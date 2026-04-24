import os
import json
import asyncio
from main import commissionRequest
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

app = FastAPI()

# Z.AI Configuration (GLM-5.1)
client = OpenAI(
    api_key=os.getenv("ZAI_API_KEY"),
    base_url="https://api.z.ai/api/paas/v4/"
)

# MCP Connection Parameters
mcp_params = StdioServerParameters(
    command="python",
    args=["mcp_server.py"]
)

@app.post("/api/v1/decide")
async def process_commission(data: commissionRequest):
    async with stdio_client(mcp_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # We get our Tools of the Trade
            mcp_tools = await session.list_tools()
            zai_tools = [{
                "type": "function",
                "function": {
                    "name": t.name,
                    "description": t.description,
                    "parameters": t.inputSchema
                }
            } for t in mcp_tools.tools]

            # 2. We organise how the agent will process data
            
            messages = [
                {
                    "role": "system", 
                    "content": (
                        "You are a Commission Decision Agent. Use the calculate_complexity_score tool "
                        "to assess the task. Then use get_market_benchmark to find the standard rate. "
                        "Return a final JSON with: 'verdict' (Accept/Negotiate/Reject), 'reasoning', "
                        "and 'counter_offer'."
                    )
                },
                {"role": "user", "content": f"New Request: {data.model_dump_json()}"}
            ]

            # 3. Agentic Loop (Reasoning + Tool Use)
            response = client.chat.completions.create(
                model="glm-5.1",
                messages=messages,
                tools=zai_tools,
                tool_choice="auto"
            )

            # Call the tool
            msg = response.choices[0].message
            if msg.tool_calls:
                messages.append(msg)
                for tool_call in msg.tool_calls:
                    # use the tool here
                    result = await session.call_tool(
                        tool_call.function.name, 
                        json.loads(tool_call.function.arguments)
                    )
                    messages.append({
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "name": tool_call.function.name,
                        "content": str(result.content)
                    })
                
                # Final rumination and structured output
                final_output = client.chat.completions.create(
                    model="glm-5.1",
                    messages=messages,
                    response_format={"type": "json_object"}
                )
                return json.loads(final_output.choices[0].message.content)

    raise HTTPException(status_code=500, detail="Decision Loop Failed")
