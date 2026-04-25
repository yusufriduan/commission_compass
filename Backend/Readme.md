# Commission Compass

Commission Compass is an AI-powered decision support platform designed for freelancers to evaluate incoming project requests. By leveraging the ILMU-GLM-5.1 model via Z.AI and the Model Context Protocol (MCP), the application analyzes project scopes, budgets, and market benchmarks to provide a verdict: Accept, Negotiate or Reject.

## Project Architecture
The project is split into two main components.  
1. **Frontend**: A modern, responsive mobile/web interface built with Flutter.
2. **Backend**: An agentic API built with FastAPI, utilizing a Reasoning + Tool Use loop to process commission data.

## Features
- **Agentic Reasoning**: Uses a specialized "Commission Decision Agent" to evaluate complexity.
- **Market Benchmarking**: Utilizes MCP tools to compare requests against industry standards.
- **Actionable Insights**: Provides a verdict, detailed reasoning and suggested counter-offers.
- **Cross-Platform**: Built with Flutter for iOS, Android and Web support.

## Tech Stack
### Backend
- Framework: FastAPI
- AI Model: ILMU-GLM-5.1
- Protocol: MCP for tool integration
- Containerization: Docker
- Language: Python 3.10+

### Frontend
- Framework: Flutter (SDK ^3.11.5)
- Icons/Assets: Cupertino Icons & Flutter SVG

## Installation & Setup
### 1. Backend Setup (FastAPI & Agent)  
 
#### Prerequisites:  
- Docker Installed
- `ZAI_API_KEY` from ILMU Console

#### Steps:
1. Navigate to the Backend directory.
```bash
cd backend
```

2. Build the Docker image:
```bash
docker build -t backend-commission-compass .
```

3. Run the container:
```bash
docker run -it --name backend-cc-container -e ZAI_API_KEY='your_actual_key_here' backend-commission-compass
```

### 2. Frontend Setup (Flutter)
#### Prerequisites
- Flutter SDK installed
- Java/Android Studio (for Android) or Xcode (for iOS)

#### Steps:
1. Navigate to the Frontend directory.
```bash
cd Frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```