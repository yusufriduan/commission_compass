# first build docker image: docker build -t backend-commission-compass .
# then create container: docker run -it --name backend-cc-container -p 8000:8000 -e ZAI_API_KEY="your_key_here" backend-commission-compass
from agent import process_commission
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

# Matches the single input from your Flutter TextField
class commissionRequest(BaseModel):
    user_input: str 

@app.post("/decision")
async def make_decision(task: commissionRequest):
    # Calling the updated async process
    result = await process_commission(task)
    # Returning the result directly so it matches the expected JSON structure
    return result