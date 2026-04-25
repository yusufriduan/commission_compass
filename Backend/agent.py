import os
from dotenv import load_dotenv
import json
from fastapi import HTTPException
from openai import OpenAI
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

load_dotenv()

# Configuration
client = OpenAI(api_key=os.getenv("ZAI_API_KEY"), base_url="https://api.ilmu.ai/v1/")
mcp_params = StdioServerParameters(command="python", args=["mcp_server.py"])

async def process_commission(data):
    async with stdio_client(mcp_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            mcp_tools = await session.list_tools()
            zai_tools = [{
                "type": "function",
                "function": {
                    "name": t.name,
                    "description": t.description,
                    "parameters": t.inputSchema
                }
            } for t in mcp_tools.tools]

            # The System Prompt now matches your Flutter AIResponse parameters
            messages = [
                {
                    "role": "system", 
                    "content": (
                        "You are a Freelance Decision Agent. Analyze the user's request. "
                        "1. Use tools to find benchmarks and complexity. "
                        "2. If input is missing (budget/hours), estimate them based on the scope. "
                        "3. Return a JSON object with these EXACT keys: "
                        "'decision' (String), "
                        "'keyReasoningContent' (String), "
                        "'prosList' (List of Strings), "
                        "'consList' (List of Strings), "
                        "'quantifiableImpactContent' (String), "
                        "'suggestionsContent' (String)."
                    )
                },
                {"role": "user", "content": f"User Prompt: {data.user_input}"}
            ]

            # Agentic Loop
            response = client.chat.completions.create(
                model="ilmu-glm-5.1",
                messages=messages,
                tools=zai_tools,
                tool_choice="auto"
            )

            msg = response.choices[0].message
            if msg.tool_calls:
                messages.append(msg)
                for tool_call in msg.tool_calls:
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
                
                # Final pass to generate the Flutter-compatible JSON
                final_output = client.chat.completions.create(
                    model="ilmu-glm-5.1",
                    messages=messages,
                    response_format={"type": "json_object"}
                )
                
                # This returns the dictionary that FastAPI will send to Flutter
                return json.loads(final_output.choices[0].message.content)

    raise HTTPException(status_code=500, detail="Decision Loop Failed")