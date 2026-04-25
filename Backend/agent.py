import os
import json
from dotenv import load_dotenv
from fastapi import HTTPException
from openai import OpenAI
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

load_dotenv()

client = OpenAI(api_key=os.getenv("ZAI_API_KEY"), base_url="https://api.ilmu.ai/v1/")
# Keeping your original working command
mcp_params = StdioServerParameters(command="python", args=["mcp_server.py"])

async def process_commission(data):
    async with stdio_client(mcp_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            
            # Sync tools with LLM
            mcp_tools = await session.list_tools()
            zai_tools = [{
                "type": "function",
                "function": {
                    "name": t.name,
                    "description": t.description,
                    "parameters": t.inputSchema
                }
            } for t in mcp_tools.tools]

            messages = [
                {
                    "role": "system", 
                    "content": (
                        "You are a Freelance Decision Agent. Analyze the user request. "
                        "1. Use tools to find benchmarks and complexity. "
                        "2. ALWAYS return a JSON object with these keys: "
                        "'decision', 'keyReasoningContent', 'prosList', 'consList', "
                        "'quantifiableImpactContent', 'suggestionsContent'."
                    )
                },
                {"role": "user", "content": f"User Prompt: {data.user_input}"}
            ]

            # Pass 1
            response = client.chat.completions.create(
                model="ilmu-glm-5.1",
                messages=messages,
                tools=zai_tools,
                tool_choice="auto"
            )

            msg = response.choices[0].message

            # Agentic Loop (If tools are needed)
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
                
                # Final Pass for JSON formatting
                final_output = client.chat.completions.create(
                    model="ilmu-glm-5.1",
                    messages=messages,
                    response_format={"type": "json_object"}
                )
                return json.loads(final_output.choices[0].message.content)

            # FALLBACK: If "Hi" or no tool call, format a standard response
            try:
                # Ask the model to format its current response into JSON
                fallback_res = client.chat.completions.create(
                    model="ilmu-glm-5.1",
                    messages=messages + [{"role": "assistant", "content": msg.content}, {"role": "user", "content": "Format your previous response into the required JSON structure."}],
                    response_format={"type": "json_object"}
                )
                return json.loads(fallback_res.choices[0].message.content)
            except:
                return {
                    "decision": "Needs Details",
                    "keyReasoningContent": msg.content or "Greeting received.",
                    "prosList": [], "consList": [],
                    "quantifiableImpactContent": "N/A",
                    "suggestionsContent": "Please provide commission details (e.g., 'I am an artist doing a logo')."
                }

    raise HTTPException(status_code=500, detail="Bridge Error")