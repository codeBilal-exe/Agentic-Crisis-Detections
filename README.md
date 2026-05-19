# CIRO — Crisis Intelligence & Response Orchestrator
**Pakistan National Emergency & Disaster Response System**
*Google Antigravity Hackathon — Challenge 3*

---

## System Architecture

CIRO uses a 4-layer architecture:
1. **Signal Layer** (FastAPI Mock Server) — generates social media, weather, and traffic signals
2. **Intelligence Layer** (Google Antigravity) — 4-agent reasoning pipeline
3. **State Layer** (Firebase Realtime Database) — single source of truth for all system state
4. **Presentation Layer** (Flutter Mobile App) — real-time coordinator and field team interface

See `/docs/architecture_diagram.png` for visual overview.

## Google Antigravity Usage

Antigravity serves as the core orchestration brain via its Manager Surface:

| Agent | Role | Input | Output |
|---|---|---|---|
| The Sentinel | Signal ingestion & Roman Urdu normalization | FastAPI /signals/all | SignalBundle JSON |
| The Analyst | Crisis detection & severity reasoning | SignalBundle | CrisisProfile JSON |
| The Commander | Response action planning | CrisisProfile | ActionPlan JSON |
| The Dispatcher | Execution simulation & Firebase writes | ActionPlan | ExecutionLog JSON |

Agent prompts are in `/intelligence_layer/`. Combined Agent Trace log exported as artifact.

## Tools & APIs Used

| Tool | Version | Purpose |
|---|---|---|
| Google Antigravity | Latest | Multi-agent orchestration |
| Python / FastAPI | 3.11 / 0.111 | Mock signal server |
| Firebase Realtime Database | Latest | Real-time state sync |
| Flutter | 3.22+ | Mobile application |
| Google Maps Flutter | 2.7.0 | Crisis & unit mapping |
| Firebase Admin SDK | 6.5.0 | Agent→Firebase writes |

## How to Run

### 1. Start the Signal Layer (FastAPI Mock Server)
```bash
cd signal_layer
pip install -r requirements.txt
cp .env.example .env  # add your Firebase Database URL
uvicorn main:app --reload --port 8000
```

### 2. Initialize Firebase
- Create Firebase project at console.firebase.google.com
- Enable Realtime Database
- Download serviceAccountKey.json → place in signal_layer/firebase_config/
- Run reset: `POST http://localhost:8000/api/simulation/reset`

### 3. Build and Run Presentation Layer (Flutter Mobile App)
```bash
cd presentation_layer
flutter pub get
flutterfire configure  # connect to your Firebase project
flutter run
```

### 4. Run Antigravity Pipeline
- Open Antigravity Manager Surface
- Load agent prompts from /intelligence_layer/ folder
- Trigger scenario via Flutter app or API
- Execute Manager pipeline

## Assumptions

1. All signal data is simulated via FastAPI mock server — no real social media scraping
2. Rescue 1122 / PDMA unit positions are mock coordinates representing real Islamabad bases
3. Traffic rerouting is visual simulation — not integrated with actual NHA/CDA systems
4. Weather data from Pakistan Meteorological Department is mocked
5. "Dispatch" simulation moves unit coordinates to midpoint toward destination — not real GPS tracking
6. Roman Urdu normalization is handled by Sentinel agent's LLM reasoning, not a custom NLP model
7. Firebase writes by Dispatcher simulate what a real government API integration would do
8. SMS alerts are simulated — no real telecom integration

## Agent Trace Logs

See `/docs/agent_trace_logs/CIRO_Agent_Trace_[timestamp].md` for full reasoning export.
Exported directly from Antigravity workspace artifacts.

## Demo Scenarios

| Scenario | Trigger Command | Primary Unit | Alert Type |
|---|---|---|---|
| G-10 Urban Flood | `urban_flood_g10` | 1122-ISB-04 (Flood) | 🚨 HIGH FLOOD |
| M-2 Road Accident | `road_accident_m2` | 1122-ISB-02 (Medical) | 🚨 CRITICAL ACCIDENT |
| Lahore Heatwave | `heatwave_lahore` | 1122-ISB-02 (Medical) | 🌡️ CRITICAL HEAT |
| I-8 Transformer | `power_failure_i8` | 1122-ISB-03 (Fire) | ⚡ MEDIUM INFRA |
