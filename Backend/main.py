# first build docker image: docker build -t backend-commission-compass
# then create container: docker run -it --name backend-cc-container ./[DIRECTORY OF THE PYTHON FILE]

# to run: docker start -ai backend-cc-container

from agent import process_commission
import os
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

# Base Structure: Gather and organise input herie, then the API will take the task to agent.py for processing

class commissionRequest(BaseModel):
    client_name: str
    project_scope: str
    budget: float
    est_hours: float
    hourly_rate: float
    deadline_days: int

@app.post("/decision")
def make_decision(task: commissionRequest):
    result = process_commission(task.dict())
    return {"decision": result}

