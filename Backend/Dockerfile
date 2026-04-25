# Use a lightweight Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies (needed for some MCP networking tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set environment variables
# Note: ZAI_API_KEY should be passed at runtime, not hardcoded here
ENV PYTHONUNBUFFERED=1

# Expose the FastAPI port
EXPOSE 8000

# Start the application
# We run main.py which initializes the FastAPI app and agent
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]