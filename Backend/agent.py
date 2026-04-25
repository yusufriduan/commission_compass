import os
import json
import re
from dotenv import load_dotenv
from fastapi import HTTPException
from openai import OpenAI
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

load_dotenv()

client = OpenAI(
    api_key=os.getenv("ZAI_API_KEY"),
    base_url="https://api.ilmu.ai/v1/"
)

mcp_params = StdioServerParameters(
    command="python",
    args=["mcp_server.py"]
)

def safe_json_load(content: str):
    if not content or not content.strip():
        raise ValueError("Empty LLM response")

    # Remove markdown code blocks if present
    content = re.sub(r"```json", "", content)
    content = re.sub(r"```", "", content)

    content = content.strip()

    # Extract first valid JSON object (extra safety)
    match = re.search(r"\{.*\}", content, re.DOTALL)
    if match:
        content = match.group(0)

    return json.loads(content)


async def process_commission(data):

    async with stdio_client(mcp_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # Load tools
            mcp_tools = await session.list_tools()

            zai_tools = [
                {
                    "type": "function",
                    "function": {
                        "name": t.name,
                        "description": t.description,
                        "parameters": t.inputSchema
                    }
                }
                for t in mcp_tools.tools
            ]

            # Strong system prompt
            messages = [
                {
                    "role": "system",
                    "content": (
                        "You are a Freelance Decision Agent.\n"
                        "You MUST return ONLY valid JSON.\n"
                        "No markdown. No explanations outside JSON.\n\n"
                        "Format:\n"
                        "{\n"
                        "  \"decision\": \"...\",\n"
                        "  \"keyReasoningContent\": \"...\",\n"
                        "  \"prosList\": [],\n"
                        "  \"consList\": [],\n"
                        "  \"quantifiableImpactContent\": \"...\",\n"
                        "  \"suggestionsContent\": \"...\"\n"
                        "}"
                    )
                },
                {
                    "role": "user",
                    "content": data.user_input
                }
            ]

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
                    try:
                        args = json.loads(tool_call.function.arguments)
                    except:
                        args = {}

                    result = await session.call_tool(
                        tool_call.function.name,
                        args
                    )

                    messages.append({
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "name": tool_call.function.name,
                        "content": str(result.content)
                    })

            final_output = client.chat.completions.create(
                model="ilmu-glm-5.1",
                messages=messages,
                response_format={"type": "json_object"}
            )

            content = final_output.choices[0].message.content

            try:
                return safe_json_load(content)

            except Exception as e:
                print("🚨 RAW BAD OUTPUT:\n", repr(content))

                raise HTTPException(
                    status_code=500,
                    detail=f"Invalid AI JSON: {str(e)}"
                )