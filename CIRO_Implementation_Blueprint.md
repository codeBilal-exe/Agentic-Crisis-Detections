# CIRO — Crisis Intelligence & Response Orchestrator
## Complete Implementation Blueprint (Antigravity Hackathon Submission)
### Version 1.0 | Challenge 3 | National Emergency & Disaster Response System

---

> **HOW TO USE THIS DOCUMENT**
> This is a full build specification. Every section maps directly to something you must build. Read top to bottom before writing a single line of code. Every schema, every agent prompt, every screen, every endpoint is defined here exactly as it should be implemented. Do not invent or improvise — follow this blueprint precisely.

---

## TABLE OF CONTENTS

1. [Project Vision & Scope](#1-project-vision--scope)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Technology Stack — Complete Reference](#3-technology-stack--complete-reference)
4. [Folder & File Structure](#4-folder--file-structure)
5. [Core Data Schemas](#5-core-data-schemas)
6. [Firebase Database Schema](#6-firebase-database-schema)
7. [FastAPI Backend — All Endpoints](#7-fastapi-backend--all-endpoints)
8. [Mock Data & Crisis Simulation Engine](#8-mock-data--crisis-simulation-engine)
9. [Google Antigravity — Agent Architecture](#9-google-antigravity--agent-architecture)
10. [Flutter Mobile App — All Screens & Logic](#10-flutter-mobile-app--all-screens--logic)
11. [End-to-End Data Flow](#11-end-to-end-data-flow)
12. [Pre-Built Demo Crisis Scenarios](#12-pre-built-demo-crisis-scenarios)
13. [Demo Video Script (3–5 Minutes)](#13-demo-video-script-35-minutes)
14. [Evaluation Criteria Mapping](#14-evaluation-criteria-mapping)
15. [README Template](#15-readme-template)

---

## 1. PROJECT VISION & SCOPE

### What CIRO Is
CIRO is a **national-level emergency and disaster response orchestration system** for Pakistan. It ingests real-time multi-source signals (social media reports, weather data, traffic feeds, and direct citizen reports), detects emerging crises using an agentic AI pipeline, generates coordinated response action plans, simulates their execution, and visualizes the before/after impact — all in real time on a mobile dashboard used by emergency coordinators.

### What Makes CIRO Different from the Baseline
The challenge asks for a city-level tool. CIRO targets **Pakistan's national emergency infrastructure** — specifically integrating the workflow of **Rescue 1122** (Punjab's emergency service), **PDMA** (Provincial Disaster Management Authority), and **NHA** (National Highway Authority) as stakeholders. This raises the perceived impact dramatically and aligns with a real gap in Pakistan's crisis response ecosystem.

### Core User Personas
| Persona | Role in CIRO |
|---|---|
| Emergency Coordinator | Views the Dispatcher Dashboard, approves/monitors agent decisions |
| Field Commander (Rescue 1122) | Receives unit dispatch orders via the app |
| Public Citizen | Submits crisis reports, receives route alerts |
| System Admin | Triggers simulation scenarios, views agent logs |

### Scope Boundaries (What Is and Is NOT In Scope)
**IN SCOPE:**
- Multi-source signal ingestion (mocked APIs + manual text input)
- 4-agent Antigravity pipeline (Sentinel → Analyst → Commander → Dispatcher)
- Firebase real-time sync between agent actions and Flutter UI
- Flutter mobile app with live map, alert feed, unit tracker
- Full simulation of traffic rerouting, unit dispatch, alert broadcasting
- Before/after outcome visualization
- Crisis scenarios for: urban flooding, road accidents, heatwave, infrastructure failure

**OUT OF SCOPE (explicitly):**
- Real SMS/telecom integration (mocked)
- Real Rescue 1122 API (no such public API exists; mocked)
- Real payment or government authentication
- Web app (mobile is mandatory; web is optional and will be skipped to focus quality)

---

## 2. SYSTEM ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                        SIGNAL SOURCES                           │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐    │
│  │ Social Media │  │ Weather API  │  │ Traffic/Maps Feed  │    │
│  │ (Mock Feed)  │  │ (Mock API)   │  │ (Mock API)         │    │
│  └──────┬───────┘  └──────┬───────┘  └─────────┬──────────┘    │
└─────────┼─────────────────┼──────────────────────┼─────────────┘
          │                 │                      │
          └─────────────────▼──────────────────────┘
                            │
                    ┌───────▼────────┐
                    │  FastAPI Mock  │
                    │  Backend       │
                    │  (Python 3.11) │
                    └───────┬────────┘
                            │ HTTP Polling
          ┌─────────────────▼──────────────────────────────────┐
          │              GOOGLE ANTIGRAVITY                     │
          │                                                      │
          │  ┌────────────┐    ┌────────────┐                   │
          │  │  AGENT 1   │───▶│  AGENT 2   │                   │
          │  │  Sentinel  │    │  Analyst   │                   │
          │  │  (Ingest)  │    │  (Detect)  │                   │
          │  └────────────┘    └─────┬──────┘                   │
          │                          │                           │
          │  ┌────────────┐    ┌─────▼──────┐                   │
          │  │  AGENT 4   │◀───│  AGENT 3   │                   │
          │  │ Dispatcher │    │ Commander  │                   │
          │  │ (Execute)  │    │  (Plan)    │                   │
          │  └─────┬──────┘    └────────────┘                   │
          └────────┼───────────────────────────────────────────┘
                   │ Firebase Admin SDK Write
          ┌────────▼────────────────────────────────────────────┐
          │              FIREBASE REALTIME DATABASE              │
          │  /active_crises  /units  /alerts  /routes  /logs    │
          └────────┬────────────────────────────────────────────┘
                   │ Real-time Listeners (onValue stream)
          ┌────────▼────────────────────────────────────────────┐
          │              FLUTTER MOBILE APP                      │
          │  Screen 1: Dashboard   Screen 2: Crisis Detail       │
          │  Screen 3: Map View    Screen 4: Unit Tracker        │
          │  Screen 5: Alert Feed  Screen 6: Agent Logs          │
          └─────────────────────────────────────────────────────┘
```

### Component Responsibilities Summary
| Component | Technology | Responsibility |
|---|---|---|
| Mock Signal Server | FastAPI (Python) | Generates simulated social/weather/traffic signals |
| Antigravity Agents | Google Antigravity | 4-agent reasoning + decision pipeline |
| Firebase RTD | Firebase Realtime Database | Single source of truth for app state |
| Flutter App | Flutter 3.x (Dart) | Mobile UI for coordinators and field teams |

---

## 3. TECHNOLOGY STACK — COMPLETE REFERENCE

### Backend
| Tool | Version | Purpose | Install Command |
|---|---|---|---|
| Python | 3.11+ | Backend language | — |
| FastAPI | 0.111.0 | REST API framework | `pip install fastapi` |
| Uvicorn | 0.30.0 | ASGI server | `pip install uvicorn` |
| Firebase Admin SDK | 6.5.0 | Write to Firebase from agents | `pip install firebase-admin` |
| httpx | 0.27.0 | Async HTTP client for agents | `pip install httpx` |
| Faker | 25.0.0 | Generate mock signal data | `pip install faker` |
| APScheduler | 3.10.4 | Periodic signal generation | `pip install apscheduler` |
| python-dotenv | 1.0.1 | Manage env variables | `pip install python-dotenv` |
| Pydantic | 2.7.0 | Data validation/schemas | `pip install pydantic` |

### Mobile App
| Tool | Version | Purpose |
|---|---|---|
| Flutter | 3.22.0+ | Mobile framework |
| Dart | 3.4.0+ | Language |
| firebase_core | ^3.1.0 | Firebase init |
| firebase_database | ^11.0.0 | Realtime Database listeners |
| google_maps_flutter | ^2.7.0 | Map rendering |
| flutter_riverpod | ^2.5.1 | State management |
| go_router | ^14.0.0 | Navigation |
| fl_chart | ^0.68.0 | Charts for outcome visualization |
| lottie | ^3.1.0 | Animations for alert states |
| intl | ^0.19.0 | Date formatting |
| http | ^1.2.0 | API calls |

### Firebase Services
| Service | Purpose |
|---|---|
| Firebase Realtime Database | Live state sync (crises, units, alerts, routes) |
| Firebase Authentication | Anonymous auth for coordinator session (optional) |

### Google Antigravity
- **Manager Surface**: Orchestrates all 4 agents
- **Tool Access per Agent**: HTTP (polling FastAPI), Python script execution, Firebase writes
- **Artifact Output**: Each agent produces a markdown artifact (serves as Agent Trace log)
- **Model**: Gemini 1.5 Pro (or whatever is default in Antigravity at time of build)

---

## 4. FOLDER & FILE STRUCTURE

```
ciro/
├── backend/
│   ├── main.py                    # FastAPI app entrypoint
│   ├── routers/
│   │   ├── signals.py             # Signal feed endpoints
│   │   ├── crisis.py              # Crisis injection & management
│   │   ├── units.py               # Rescue unit mock data
│   │   └── simulation.py          # Simulation control
│   ├── models/
│   │   ├── signal.py              # Pydantic models for signals
│   │   ├── crisis.py              # Crisis profile models
│   │   └── action.py              # Action plan models
│   ├── services/
│   │   ├── signal_generator.py    # Mock data factory
│   │   ├── firebase_service.py    # Firebase write helpers
│   │   └── scenario_loader.py     # Pre-built crisis scenarios
│   ├── scenarios/
│   │   ├── urban_flood_g10.json   # Scenario 1
│   │   ├── road_accident_m2.json  # Scenario 2
│   │   ├── heatwave_lahore.json   # Scenario 3
│   │   └── power_failure_i8.json  # Scenario 4
│   ├── firebase_config/
│   │   └── serviceAccountKey.json # Firebase admin credentials
│   ├── requirements.txt
│   └── .env
│
├── antigravity/
│   ├── agent_1_sentinel_prompt.md     # Full system prompt for Sentinel
│   ├── agent_2_analyst_prompt.md      # Full system prompt for Analyst
│   ├── agent_3_commander_prompt.md    # Full system prompt for Commander
│   ├── agent_4_dispatcher_prompt.md   # Full system prompt for Dispatcher
│   ├── manager_orchestration.md       # Manager Surface instructions
│   └── tool_definitions.json          # Tool schemas for all agents
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart       # Auto-generated by FlutterFire CLI
│   │   ├── core/
│   │   │   ├── constants.dart          # Colors, strings, keys
│   │   │   ├── theme.dart              # App-wide theme
│   │   │   └── router.dart             # go_router config
│   │   ├── models/
│   │   │   ├── crisis_model.dart
│   │   │   ├── unit_model.dart
│   │   │   ├── alert_model.dart
│   │   │   └── route_model.dart
│   │   ├── providers/
│   │   │   ├── crisis_provider.dart    # Riverpod stream providers
│   │   │   ├── units_provider.dart
│   │   │   ├── alerts_provider.dart
│   │   │   └── simulation_provider.dart
│   │   ├── services/
│   │   │   └── firebase_service.dart   # RTD stream wrappers
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── dashboard_screen.dart   # Main coordinator view
│   │       ├── crisis_detail_screen.dart
│   │       ├── map_screen.dart         # Live Google Maps
│   │       ├── unit_tracker_screen.dart
│   │       ├── alert_feed_screen.dart
│   │       └── agent_logs_screen.dart
│   ├── pubspec.yaml
│   └── assets/
│       ├── icons/
│       │   ├── rescue_1122.png
│       │   ├── pdma.png
│       │   └── crisis_icons/
│       └── animations/
│           ├── alert_pulse.json        # Lottie
│           └── unit_moving.json        # Lottie
│
├── docs/
│   ├── architecture_diagram.png
│   └── agent_trace_logs/              # Exported from Antigravity
│
└── README.md
```

---

## 5. CORE DATA SCHEMAS

These schemas are the **universal language** between all components. Every agent reads and writes using these exact structures.

### 5.1 RawSignal
```json
{
  "signal_id": "sig_abc123",
  "source": "social_media",            // "social_media" | "weather" | "traffic" | "citizen_report"
  "timestamp": "2024-07-15T14:32:00Z",
  "raw_text": "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain",
  "normalized_text": "G-10 area flooded, vehicles stranded",
  "location": {
    "area": "G-10",
    "city": "Islamabad",
    "lat": 33.6844,
    "lng": 73.0479
  },
  "metadata": {
    "platform": "Twitter/X",
    "engagement_score": 47,
    "language_detected": "roman_urdu"
  }
}
```

### 5.2 SignalBundle (Sentinel Output)
```json
{
  "bundle_id": "bundle_xyz789",
  "generated_at": "2024-07-15T14:33:00Z",
  "signals": [ /* array of RawSignal */ ],
  "signal_count": 8,
  "dominant_location": "G-10, Islamabad",
  "dominant_event_type": "urban_flooding",
  "time_window_minutes": 30
}
```

### 5.3 CrisisProfile (Analyst Output)
```json
{
  "crisis_id": "crisis_001",
  "detected_at": "2024-07-15T14:34:00Z",
  "crisis_type": "urban_flooding",        // "urban_flooding" | "road_accident" | "heatwave" | "infrastructure_failure" | "unknown"
  "severity": "HIGH",                      // "LOW" | "MEDIUM" | "HIGH" | "CRITICAL"
  "confidence": 0.91,                      // 0.0 to 1.0
  "confidence_label": "HIGH",
  "affected_area": {
    "name": "G-10 Sector, Islamabad",
    "lat": 33.6844,
    "lng": 73.0479,
    "radius_km": 2.0
  },
  "impact_assessment": {
    "estimated_people_affected": 2000,
    "roads_blocked": ["G-10 Markaz Road", "IJP Road intersection"],
    "vehicles_stranded": true,
    "casualties_likely": false,
    "infrastructure_damage": "moderate"
  },
  "supporting_signals": [ /* signal_ids that triggered this */ ],
  "reasoning_summary": "3 social media reports in 30 minutes from G-10 describing flooding, corroborated by heavy rainfall weather alert and traffic congestion spike on IJP Road. High confidence urban flooding event.",
  "status": "active"                       // "active" | "resolved" | "false_positive"
}
```

### 5.4 ActionPlan (Commander Output)
```json
{
  "plan_id": "plan_001",
  "crisis_id": "crisis_001",
  "generated_at": "2024-07-15T14:35:00Z",
  "response_protocol": "URBAN_FLOOD_PROTOCOL_ALPHA",
  "actions": [
    {
      "action_id": "act_001",
      "action_type": "dispatch_unit",
      "priority": 1,
      "target": {
        "unit_id": "1122-ISB-04",
        "unit_name": "Rescue 1122 Unit 4 — Islamabad",
        "unit_type": "flood_rescue"
      },
      "instruction": "Deploy flood rescue team to G-10 Markaz. Estimated ETA: 8 minutes.",
      "coordinates": { "lat": 33.6844, "lng": 73.0479 }
    },
    {
      "action_id": "act_002",
      "action_type": "traffic_reroute",
      "priority": 2,
      "affected_road": "G-10 Markaz Road",
      "alternate_route": {
        "name": "Via Srinagar Highway → Margalla Road",
        "waypoints": [
          { "lat": 33.6900, "lng": 73.0400 },
          { "lat": 33.7000, "lng": 73.0600 }
        ]
      },
      "instruction": "Divert all inbound G-10 traffic to Srinagar Highway alternate via NHA coordination."
    },
    {
      "action_id": "act_003",
      "action_type": "broadcast_alert",
      "priority": 1,
      "alert_text": "🚨 FLOOD ALERT — G-10 Islamabad: Heavy flooding reported. Avoid G-10 Markaz Road. Use Srinagar Highway alternate. Rescue 1122 deployed. Stay safe.",
      "urdu_alert_text": "🚨 سیلابی الرٹ — جی-10 اسلام آباد: شدید بارش سے سیلاب۔ جی-10 مرکز روڈ سے بچیں۔ ریسکیو 1122 تعینات۔",
      "target_channels": ["in_app", "sms_mock", "pdma_dashboard"],
      "severity": "HIGH"
    },
    {
      "action_id": "act_004",
      "action_type": "open_relief_point",
      "priority": 3,
      "location": {
        "name": "G-10 Community Center",
        "lat": 33.6850,
        "lng": 73.0490
      },
      "instruction": "Activate G-10 Community Center as temporary relief point. Coordinate with PDMA for water pumps."
    }
  ],
  "estimated_resolution_minutes": 45,
  "coordinating_agencies": ["Rescue 1122", "PDMA", "NHA", "CDA Traffic Police"]
}
```

### 5.5 ExecutionLog (Dispatcher Output)
```json
{
  "log_id": "log_001",
  "plan_id": "plan_001",
  "crisis_id": "crisis_001",
  "executed_at": "2024-07-15T14:36:00Z",
  "execution_steps": [
    {
      "step": 1,
      "action_id": "act_001",
      "status": "EXECUTED",
      "firebase_path": "/units/1122-ISB-04",
      "change": { "status": "dispatched", "destination": "G-10 Markaz", "eta_minutes": 8 },
      "timestamp": "2024-07-15T14:36:01Z"
    },
    {
      "step": 2,
      "action_id": "act_002",
      "status": "EXECUTED",
      "firebase_path": "/routes/active_reroutes/reroute_001",
      "change": { "road_blocked": "G-10 Markaz Road", "alternate": "Srinagar Highway" },
      "timestamp": "2024-07-15T14:36:02Z"
    },
    {
      "step": 3,
      "action_id": "act_003",
      "status": "EXECUTED",
      "firebase_path": "/alerts/alert_001",
      "change": { "alert_created": true, "channels_notified": 3 },
      "timestamp": "2024-07-15T14:36:03Z"
    }
  ],
  "overall_status": "COMPLETE",
  "firebase_sync_confirmed": true
}
```

---

## 6. FIREBASE DATABASE SCHEMA

The Firebase Realtime Database has the following top-level nodes. Every key and value is defined exactly as written here. Flutter listens to these paths.

```json
{
  "system_state": {
    "mode": "monitoring",               // "monitoring" | "crisis_active" | "simulation"
    "last_updated": "ISO_TIMESTAMP",
    "active_crisis_count": 0,
    "signal_ingestion_active": true
  },

  "active_crises": {
    "crisis_001": {
      "crisis_id": "crisis_001",
      "crisis_type": "urban_flooding",
      "severity": "HIGH",
      "confidence": 0.91,
      "confidence_label": "HIGH",
      "detected_at": "ISO_TIMESTAMP",
      "affected_area_name": "G-10 Sector, Islamabad",
      "affected_lat": 33.6844,
      "affected_lng": 73.0479,
      "affected_radius_km": 2.0,
      "roads_blocked": ["G-10 Markaz Road", "IJP Road intersection"],
      "estimated_people_affected": 2000,
      "status": "active",
      "plan_id": "plan_001",
      "reasoning_summary": "3 social media reports in 30 minutes..."
    }
  },

  "units": {
    "1122-ISB-01": {
      "unit_id": "1122-ISB-01",
      "name": "Rescue 1122 — Alpha Team",
      "type": "general_rescue",         // "general_rescue" | "flood_rescue" | "fire" | "medical" | "pdma_assessment"
      "status": "available",            // "available" | "dispatched" | "on_scene" | "returning" | "standby"
      "base_lat": 33.7294,
      "base_lng": 73.0931,
      "current_lat": 33.7294,
      "current_lng": 73.0931,
      "destination": null,
      "eta_minutes": null,
      "assigned_crisis_id": null,
      "last_updated": "ISO_TIMESTAMP"
    },
    "1122-ISB-02": {
      "unit_id": "1122-ISB-02",
      "name": "Rescue 1122 — Bravo Team",
      "type": "medical",
      "status": "available",
      "base_lat": 33.6938,
      "base_lng": 73.0651,
      "current_lat": 33.6938,
      "current_lng": 73.0651,
      "destination": null,
      "eta_minutes": null,
      "assigned_crisis_id": null,
      "last_updated": "ISO_TIMESTAMP"
    },
    "1122-ISB-03": {
      "unit_id": "1122-ISB-03",
      "name": "Rescue 1122 — Charlie Team",
      "type": "fire",
      "status": "available",
      "base_lat": 33.6611,
      "base_lng": 73.0169,
      "current_lat": 33.6611,
      "current_lng": 73.0169,
      "destination": null,
      "eta_minutes": null,
      "assigned_crisis_id": null,
      "last_updated": "ISO_TIMESTAMP"
    },
    "1122-ISB-04": {
      "unit_id": "1122-ISB-04",
      "name": "Rescue 1122 — Delta Team (Flood)",
      "type": "flood_rescue",
      "status": "available",
      "base_lat": 33.6701,
      "base_lng": 73.0553,
      "current_lat": 33.6701,
      "current_lng": 73.0553,
      "destination": null,
      "eta_minutes": null,
      "assigned_crisis_id": null,
      "last_updated": "ISO_TIMESTAMP"
    },
    "pdma-team-01": {
      "unit_id": "pdma-team-01",
      "name": "PDMA Assessment Team — Islamabad",
      "type": "pdma_assessment",
      "status": "standby",
      "base_lat": 33.7215,
      "base_lng": 73.0433,
      "current_lat": 33.7215,
      "current_lng": 73.0433,
      "destination": null,
      "eta_minutes": null,
      "assigned_crisis_id": null,
      "last_updated": "ISO_TIMESTAMP"
    }
  },

  "alerts": {
    "alert_001": {
      "alert_id": "alert_001",
      "crisis_id": "crisis_001",
      "created_at": "ISO_TIMESTAMP",
      "severity": "HIGH",
      "title": "🚨 FLOOD ALERT — G-10 Islamabad",
      "body": "Heavy flooding reported in G-10. Avoid G-10 Markaz Road. Rescue 1122 deployed.",
      "urdu_body": "جی-10 میں شدید سیلاب۔ جی-10 مرکز روڈ سے بچیں۔ ریسکیو 1122 تعینات۔",
      "channels_sent": ["in_app", "sms_mock", "pdma_dashboard"],
      "acknowledged": false
    }
  },

  "routes": {
    "active_reroutes": {
      "reroute_001": {
        "reroute_id": "reroute_001",
        "crisis_id": "crisis_001",
        "blocked_road": "G-10 Markaz Road",
        "alternate_route_name": "Srinagar Highway → Margalla Road",
        "status": "active",             // "active" | "cleared"
        "created_at": "ISO_TIMESTAMP",
        "waypoints": [
          { "lat": 33.6900, "lng": 73.0400 },
          { "lat": 33.7000, "lng": 73.0600 }
        ]
      }
    }
  },

  "agent_logs": {
    "log_001": {
      "log_id": "log_001",
      "timestamp": "ISO_TIMESTAMP",
      "agent": "Sentinel",
      "message": "Ingested 8 signals. Dominant cluster: G-10 flooding. Passing bundle to Analyst.",
      "data_ref": "bundle_xyz789"
    },
    "log_002": {
      "timestamp": "ISO_TIMESTAMP",
      "agent": "Analyst",
      "message": "Crisis detected: Urban flooding G-10. Severity: HIGH. Confidence: 91%. Reasoning: 3 corroborating social media reports + weather alert.",
      "data_ref": "crisis_001"
    },
    "log_003": {
      "timestamp": "ISO_TIMESTAMP",
      "agent": "Commander",
      "message": "Action plan generated: 4 actions. Dispatching 1122-ISB-04, rerouting traffic, broadcasting alert, activating relief point.",
      "data_ref": "plan_001"
    },
    "log_004": {
      "timestamp": "ISO_TIMESTAMP",
      "agent": "Dispatcher",
      "message": "Execution complete. Firebase updated: /units, /alerts, /routes, /active_crises. All actions confirmed.",
      "data_ref": "log_001"
    }
  },

  "signal_feed": {
    "recent_signals": {
      "sig_001": {
        "signal_id": "sig_001",
        "source": "social_media",
        "timestamp": "ISO_TIMESTAMP",
        "normalized_text": "G-10 flooding — vehicles stuck on main road",
        "location_area": "G-10, Islamabad",
        "event_type": "urban_flooding"
      }
    }
  },

  "outcome_metrics": {
    "before": {
      "congestion_level": 95,           // 0-100
      "units_available": 5,
      "alerts_active": 0,
      "estimated_stranded_vehicles": 35
    },
    "after": {
      "congestion_level": 40,
      "units_available": 4,
      "alerts_active": 1,
      "estimated_stranded_vehicles": 5
    },
    "resolution_time_minutes": 45,
    "last_updated": "ISO_TIMESTAMP"
  }
}
```

---

## 7. FASTAPI BACKEND — ALL ENDPOINTS

### File: `backend/main.py`
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import signals, crisis, units, simulation

app = FastAPI(title="CIRO Mock Signal Server", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(signals.router, prefix="/api/signals", tags=["Signals"])
app.include_router(crisis.router, prefix="/api/crisis", tags=["Crisis"])
app.include_router(units.router, prefix="/api/units", tags=["Units"])
app.include_router(simulation.router, prefix="/api/simulation", tags=["Simulation"])

@app.get("/")
def root():
    return {"status": "CIRO Mock Server running", "version": "1.0.0"}
```

### Endpoint Reference Table
| Method | Endpoint | Description | Used By |
|---|---|---|---|
| GET | `/api/signals/social` | Returns last N social media signals | Sentinel Agent |
| GET | `/api/signals/weather` | Returns current weather alerts | Sentinel Agent |
| GET | `/api/signals/traffic` | Returns traffic anomaly data | Sentinel Agent |
| GET | `/api/signals/all` | Returns combined signal bundle | Sentinel Agent |
| POST | `/api/crisis/inject` | Injects a pre-built crisis scenario | Admin/Demo |
| GET | `/api/crisis/active` | Lists all active crisis profiles | Commander Agent |
| POST | `/api/crisis/resolve/{crisis_id}` | Marks crisis as resolved | Dispatcher Agent |
| GET | `/api/units/available` | Lists all Rescue units and their status | Commander Agent |
| POST | `/api/units/dispatch` | Simulates dispatching a unit | Dispatcher Agent |
| GET | `/api/simulation/scenarios` | Lists available demo scenarios | Admin |
| POST | `/api/simulation/trigger/{scenario_name}` | Loads and activates a scenario | Admin/Demo |
| POST | `/api/simulation/reset` | Resets all Firebase state to baseline | Admin |
| GET | `/api/simulation/status` | Returns current simulation status | Admin |

### File: `backend/routers/signals.py` — Full Implementation
```python
from fastapi import APIRouter, Query
from services.signal_generator import SignalGenerator
from typing import Optional

router = APIRouter()
generator = SignalGenerator()

@router.get("/social")
def get_social_signals(limit: int = Query(default=10, le=50)):
    """
    Returns the most recent mock social media signals.
    In crisis scenario mode, these contain flooding/accident reports in Roman Urdu and English.
    """
    return {
        "source": "social_media_mock",
        "signals": generator.get_social_signals(limit)
    }

@router.get("/weather")
def get_weather_alerts():
    """
    Returns simulated weather alert data for major Pakistani cities.
    Severity: NONE | WATCH | WARNING | EMERGENCY
    """
    return {
        "source": "pakistan_met_department_mock",
        "timestamp": generator.now_iso(),
        "alerts": generator.get_weather_alerts()
    }

@router.get("/traffic")
def get_traffic_data():
    """
    Returns mock traffic congestion data. Congestion score 0-100.
    Anomaly threshold: score > 70.
    """
    return {
        "source": "google_maps_traffic_mock",
        "timestamp": generator.now_iso(),
        "segments": generator.get_traffic_segments()
    }

@router.get("/all")
def get_all_signals():
    """
    Aggregated endpoint — returns social + weather + traffic in one call.
    Used by Sentinel agent for efficiency.
    """
    return {
        "bundle_id": generator.new_bundle_id(),
        "timestamp": generator.now_iso(),
        "social": generator.get_social_signals(15),
        "weather": generator.get_weather_alerts(),
        "traffic": generator.get_traffic_segments()
    }
```

### File: `backend/routers/simulation.py` — Full Implementation
```python
from fastapi import APIRouter, HTTPException
from services.scenario_loader import ScenarioLoader
from services.firebase_service import FirebaseService

router = APIRouter()
loader = ScenarioLoader()
firebase = FirebaseService()

@router.get("/scenarios")
def list_scenarios():
    return {"scenarios": loader.list_available_scenarios()}

@router.post("/trigger/{scenario_name}")
def trigger_scenario(scenario_name: str):
    """
    Loads a scenario JSON and injects signals into the mock feed.
    Also sets system_state.mode = "crisis_active" in Firebase.
    """
    scenario = loader.load_scenario(scenario_name)
    if not scenario:
        raise HTTPException(status_code=404, detail=f"Scenario '{scenario_name}' not found")
    
    # Inject signals into the active feed
    loader.activate_scenario(scenario)
    
    # Signal Firebase that simulation is running
    firebase.set("system_state/mode", "simulation")
    firebase.set("system_state/last_updated", loader.now_iso())
    
    return {
        "status": "scenario_activated",
        "scenario": scenario_name,
        "signal_count_injected": scenario.get("signal_count", 0),
        "message": "Signals injected. Run Antigravity pipeline to detect and respond."
    }

@router.post("/reset")
def reset_simulation():
    """
    Resets Firebase to clean baseline state. 
    Clears: active_crises, alerts, routes, agent_logs, outcome_metrics.
    Resets: units to available, system_state to monitoring.
    """
    firebase.reset_to_baseline()
    return {"status": "reset_complete", "message": "System returned to monitoring baseline."}

@router.get("/status")
def get_simulation_status():
    return firebase.get("system_state")
```

### File: `backend/services/signal_generator.py` — Full Implementation
```python
import uuid
import random
from datetime import datetime, timezone
from faker import Faker

fake = Faker()

# Crisis-specific signal templates
FLOOD_SOCIAL_SIGNALS = [
    "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain",
    "G10 sector completely flooded. Main road blocked. Rescue needed ASAP!",
    "Yaar G-10 markaz ke paas itna paani hai ke guzarna mushkil hai",
    "Flash flood G-10 Islamabad! Cars stuck. Roads impassable. Where is rescue?",
    "Heavy rain causing flooding in G-10, multiple vehicles stranded on main road",
    "G-10 paani mein doob gaya hai bhai. Rescue 1122 bulao jaldi",
    "Islamabad G-10 main road blocked due to heavy flooding. Avoid this area!",
    "IJP Road G-10 crossing completely under water. Major traffic jam building up"
]

FLOOD_NORMALIZED = [
    "G-10 sector flooded, vehicles stranded",
    "G-10 main road blocked, flooding critical",
    "G-10 area flooded, road impassable",
    "Flash flood G-10, vehicles stuck, rescue needed",
    "Heavy flooding G-10, vehicles stranded on main road",
    "G-10 flooded, requesting Rescue 1122",
    "G-10 main road blocked by flooding",
    "IJP Road G-10 submerged, traffic blocked"
]

NORMAL_SOCIAL_SIGNALS = [
    "Traffic moving smoothly on Constitution Avenue today",
    "Nice weather in Islamabad this morning",
    "F-10 Markaz parking is crowded as usual",
    "Blue Area office hours traffic picking up",
    "Margalla road clear and scenic today"
]

class SignalGenerator:
    def __init__(self):
        self._crisis_mode = False
        self._crisis_type = None
        self._crisis_location = None
    
    def activate_crisis_mode(self, crisis_type: str, location: str):
        self._crisis_mode = True
        self._crisis_type = crisis_type
        self._crisis_location = location
    
    def deactivate_crisis_mode(self):
        self._crisis_mode = False
    
    def new_signal_id(self): return f"sig_{uuid.uuid4().hex[:8]}"
    def new_bundle_id(self): return f"bundle_{uuid.uuid4().hex[:8]}"
    def now_iso(self): return datetime.now(timezone.utc).isoformat()
    
    def get_social_signals(self, limit: int = 10) -> list:
        signals = []
        if self._crisis_mode and self._crisis_type == "urban_flooding":
            # Generate crisis-weighted signals
            n_crisis = min(limit, random.randint(4, 7))
            n_normal = limit - n_crisis
            
            for i in range(n_crisis):
                idx = i % len(FLOOD_SOCIAL_SIGNALS)
                signals.append({
                    "signal_id": self.new_signal_id(),
                    "source": "social_media",
                    "timestamp": self.now_iso(),
                    "raw_text": FLOOD_SOCIAL_SIGNALS[idx],
                    "normalized_text": FLOOD_NORMALIZED[idx],
                    "location": {
                        "area": "G-10",
                        "city": "Islamabad",
                        "lat": 33.6844 + random.uniform(-0.005, 0.005),
                        "lng": 73.0479 + random.uniform(-0.005, 0.005)
                    },
                    "metadata": {
                        "platform": random.choice(["Twitter/X", "Facebook", "WhatsApp Group"]),
                        "engagement_score": random.randint(20, 150),
                        "language_detected": random.choice(["roman_urdu", "english"])
                    }
                })
            
            for _ in range(n_normal):
                signals.append(self._generate_normal_signal())
        else:
            for _ in range(limit):
                signals.append(self._generate_normal_signal())
        
        random.shuffle(signals)
        return signals
    
    def _generate_normal_signal(self) -> dict:
        text = random.choice(NORMAL_SOCIAL_SIGNALS)
        return {
            "signal_id": self.new_signal_id(),
            "source": "social_media",
            "timestamp": self.now_iso(),
            "raw_text": text,
            "normalized_text": text,
            "location": {
                "area": random.choice(["F-7", "G-6", "Blue Area", "F-10", "E-7"]),
                "city": "Islamabad",
                "lat": 33.7 + random.uniform(-0.05, 0.05),
                "lng": 73.0 + random.uniform(-0.05, 0.05)
            },
            "metadata": {
                "platform": random.choice(["Twitter/X", "Facebook"]),
                "engagement_score": random.randint(1, 15),
                "language_detected": "english"
            }
        }
    
    def get_weather_alerts(self) -> list:
        if self._crisis_mode and self._crisis_type == "urban_flooding":
            return [
                {
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "HEAVY_RAINFALL",
                    "severity": "WARNING",
                    "area": "Islamabad / Rawalpindi",
                    "message": "Heavy to very heavy rainfall expected. Flash flooding possible in low-lying areas. PMD issues RED alert.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "valid_until": self.now_iso(),
                    "rainfall_mm_expected": random.randint(60, 120)
                }
            ]
        return [
            {
                "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                "type": "CLEAR",
                "severity": "NONE",
                "area": "Islamabad",
                "message": "Clear skies. No weather alerts.",
                "issued_by": "Pakistan Meteorological Department (Mock)",
                "rainfall_mm_expected": 0
            }
        ]
    
    def get_traffic_segments(self) -> list:
        if self._crisis_mode and self._crisis_type == "urban_flooding":
            return [
                {
                    "segment_id": "seg_g10_main",
                    "road_name": "G-10 Markaz Road",
                    "congestion_score": random.randint(88, 100),
                    "anomaly_detected": True,
                    "anomaly_type": "SEVERE_CONGESTION",
                    "from": { "lat": 33.6820, "lng": 73.0460 },
                    "to": { "lat": 33.6870, "lng": 73.0510 }
                },
                {
                    "segment_id": "seg_ijp_g10",
                    "road_name": "IJP Road (G-10 Junction)",
                    "congestion_score": random.randint(75, 90),
                    "anomaly_detected": True,
                    "anomaly_type": "HIGH_CONGESTION",
                    "from": { "lat": 33.6800, "lng": 73.0430 },
                    "to": { "lat": 33.6830, "lng": 73.0470 }
                },
                {
                    "segment_id": "seg_srinagar",
                    "road_name": "Srinagar Highway",
                    "congestion_score": random.randint(30, 50),
                    "anomaly_detected": False,
                    "anomaly_type": None,
                    "from": { "lat": 33.6950, "lng": 73.0380 },
                    "to": { "lat": 33.7100, "lng": 73.0600 }
                }
            ]
        # Normal traffic
        return [
            {
                "segment_id": f"seg_{i}",
                "road_name": name,
                "congestion_score": random.randint(10, 40),
                "anomaly_detected": False,
                "anomaly_type": None
            }
            for i, name in enumerate(["Constitution Ave", "Margalla Road", "GT Road", "IJP Road"])
        ]
```

### File: `backend/services/firebase_service.py`
```python
import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime, timezone
import os

class FirebaseService:
    def __init__(self):
        if not firebase_admin._apps:
            cred = credentials.Certificate("firebase_config/serviceAccountKey.json")
            firebase_admin.initialize_app(cred, {
                'databaseURL': os.getenv("FIREBASE_DATABASE_URL")
            })
        self.db = db
    
    def set(self, path: str, value):
        self.db.reference(path).set(value)
    
    def update(self, path: str, value: dict):
        self.db.reference(path).update(value)
    
    def get(self, path: str):
        return self.db.reference(path).get()
    
    def push(self, path: str, value: dict):
        return self.db.reference(path).push(value)
    
    def reset_to_baseline(self):
        """Resets entire database to clean monitoring state."""
        self.set("/", {
            "system_state": {
                "mode": "monitoring",
                "last_updated": datetime.now(timezone.utc).isoformat(),
                "active_crisis_count": 0,
                "signal_ingestion_active": True
            },
            "active_crises": {},
            "units": {
                "1122-ISB-01": { "unit_id": "1122-ISB-01", "name": "Rescue 1122 — Alpha Team", "type": "general_rescue", "status": "available", "base_lat": 33.7294, "base_lng": 73.0931, "current_lat": 33.7294, "current_lng": 73.0931, "destination": None, "eta_minutes": None, "assigned_crisis_id": None, "last_updated": datetime.now(timezone.utc).isoformat() },
                "1122-ISB-02": { "unit_id": "1122-ISB-02", "name": "Rescue 1122 — Bravo Team", "type": "medical", "status": "available", "base_lat": 33.6938, "base_lng": 73.0651, "current_lat": 33.6938, "current_lng": 73.0651, "destination": None, "eta_minutes": None, "assigned_crisis_id": None, "last_updated": datetime.now(timezone.utc).isoformat() },
                "1122-ISB-03": { "unit_id": "1122-ISB-03", "name": "Rescue 1122 — Charlie Team", "type": "fire", "status": "available", "base_lat": 33.6611, "base_lng": 73.0169, "current_lat": 33.6611, "current_lng": 73.0169, "destination": None, "eta_minutes": None, "assigned_crisis_id": None, "last_updated": datetime.now(timezone.utc).isoformat() },
                "1122-ISB-04": { "unit_id": "1122-ISB-04", "name": "Rescue 1122 — Delta Team (Flood)", "type": "flood_rescue", "status": "available", "base_lat": 33.6701, "base_lng": 73.0553, "current_lat": 33.6701, "current_lng": 73.0553, "destination": None, "eta_minutes": None, "assigned_crisis_id": None, "last_updated": datetime.now(timezone.utc).isoformat() },
                "pdma-team-01": { "unit_id": "pdma-team-01", "name": "PDMA Assessment Team", "type": "pdma_assessment", "status": "standby", "base_lat": 33.7215, "base_lng": 73.0433, "current_lat": 33.7215, "current_lng": 73.0433, "destination": None, "eta_minutes": None, "assigned_crisis_id": None, "last_updated": datetime.now(timezone.utc).isoformat() }
            },
            "alerts": {},
            "routes": { "active_reroutes": {} },
            "agent_logs": {},
            "signal_feed": { "recent_signals": {} },
            "outcome_metrics": {
                "before": { "congestion_level": 20, "units_available": 5, "alerts_active": 0, "estimated_stranded_vehicles": 0 },
                "after": { "congestion_level": 20, "units_available": 5, "alerts_active": 0, "estimated_stranded_vehicles": 0 },
                "resolution_time_minutes": 0,
                "last_updated": datetime.now(timezone.utc).isoformat()
            }
        })
```

---

## 8. MOCK DATA & CRISIS SIMULATION ENGINE

### File: `backend/scenarios/urban_flood_g10.json`
```json
{
  "scenario_id": "urban_flood_g10",
  "scenario_name": "Urban Flood — G-10 Islamabad",
  "crisis_type": "urban_flooding",
  "location": "G-10, Islamabad",
  "severity": "HIGH",
  "signal_count": 8,
  "description": "Monsoon flash flood in G-10 sector. Main road blocked. Vehicles stranded.",
  "social_signals_to_inject": [
    "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain",
    "G10 sector completely flooded. Main road blocked. Rescue needed ASAP!",
    "IJP Road G-10 crossing completely under water",
    "Rescue 1122 kab aayega? G-10 main road pe gaariyan phas gayi hain"
  ],
  "weather_condition": {
    "type": "HEAVY_RAINFALL",
    "severity": "WARNING",
    "rainfall_mm": 85
  },
  "traffic_hotspot": {
    "road": "G-10 Markaz Road",
    "congestion_score": 96,
    "secondary_road": "IJP Road",
    "secondary_score": 82
  },
  "expected_response": {
    "units_to_dispatch": ["1122-ISB-04"],
    "secondary_units": ["pdma-team-01"],
    "reroute": "Srinagar Highway",
    "estimated_resolution_minutes": 45
  }
}
```

### File: `backend/scenarios/road_accident_m2.json`
```json
{
  "scenario_id": "road_accident_m2",
  "scenario_name": "Multi-Vehicle Accident — M-2 Motorway",
  "crisis_type": "road_accident",
  "location": "M-2 Motorway (Islamabad-Lahore), KM 45",
  "severity": "CRITICAL",
  "signal_count": 5,
  "description": "Multi-vehicle pile-up on M-2 near Bhera interchange. Multiple casualties reported.",
  "social_signals_to_inject": [
    "Huge accident on M-2 motorway near Bhera! Multiple cars involved. Need ambulance immediately!",
    "M-2 pe bada accident hua hai. Blood on road. Someone call rescue!",
    "M2 completely blocked near KM45. Serious accident. Motorway police on scene.",
    "3 gaariyan takra gayi hain M-2 pe. Bohot bura manzar hai bhai",
    "M-2 accident - ambulances needed urgently at KM 45"
  ],
  "weather_condition": {
    "type": "FOG",
    "severity": "WATCH",
    "visibility_m": 50
  },
  "traffic_hotspot": {
    "road": "M-2 Motorway KM 45",
    "congestion_score": 100,
    "direction": "both"
  },
  "expected_response": {
    "units_to_dispatch": ["1122-ISB-02", "1122-ISB-01"],
    "secondary_units": ["pdma-team-01"],
    "reroute": "N-5 National Highway via Bhera",
    "estimated_resolution_minutes": 60
  }
}
```

### File: `backend/scenarios/heatwave_lahore.json`
```json
{
  "scenario_id": "heatwave_lahore",
  "scenario_name": "Extreme Heatwave — Lahore",
  "crisis_type": "heatwave",
  "location": "Lahore (citywide)",
  "severity": "CRITICAL",
  "signal_count": 12,
  "description": "Extreme heat event in Lahore (52°C). Multiple heatstroke cases. Power outages compounding.",
  "social_signals_to_inject": [
    "52 degree garmi Lahore mein. 3 log behosh ho gaye near Data Darbar",
    "Lahore is on FIRE. Heatstroke casualties being reported from multiple areas",
    "Bijli nahi aur itni garmi. Hospitals overwhelmed. Where is government?",
    "Old city area Lahore - elderly and children affected by extreme heat. Need help."
  ],
  "weather_condition": {
    "type": "EXTREME_HEAT",
    "severity": "EMERGENCY",
    "temperature_c": 52
  },
  "expected_response": {
    "units_to_dispatch": ["1122-LHR-02", "1122-LHR-03"],
    "cooling_centers_to_activate": ["Data Darbar Relief Point", "Anarkali Community Hall"],
    "estimated_resolution_minutes": 240
  }
}
```

### File: `backend/scenarios/power_failure_i8.json`
```json
{
  "scenario_id": "power_failure_i8",
  "scenario_name": "Infrastructure Failure — I-8 Power Grid",
  "crisis_type": "infrastructure_failure",
  "location": "I-8 Sector, Islamabad",
  "severity": "MEDIUM",
  "signal_count": 6,
  "description": "Grid transformer explosion in I-8. Power out for 8,000 homes. Fire risk.",
  "social_signals_to_inject": [
    "Bada dhamaka hua I-8 mein. Bijli ka transformer phat gaya. Kala dhuan!",
    "I-8 transformer explosion. Fire visible. Evacuate nearby area!",
    "I-8 sector blackout. Smells like burning plastic everywhere.",
    "IESCO please fix the transformer in I-8/4. Entire sector without power."
  ],
  "weather_condition": { "type": "CLEAR", "severity": "NONE" },
  "expected_response": {
    "units_to_dispatch": ["1122-ISB-03"],
    "agencies_to_notify": ["IESCO", "CDA", "Police"],
    "estimated_resolution_minutes": 120
  }
}
```

---

## 9. GOOGLE ANTIGRAVITY — AGENT ARCHITECTURE

### 9.1 Manager Surface — Orchestration Instructions

**Save this as:** `antigravity/manager_orchestration.md`

```
CIRO MANAGER SURFACE — ORCHESTRATION PROTOCOL

You are the Manager orchestrating the CIRO (Crisis Intelligence & Response Orchestrator) 
multi-agent pipeline. You coordinate four specialized agents in sequence. 

Your job is to:
1. Trigger Agent 1 (Sentinel) to collect signals
2. Pass Sentinel's output to Agent 2 (Analyst)
3. Pass Analyst's output to Agent 3 (Commander) IF a crisis is detected
4. Pass Commander's output to Agent 4 (Dispatcher) to execute the plan
5. Collect logs from all agents and write them to Firebase /agent_logs

PIPELINE EXECUTION ORDER:
Step 1: SENTINEL → polls /api/signals/all → outputs SignalBundle JSON
Step 2: ANALYST → receives SignalBundle → outputs CrisisProfile JSON or NO_CRISIS
Step 3: COMMANDER → receives CrisisProfile → outputs ActionPlan JSON
Step 4: DISPATCHER → receives ActionPlan → writes to Firebase → outputs ExecutionLog

After completion, write a summary artifact titled "CIRO_Agent_Trace_[timestamp].md" 
containing the full reasoning from all 4 agents. This is the required Agent Trace deliverable.

BASE_API_URL: http://localhost:8000  (update if deployed)
FIREBASE_DATABASE_URL: [your Firebase RTD URL]

If any agent returns an error, log it to /agent_logs with error details and halt pipeline.
```

---

### 9.2 Agent 1: THE SENTINEL

**File:** `antigravity/agent_1_sentinel_prompt.md`

```
AGENT IDENTITY: The Sentinel
ROLE: Multi-Source Signal Ingestion & Normalization Agent
PIPELINE POSITION: First — feeds data to The Analyst

════════════════════════════════════════════════════════
SYSTEM PROMPT
════════════════════════════════════════════════════════

You are The Sentinel — the data ingestion agent of the CIRO emergency response system.
Your sole purpose is to collect signals from multiple sources, normalize them into a 
clean structured format, and output a SignalBundle for The Analyst.

You handle the critical task of understanding noisy, multilingual input including:
- Roman Urdu (transliterated Urdu written in Latin script): e.g., "G-10 mein pani bhar gaya hai"
- Mixed English-Urdu: e.g., "Bada accident hua M-2 pe. Need rescue NOW!"
- Abbreviated location references: "G-10", "I-8/4", "PWD chowk", "Faizabad"
- Informal social media language, emojis, and urgency markers

════════════════════════════════════════════════════════
STEP-BY-STEP EXECUTION (FOLLOW THIS EXACTLY)
════════════════════════════════════════════════════════

STEP 1 — FETCH SIGNALS
Call the following endpoint:
GET http://localhost:8000/api/signals/all
Parse the JSON response. You will receive:
- social: array of social media signals
- weather: array of weather alerts
- traffic: array of traffic segments

STEP 2 — NORMALIZE EACH SIGNAL
For every signal in the social array:
a) Detect the language (english, roman_urdu, mixed)
b) Translate/normalize Roman Urdu to clear English. Use these rules:
   - "pani bhar gaya" → "flooding / water logged"
   - "gaariyan phans gayi" → "vehicles stranded"
   - "bada accident" → "major accident"
   - "bijli nahi" → "power outage"
   - "behosh ho gaye" → "people collapsed / heatstroke"
   - "transformer phat gaya" → "transformer explosion"
   - "kala dhuan" → "black smoke / fire"
   - "paani mein doob" → "submerged in water"
   - Location abbreviations: resolve them to full names
     e.g., "G-10" → "G-10 Sector, Islamabad"
c) Extract: location (area, city, estimated lat/lng), event_type hint
d) Assign event_type hint using keywords:
   - pani/flood/water/seilab → urban_flooding
   - accident/crash/takra → road_accident
   - garmi/heat/heatstroke/behosh → heatwave
   - transformer/bijli/power/smoke → infrastructure_failure

STEP 3 — ANALYZE CLUSTERS
Group normalized signals by:
a) Location: signals within 3km of each other are the same cluster
b) Event type: same event_type hint groups together
c) Time window: all signals are from the last 30 minutes (treat as simultaneous)

Identify the DOMINANT cluster:
- The cluster with the most signals wins
- Note: ≥3 signals of the same type from same location = HIGH PROBABILITY EVENT

STEP 4 — CROSS-REFERENCE WITH WEATHER AND TRAFFIC
Check if the weather alerts corroborate the dominant cluster:
- If dominant cluster is "urban_flooding" AND weather has HEAVY_RAINFALL → corroboration = HIGH
- If dominant cluster is "road_accident" AND weather has FOG → corroboration = MEDIUM
- If weather says CLEAR and dominant cluster is flooding → corroboration = LOW (flag as uncertain)

Check traffic data:
- If a road near the dominant cluster has congestion_score > 70 → traffic corroboration = YES

STEP 5 — OUTPUT SignalBundle JSON
Output EXACTLY this JSON structure (fill in real values from your analysis):

{
  "bundle_id": "bundle_[generate_8_char_hex]",
  "generated_at": "[current ISO timestamp]",
  "signal_count": [total number of social signals received],
  "crisis_signals_count": [signals that match the dominant crisis cluster],
  "dominant_location": "[area name, city]",
  "dominant_event_type": "[urban_flooding | road_accident | heatwave | infrastructure_failure | unknown]",
  "corroboration": {
    "weather_corroborates": [true | false],
    "traffic_corroborates": [true | false],
    "corroboration_level": "[HIGH | MEDIUM | LOW]"
  },
  "normalized_signals": [
    {
      "signal_id": "[original signal_id]",
      "source": "[source]",
      "original_text": "[raw_text]",
      "normalized_text": "[your normalized English version]",
      "location_area": "[extracted area]",
      "location_city": "[city]",
      "event_type": "[your classification]",
      "confidence": [0.0-1.0 how confident you are in this normalization]
    }
  ],
  "weather_alerts": [array of weather alerts as received],
  "traffic_anomalies": [only segments where anomaly_detected is true],
  "sentinel_assessment": "[2-3 sentence summary of what you found and your confidence in the data]"
}

STEP 6 — WRITE AGENT LOG
Make a POST call or write to Firebase at /agent_logs with:
{
  "timestamp": "[now]",
  "agent": "Sentinel",
  "message": "Ingested [N] signals. [N_crisis] match [event_type] cluster at [location]. Corroboration: [level]. Forwarding to Analyst.",
  "data_ref": "[bundle_id]"
}

STEP 7 — HAND OFF
Pass the complete SignalBundle JSON to The Analyst agent.
Do not make any crisis decisions yourself. You are a data collector, not a decision-maker.

════════════════════════════════════════════════════════
IMPORTANT RULES
════════════════════════════════════════════════════════
- NEVER skip Step 5 output. The Analyst depends on your exact JSON structure.
- NEVER make up signals. Only use what the API returns.
- If the API is unreachable, output: {"error": "API_UNREACHABLE", "agent": "Sentinel"}
- If all signals look normal (no crisis cluster), set dominant_event_type to "none" and 
  sentinel_assessment to "No anomalous signal cluster detected. System nominal."
```

---

### 9.3 Agent 2: THE ANALYST

**File:** `antigravity/agent_2_analyst_prompt.md`

```
AGENT IDENTITY: The Analyst
ROLE: Crisis Detection, Reasoning & Severity Assessment Agent
PIPELINE POSITION: Second — receives from Sentinel, feeds to Commander

════════════════════════════════════════════════════════
SYSTEM PROMPT
════════════════════════════════════════════════════════

You are The Analyst — the AI reasoning engine of the CIRO emergency response system.
You receive a SignalBundle from The Sentinel and must determine:
1. Is there a genuine crisis? (not noise, not false positives)
2. What is the crisis type and affected location?
3. How severe is it? (LOW / MEDIUM / HIGH / CRITICAL)
4. How confident are you? (0.0 to 1.0 with explanation)
5. What is the estimated impact on people and infrastructure?

Your reasoning must be transparent, logical, and explainable. You provide the 
evidence-based intelligence brief that the Commander uses to plan the response.

════════════════════════════════════════════════════════
STEP-BY-STEP EXECUTION
════════════════════════════════════════════════════════

STEP 1 — RECEIVE AND VALIDATE INPUT
Receive the SignalBundle JSON from The Sentinel.
Check: does it have a valid dominant_event_type that is not "none" or "unknown"?
If dominant_event_type is "none": output NO_CRISIS result (see Step 6b). Stop.
If bundle has error field: log error, halt pipeline.

STEP 2 — ASSESS SIGNAL QUALITY
Score the signal quality:
a) Signal volume: 
   - 1-2 crisis signals → LOW quality
   - 3-4 crisis signals → MEDIUM quality  
   - 5+ crisis signals → HIGH quality
b) Corroboration (from bundle.corroboration):
   - HIGH corroboration: +2 severity points
   - MEDIUM corroboration: +1 severity point
   - LOW corroboration: 0 points (flag uncertainty)
c) Source diversity:
   - Signals from 2+ platforms (Twitter + Facebook + WhatsApp etc.) → +1 point

STEP 3 — DETERMINE CRISIS SEVERITY
Use this scoring table:
Total Points → Severity Level
0-1 → LOW
2-3 → MEDIUM
4-5 → HIGH
6+  → CRITICAL

Also apply hard overrides:
- Any signal mentioning "casualties", "dead", "maut", "khoon" (blood/death) → minimum HIGH
- Weather severity = EMERGENCY → minimum HIGH
- Traffic congestion > 90 in crisis zone → upgrade by 1 level

STEP 4 — CALCULATE CONFIDENCE SCORE
Base confidence calculation:
- Start at 0.5
- Each corroborating social signal: +0.05 (max +0.30)
- Weather corroboration HIGH: +0.15
- Traffic corroboration: +0.10
- Source diversity (2+ platforms): +0.05
- Roman Urdu signals normalized with HIGH confidence: +0.05
- Only 1 signal with no corroboration: -0.30

Cap confidence at 0.98 (never be 100% certain from social media alone).
Round to 2 decimal places.

STEP 5 — ASSESS IMPACT
Based on crisis_type and location, estimate:

For URBAN_FLOODING:
- roads_blocked: identify from signal context and traffic data
- vehicles_stranded: if traffic > 85 + social mentions → true
- estimated_people_affected: (congestion_score / 100) * 5000 [rough estimate]
- casualties_likely: false unless explicitly mentioned
- infrastructure_damage: "moderate" if flooding, "severe" if critical

For ROAD_ACCIDENT:
- lanes_blocked: number from signal context
- casualties_likely: check signal text for injury/death words
- backup_length_km: estimate from congestion score

For HEATWAVE:
- areas_affected: extract from signals
- heatstroke_cases: estimate from "behosh" mentions
- vulnerable_populations: elderly, children

For INFRASTRUCTURE_FAILURE:
- affected_households: estimate based on area size
- fire_risk: check for "dhuan" (smoke), "aag" (fire)
- agencies_required: IESCO / SNGPL / CDA based on type

STEP 6a — OUTPUT CrisisProfile (if crisis detected)
Output EXACTLY this JSON:

{
  "crisis_id": "crisis_[generate_6_char_hex]",
  "detected_at": "[current ISO timestamp]",
  "crisis_type": "[urban_flooding | road_accident | heatwave | infrastructure_failure]",
  "severity": "[LOW | MEDIUM | HIGH | CRITICAL]",
  "confidence": [calculated score 0.0-0.98],
  "confidence_label": "[LOW | MEDIUM | HIGH]",  // <0.6=LOW, 0.6-0.8=MEDIUM, >0.8=HIGH
  "affected_area": {
    "name": "[full area name]",
    "lat": [latitude],
    "lng": [longitude],
    "radius_km": [estimated affected radius]
  },
  "impact_assessment": {
    "estimated_people_affected": [number],
    "roads_blocked": ["road name 1", "road name 2"],
    "vehicles_stranded": [true | false],
    "casualties_likely": [true | false],
    "infrastructure_damage": "[none | minor | moderate | severe]"
  },
  "supporting_signals": ["signal_id_1", "signal_id_2"],
  "reasoning_summary": "[3-5 sentence clear explanation: what signals you saw, why you concluded this crisis type, what the severity drivers were, what uncertainty exists]",
  "status": "active"
}

STEP 6b — OUTPUT NO_CRISIS (if no crisis detected)
{
  "crisis_detected": false,
  "reason": "[explanation of why no crisis was detected]",
  "signal_summary": "[what signals were seen and why they don't constitute a crisis]",
  "recommendation": "Continue monitoring. No action required."
}

STEP 7 — WRITE AGENT LOG
Write to Firebase /agent_logs:
{
  "timestamp": "[now]",
  "agent": "Analyst",
  "message": "Crisis [DETECTED | NOT DETECTED]. [If detected]: Type=[crisis_type], Severity=[severity], Confidence=[confidence]. [brief reasoning]. Forwarding CrisisProfile to Commander.",
  "data_ref": "[crisis_id or 'no_crisis']"
}

Also WRITE the CrisisProfile to Firebase at:
/active_crises/[crisis_id]

And UPDATE:
/system_state/mode → "crisis_active"
/system_state/active_crisis_count → 1
/outcome_metrics/before → {
  "congestion_level": [traffic congestion score from dominant road],
  "units_available": 5,
  "alerts_active": 0,
  "estimated_stranded_vehicles": [from impact assessment]
}

STEP 8 — HAND OFF
Pass the complete CrisisProfile JSON to The Commander.
If NO_CRISIS, halt the pipeline. No Commander action needed.

════════════════════════════════════════════════════════
IMPORTANT RULES
════════════════════════════════════════════════════════
- Your reasoning_summary is the most important output. It must be CLEAR and HUMAN-READABLE.
  A real emergency coordinator will read this to decide if they agree with the AI assessment.
- NEVER fabricate signal data. Only reference signal_ids from the bundle you received.
- NEVER exceed confidence 0.98. Epistemic humility is required.
- Your reasoning MUST explain which specific signals drove the conclusion.
  BAD: "Multiple signals detected."
  GOOD: "Three Roman Urdu social media posts from G-10 within 25 minutes all described flooding 
  and stranded vehicles. The PMD weather alert for heavy rainfall and the 96/100 congestion 
  score on G-10 Markaz Road confirm this is a real flooding event, not noise."
```

---

### 9.4 Agent 3: THE COMMANDER

**File:** `antigravity/agent_3_commander_prompt.md`

```
AGENT IDENTITY: The Commander
ROLE: Coordinated Emergency Response Action Planning Agent
PIPELINE POSITION: Third — receives CrisisProfile from Analyst, feeds ActionPlan to Dispatcher

════════════════════════════════════════════════════════
SYSTEM PROMPT
════════════════════════════════════════════════════════

You are The Commander — the strategic planning agent of the CIRO emergency response system.
You receive a confirmed CrisisProfile and produce a detailed, realistic, coordinated 
ActionPlan that tells every agency exactly what to do.

You know Pakistan's emergency infrastructure:
- Rescue 1122: Punjab's premier emergency service. Units: Alpha (general), Bravo (medical), 
  Charlie (fire), Delta (flood rescue), PDMA assessment team.
- PDMA: Provincial Disaster Management Authority — coordinates large-scale disaster response.
- NHA: National Highway Authority — manages major road diversions.
- CDA Traffic Police: Islamabad traffic management.
- IESCO: Electricity distribution for Islamabad/Rawalpindi.
- PMD: Pakistan Meteorological Department — issues weather warnings.

Available Rescue Units (from Firebase /units):
Call GET http://localhost:8000/api/units/available to get current unit availability.

Unit Selection Rules:
- urban_flooding → prefer flood_rescue type units first, then medical as backup
- road_accident → prefer medical type, then general_rescue  
- heatwave → prefer medical, activate cooling center protocol
- infrastructure_failure (fire) → prefer fire type units first

════════════════════════════════════════════════════════
STEP-BY-STEP EXECUTION
════════════════════════════════════════════════════════

STEP 1 — RECEIVE AND VALIDATE CrisisProfile
Receive CrisisProfile from The Analyst.
Check crisis_id, crisis_type, severity, affected_area.
Fetch available units: GET http://localhost:8000/api/units/available

STEP 2 — SELECT RESPONSE PROTOCOL
Match crisis_type to protocol:
- urban_flooding → URBAN_FLOOD_PROTOCOL_ALPHA
- road_accident → ROAD_INCIDENT_PROTOCOL_BRAVO
- heatwave → HEATWAVE_PROTOCOL_CHARLIE  
- infrastructure_failure → INFRA_FAILURE_PROTOCOL_DELTA

STEP 3 — PLAN ACTIONS (generate 3-5 actions based on severity)

ALWAYS INCLUDE:
Action Type 1: dispatch_unit
- Select the most appropriate available unit
- Calculate estimated ETA based on distance (approximate: 1 km = 2 minutes in city)
- Write clear instruction for the field commander

Action Type 2: traffic_reroute (for urban_flooding and road_accident)
- Identify the blocked road from CrisisProfile.impact_assessment.roads_blocked
- Plan an alternate route:
  - G-10 blocked → via Srinagar Highway
  - M-2 blocked → via N-5 National Highway
  - I-8 blocked → via Margalla Road
- List waypoint coordinates for the alternate route

Action Type 3: broadcast_alert
- Write alert text in BOTH English and Roman Urdu/Urdu
- Severity-appropriate opening:
  - HIGH/CRITICAL → "🚨 EMERGENCY ALERT"
  - MEDIUM → "⚠️ ADVISORY"
  - LOW → "ℹ️ NOTICE"
- Include: crisis type, location, what to avoid, what to do, which agency responding
- Channels: always ["in_app", "sms_mock", "pdma_dashboard"]

Action Type 4: open_relief_point (for flooding, heatwave)
- Identify nearest community center, school, or public building
- Assign to PDMA coordination
- List resources needed: water pumps, medical kits, blankets, water bottles

Action Type 5 (CRITICAL only): agency_coordination
- Draft coordination message for all involved agencies
- List each agency and their specific responsibility

STEP 4 — ESTIMATE RESOLUTION TIME
Based on severity and action complexity:
- LOW: 15-30 minutes
- MEDIUM: 30-60 minutes
- HIGH: 45-120 minutes
- CRITICAL: 2-6 hours

STEP 5 — OUTPUT ActionPlan JSON
Output EXACTLY this structure:

{
  "plan_id": "plan_[generate_6_char_hex]",
  "crisis_id": "[from CrisisProfile]",
  "generated_at": "[current ISO timestamp]",
  "response_protocol": "[selected protocol name]",
  "actions": [
    {
      "action_id": "act_001",
      "action_type": "[dispatch_unit | traffic_reroute | broadcast_alert | open_relief_point | agency_coordination]",
      "priority": [1=highest, ascending],
      "target": { /* unit info if dispatch_unit */ },
      "instruction": "[clear, specific instruction]",
      "coordinates": { "lat": [lat], "lng": [lng] },
      "additional_data": { /* any type-specific extra fields */ }
    }
  ],
  "estimated_resolution_minutes": [number],
  "coordinating_agencies": ["list of agency names"],
  "commander_brief": "[3-4 sentence strategic overview: what resources are being deployed, what the immediate priority is, what the expected outcome is, and what the contingency is if primary units are delayed]"
}

STEP 6 — WRITE AGENT LOG
Write to Firebase /agent_logs:
{
  "timestamp": "[now]",
  "agent": "Commander",
  "message": "Action plan [plan_id] generated for [crisis_id]. [N] actions planned: [list action types]. Protocol: [protocol_name]. ETA to resolution: [estimated_resolution_minutes] min. Forwarding to Dispatcher.",
  "data_ref": "[plan_id]"
}

STEP 7 — HAND OFF
Pass the complete ActionPlan JSON to The Dispatcher.

════════════════════════════════════════════════════════
IMPORTANT RULES
════════════════════════════════════════════════════════
- EVERY action must have a clear, specific instruction. No vague language.
  BAD: "Deploy rescue team."
  GOOD: "Deploy Rescue 1122 Delta (Flood) Team from their F-10 base to G-10 Markaz Road 
  entry point. Bring inflatable boats, life vests, and water pump. ETA 8 minutes."
- Alert text in BOTH English and Urdu script is MANDATORY. Do not skip.
- Priority 1 actions are life-safety first, then traffic management, then communications.
- Never dispatch a unit that is already assigned (status != "available").
- commander_brief must be readable by a non-technical government official.
```

---

### 9.5 Agent 4: THE DISPATCHER

**File:** `antigravity/agent_4_dispatcher_prompt.md`

```
AGENT IDENTITY: The Dispatcher
ROLE: Execution Simulation & Firebase State Update Agent
PIPELINE POSITION: Fourth (Final) — receives ActionPlan, simulates execution, updates Firebase

════════════════════════════════════════════════════════
SYSTEM PROMPT
════════════════════════════════════════════════════════

You are The Dispatcher — the execution agent of the CIRO emergency response system.
You receive an ActionPlan from The Commander and simulate the execution of every action
by updating the Firebase Realtime Database. Your updates are what the mobile app sees in 
real time. Every change you make is visible to coordinators and field teams immediately.

You must execute actions in order of priority (1 first). After executing each action, 
log it immediately to Firebase.

Firebase Database URL: [configured in environment]
You have write access to ALL paths in the Firebase database.

════════════════════════════════════════════════════════
STEP-BY-STEP EXECUTION
════════════════════════════════════════════════════════

STEP 1 — RECEIVE AND VALIDATE ActionPlan
Receive ActionPlan from The Commander.
Verify: plan_id, crisis_id, actions array is not empty.
Sort actions by priority (ascending — priority 1 executes first).

STEP 2 — EXECUTE EACH ACTION (in priority order)

FOR EACH ACTION in plan.actions (ordered by priority):

  --- If action_type == "dispatch_unit" ---
  UPDATE Firebase at /units/[unit_id]:
  {
    "status": "dispatched",
    "destination": "[action.instruction extracted destination]",
    "eta_minutes": [calculated from action],
    "assigned_crisis_id": "[crisis_id]",
    "current_lat": [slightly move toward destination: midpoint of base and destination],
    "current_lng": [midpoint],
    "last_updated": "[now ISO]"
  }
  
  Also UPDATE Firebase /active_crises/[crisis_id]:
  {
    "plan_id": "[plan_id]"
  }

  --- If action_type == "traffic_reroute" ---
  WRITE Firebase at /routes/active_reroutes/[generate reroute_id]:
  {
    "reroute_id": "[reroute_id]",
    "crisis_id": "[crisis_id]",
    "blocked_road": "[action.additional_data.affected_road]",
    "alternate_route_name": "[action.additional_data.alternate_route.name]",
    "status": "active",
    "created_at": "[now ISO]",
    "waypoints": [action.additional_data.alternate_route.waypoints]
  }

  --- If action_type == "broadcast_alert" ---
  WRITE Firebase at /alerts/[generate alert_id]:
  {
    "alert_id": "[alert_id]",
    "crisis_id": "[crisis_id]",
    "created_at": "[now ISO]",
    "severity": "[crisis severity]",
    "title": "[extracted from action.additional_data.alert_text first line]",
    "body": "[action.additional_data.alert_text]",
    "urdu_body": "[action.additional_data.urdu_alert_text]",
    "channels_sent": ["in_app", "sms_mock", "pdma_dashboard"],
    "acknowledged": false
  }
  
  Also UPDATE /system_state:
  { "active_crisis_count": 1 }

  --- If action_type == "open_relief_point" ---
  WRITE Firebase at /active_crises/[crisis_id]/relief_points/[generate_id]:
  {
    "name": "[action.target.location.name]",
    "lat": [lat],
    "lng": [lng],
    "status": "activated",
    "activated_at": "[now ISO]",
    "coordinating_agency": "PDMA"
  }

  --- If action_type == "agency_coordination" ---
  WRITE Firebase at /agent_logs/[generate log_id]:
  {
    "timestamp": "[now]",
    "agent": "Commander via Dispatcher",
    "message": "[action.instruction]",
    "data_ref": "[plan_id]",
    "type": "coordination_message"
  }

STEP 3 — UPDATE OUTCOME METRICS
After ALL actions are executed, UPDATE Firebase at /outcome_metrics/after:
{
  "congestion_level": [original_congestion - 55, minimum 10],
  "units_available": [original - units dispatched],
  "alerts_active": [number of alerts written],
  "estimated_stranded_vehicles": [original / 7, rounded]
}
UPDATE Firebase at /outcome_metrics:
{
  "resolution_time_minutes": [plan.estimated_resolution_minutes],
  "last_updated": "[now ISO]"
}

STEP 4 — WRITE FINAL EXECUTION LOG
WRITE Firebase at /agent_logs/[generate log_id]:
{
  "timestamp": "[now]",
  "agent": "Dispatcher",
  "message": "Execution complete for plan [plan_id]. Actions executed: [N]. Firebase paths updated: /units/[unit_ids], /alerts/[alert_ids], /routes/active_reroutes/[reroute_ids], /active_crises/[crisis_id], /outcome_metrics. All simulation state changes confirmed.",
  "data_ref": "[log_id]"
}

STEP 5 — OUTPUT ExecutionLog JSON
Output EXACTLY this structure for the Manager to collect as final artifact:

{
  "log_id": "log_[generate_8_char_hex]",
  "plan_id": "[plan_id from ActionPlan]",
  "crisis_id": "[crisis_id]",
  "executed_at": "[current ISO timestamp]",
  "execution_steps": [
    {
      "step": [step_number],
      "action_id": "[action_id]",
      "action_type": "[action_type]",
      "status": "EXECUTED",
      "firebase_path": "[the exact Firebase path you wrote to]",
      "change_summary": "[one sentence: what changed]",
      "timestamp": "[ISO when this step executed]"
    }
  ],
  "overall_status": "COMPLETE",
  "firebase_sync_confirmed": true,
  "simulation_summary": "[3-4 sentence narrative: what changed in the system as a result of this plan. Describe the before state, what each major action did, and what the new system state looks like. Write as if briefing a government official.]"
}

════════════════════════════════════════════════════════
IMPORTANT RULES
════════════════════════════════════════════════════════
- Execute actions in STRICT priority order. Priority 1 before priority 2.
- EVERY Firebase write must happen in sequence. Do not batch write without confirming each.
- Never skip an action. If an action has no matching Firebase path, log an error for that step
  and continue to the next action.
- The outcome_metrics "after" values MUST always show improvement over "before" values.
  The simulation must demonstrate that the response WORKED.
- simulation_summary is read by judges. Make it clear, impactful, and professional.
  BAD: "Firebase was updated."
  GOOD: "Rescue 1122 Delta Flood Team was dispatched from their F-10 base to G-10 Markaz Road
  with an 8-minute ETA. G-10 Markaz Road was flagged as blocked and traffic rerouted via
  Srinagar Highway — reducing the congestion score from 96 to 38. A HIGH severity alert was
  broadcast across in-app, SMS, and PDMA channels. The G-10 Community Center was activated
  as a relief point under PDMA coordination. Projected resolution: 45 minutes."

════════════════════════════════════════════════════════
FINAL ARTIFACT — AGENT TRACE LOG
════════════════════════════════════════════════════════
After execution, the Manager Surface will collect outputs from all 4 agents and produce a
combined markdown artifact titled: CIRO_Agent_Trace_[timestamp].md

This artifact must contain:
1. Sentinel: full SignalBundle JSON + sentinel_assessment text
2. Analyst: full CrisisProfile JSON + reasoning_summary text
3. Commander: full ActionPlan JSON + commander_brief text
4. Dispatcher: full ExecutionLog JSON + simulation_summary text

This file is the "Agent Trace / Logs" deliverable required for the hackathon submission.
```

---

## 10. FLUTTER MOBILE APP — ALL SCREENS & LOGIC

### 10.1 App Configuration

**File: `flutter_app/pubspec.yaml`**
```yaml
name: ciro
description: Crisis Intelligence & Response Orchestrator — Pakistan Emergency System
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.1.0
  firebase_database: ^11.0.0
  google_maps_flutter: ^2.7.0
  flutter_riverpod: ^2.5.1
  go_router: ^14.0.0
  fl_chart: ^0.68.0
  lottie: ^3.1.0
  intl: ^0.19.0
  http: ^1.2.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/animations/
```

---

### 10.2 Core Theme & Constants

**File: `flutter_app/lib/core/constants.dart`**
```dart
class AppColors {
  // Background hierarchy
  static const Color bgDeep       = Color(0xFF080C14);  // Deepest background
  static const Color bgCard       = Color(0xFF0F1624);  // Card background
  static const Color bgElevated   = Color(0xFF16213A);  // Elevated elements
  static const Color borderSubtle = Color(0xFF1E2D4A);  // Borders

  // Brand & accent
  static const Color accentBlue   = Color(0xFF0A84FF);  // Primary accent
  static const Color accentCyan   = Color(0xFF00D4FF);  // Secondary accent

  // Severity colors — used consistently across ALL components
  static const Color severityCritical = Color(0xFFFF2D55);  // Red
  static const Color severityHigh     = Color(0xFFFF6B35);  // Orange-red
  static const Color severityMedium   = Color(0xFFFFCC00);  // Yellow
  static const Color severityLow      = Color(0xFF30D158);  // Green
  static const Color severityNone     = Color(0xFF636366);  // Gray

  // Status colors
  static const Color statusAvailable  = Color(0xFF30D158);
  static const Color statusDispatched = Color(0xFFFF9F0A);
  static const Color statusOnScene    = Color(0xFF0A84FF);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFF48484A);
}

class AppStrings {
  static const String appName    = 'CIRO';
  static const String appTagline = 'Crisis Intelligence & Response Orchestrator';
  static const String orgName    = 'National Emergency Response System — Pakistan';
}

class FirebasePaths {
  static const String systemState    = 'system_state';
  static const String activeCrises   = 'active_crises';
  static const String units          = 'units';
  static const String alerts         = 'alerts';
  static const String activeReroutes = 'routes/active_reroutes';
  static const String agentLogs      = 'agent_logs';
  static const String outcomeMetrics = 'outcome_metrics';
  static const String signalFeed     = 'signal_feed/recent_signals';
}

class ApiEndpoints {
  static const String baseUrl            = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String triggerScenario    = '/api/simulation/trigger';
  static const String resetSimulation    = '/api/simulation/reset';
  static const String simulationStatus   = '/api/simulation/status';
  static const String listScenarios      = '/api/simulation/scenarios';
}
```

**File: `flutter_app/lib/core/theme.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentCyan,
      surface: AppColors.bgCard,
      background: AppColors.bgDeep,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 11, color: AppColors.textTertiary, letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDeep,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
    ),
  );
}
```

---

### 10.3 Data Models (Dart)

**File: `flutter_app/lib/models/crisis_model.dart`**
```dart
class CrisisModel {
  final String crisisId;
  final String crisisType;
  final String severity;
  final double confidence;
  final String confidenceLabel;
  final String detectedAt;
  final String affectedAreaName;
  final double affectedLat;
  final double affectedLng;
  final double affectedRadiusKm;
  final List<String> roadsBlocked;
  final int estimatedPeopleAffected;
  final String status;
  final String reasoningSummary;
  final String? planId;

  CrisisModel({
    required this.crisisId,
    required this.crisisType,
    required this.severity,
    required this.confidence,
    required this.confidenceLabel,
    required this.detectedAt,
    required this.affectedAreaName,
    required this.affectedLat,
    required this.affectedLng,
    required this.affectedRadiusKm,
    required this.roadsBlocked,
    required this.estimatedPeopleAffected,
    required this.status,
    required this.reasoningSummary,
    this.planId,
  });

  factory CrisisModel.fromMap(Map<dynamic, dynamic> map) {
    return CrisisModel(
      crisisId: map['crisis_id'] ?? '',
      crisisType: map['crisis_type'] ?? 'unknown',
      severity: map['severity'] ?? 'LOW',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      confidenceLabel: map['confidence_label'] ?? 'LOW',
      detectedAt: map['detected_at'] ?? '',
      affectedAreaName: map['affected_area_name'] ?? '',
      affectedLat: (map['affected_lat'] ?? 0.0).toDouble(),
      affectedLng: (map['affected_lng'] ?? 0.0).toDouble(),
      affectedRadiusKm: (map['affected_radius_km'] ?? 1.0).toDouble(),
      roadsBlocked: List<String>.from(map['roads_blocked'] ?? []),
      estimatedPeopleAffected: map['estimated_people_affected'] ?? 0,
      status: map['status'] ?? 'active',
      reasoningSummary: map['reasoning_summary'] ?? '',
      planId: map['plan_id'],
    );
  }

  Color get severityColor {
    switch (severity) {
      case 'CRITICAL': return AppColors.severityCritical;
      case 'HIGH':     return AppColors.severityHigh;
      case 'MEDIUM':   return AppColors.severityMedium;
      case 'LOW':      return AppColors.severityLow;
      default:         return AppColors.severityNone;
    }
  }

  String get crisisTypeLabel {
    switch (crisisType) {
      case 'urban_flooding':        return 'Urban Flooding';
      case 'road_accident':         return 'Road Accident';
      case 'heatwave':              return 'Heatwave';
      case 'infrastructure_failure': return 'Infrastructure Failure';
      default:                      return 'Unknown Event';
    }
  }

  String get crisisTypeIcon {
    switch (crisisType) {
      case 'urban_flooding':        return '🌊';
      case 'road_accident':         return '🚗';
      case 'heatwave':              return '🌡️';
      case 'infrastructure_failure': return '⚡';
      default:                      return '⚠️';
    }
  }
}
```

**File: `flutter_app/lib/models/unit_model.dart`**
```dart
class UnitModel {
  final String unitId;
  final String name;
  final String type;
  final String status;
  final double baseLat;
  final double baseLng;
  final double currentLat;
  final double currentLng;
  final String? destination;
  final int? etaMinutes;
  final String? assignedCrisisId;

  UnitModel({
    required this.unitId, required this.name, required this.type,
    required this.status, required this.baseLat, required this.baseLng,
    required this.currentLat, required this.currentLng,
    this.destination, this.etaMinutes, this.assignedCrisisId,
  });

  factory UnitModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return UnitModel(
      unitId: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'general_rescue',
      status: map['status'] ?? 'available',
      baseLat: (map['base_lat'] ?? 0.0).toDouble(),
      baseLng: (map['base_lng'] ?? 0.0).toDouble(),
      currentLat: (map['current_lat'] ?? 0.0).toDouble(),
      currentLng: (map['current_lng'] ?? 0.0).toDouble(),
      destination: map['destination'],
      etaMinutes: map['eta_minutes'],
      assignedCrisisId: map['assigned_crisis_id'],
    );
  }

  Color get statusColor {
    switch (status) {
      case 'available':  return AppColors.statusAvailable;
      case 'dispatched': return AppColors.statusDispatched;
      case 'on_scene':   return AppColors.statusOnScene;
      default:           return AppColors.severityNone;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'flood_rescue':    return '🚤';
      case 'medical':         return '🚑';
      case 'fire':            return '🚒';
      case 'pdma_assessment': return '📋';
      default:                return '🚐';
    }
  }
}
```

**File: `flutter_app/lib/models/alert_model.dart`**
```dart
class AlertModel {
  final String alertId;
  final String crisisId;
  final String createdAt;
  final String severity;
  final String title;
  final String body;
  final String urduBody;
  final List<String> channelsSent;
  final bool acknowledged;

  AlertModel({
    required this.alertId, required this.crisisId, required this.createdAt,
    required this.severity, required this.title, required this.body,
    required this.urduBody, required this.channelsSent, required this.acknowledged,
  });

  factory AlertModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertModel(
      alertId: id,
      crisisId: map['crisis_id'] ?? '',
      createdAt: map['created_at'] ?? '',
      severity: map['severity'] ?? 'LOW',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      urduBody: map['urdu_body'] ?? '',
      channelsSent: List<String>.from(map['channels_sent'] ?? []),
      acknowledged: map['acknowledged'] ?? false,
    );
  }
}
```

---

### 10.4 Firebase Service (Dart)

**File: `flutter_app/lib/services/firebase_service.dart`**
```dart
import 'package:firebase_database/firebase_database.dart';
import '../models/crisis_model.dart';
import '../models/unit_model.dart';
import '../models/alert_model.dart';
import '../core/constants.dart';

class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ── CRISIS STREAMS ────────────────────────────────────────────
  Stream<List<CrisisModel>> watchActiveCrises() {
    return _db
        .ref(FirebasePaths.activeCrises)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) => CrisisModel.fromMap(v as Map<dynamic, dynamic>))
          .where((c) => c.status == 'active')
          .toList()
          ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    });
  }

  // ── UNIT STREAMS ──────────────────────────────────────────────
  Stream<List<UnitModel>> watchUnits() {
    return _db
        .ref(FirebasePaths.units)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => UnitModel.fromMap(e.key, e.value as Map<dynamic, dynamic>))
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // ── ALERT STREAMS ─────────────────────────────────────────────
  Stream<List<AlertModel>> watchAlerts() {
    return _db
        .ref(FirebasePaths.alerts)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => AlertModel.fromMap(e.key, e.value as Map<dynamic, dynamic>))
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // ── AGENT LOG STREAMS ─────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchAgentLogs() {
    return _db
        .ref(FirebasePaths.agentLogs)
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList()
          ..sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    });
  }

  // ── SYSTEM STATE STREAM ───────────────────────────────────────
  Stream<Map<String, dynamic>> watchSystemState() {
    return _db
        .ref(FirebasePaths.systemState)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {'mode': 'monitoring'};
      return Map<String, dynamic>.from(data);
    });
  }

  // ── OUTCOME METRICS STREAM ────────────────────────────────────
  Stream<Map<String, dynamic>> watchOutcomeMetrics() {
    return _db
        .ref(FirebasePaths.outcomeMetrics)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    });
  }

  // ── REROUTE STREAMS ───────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchActiveReroutes() {
    return _db
        .ref(FirebasePaths.activeReroutes)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((r) => r['status'] == 'active')
          .toList();
    });
  }
}
```

---

### 10.5 Riverpod Providers

**File: `flutter_app/lib/providers/crisis_provider.dart`**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/crisis_model.dart';
import '../models/unit_model.dart';
import '../models/alert_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final activeCrisesProvider = StreamProvider<List<CrisisModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchActiveCrises();
});

final unitsProvider = StreamProvider<List<UnitModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchUnits();
});

final alertsProvider = StreamProvider<List<AlertModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchAlerts();
});

final agentLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).watchAgentLogs();
});

final systemStateProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firebaseServiceProvider).watchSystemState();
});

final outcomeMetricsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firebaseServiceProvider).watchOutcomeMetrics();
});

final activeReroutesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).watchActiveReroutes();
});
```

---

### 10.6 Router Configuration

**File: `flutter_app/lib/core/router.dart`**
```dart
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/crisis_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/unit_tracker_screen.dart';
import '../screens/alert_feed_screen.dart';
import '../screens/agent_logs_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',        builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/dashboard',     builder: (c, s) => const DashboardScreen()),
    GoRoute(
      path: '/crisis/:id',
      builder: (c, s) => CrisisDetailScreen(crisisId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/map',           builder: (c, s) => const MapScreen()),
    GoRoute(path: '/units',         builder: (c, s) => const UnitTrackerScreen()),
    GoRoute(path: '/alerts',        builder: (c, s) => const AlertFeedScreen()),
    GoRoute(path: '/agent-logs',    builder: (c, s) => const AgentLogsScreen()),
  ],
);
```

---

### 10.7 Screen 1: Splash Screen

**File: `flutter_app/lib/screens/splash_screen.dart`**
```dart
// PURPOSE: Brand intro + Firebase connection check + route to Dashboard
// DESIGN: Full dark screen, CIRO logo pulses in, org names fade in below,
//         "INITIALIZING SYSTEMS..." text types out, then routes to dashboard.

// LAYOUT:
// - Full screen bgDeep background
// - Center column:
//   1. CIRO logo text (SpaceGrotesk 64px bold, accentBlue)
//   2. Tagline: "Crisis Intelligence & Response Orchestrator" (14px, textSecondary)
//   3. "National Emergency Response System — Pakistan" (12px, accentCyan, with Pakistan flag emoji)
//   4. Lottie animation: spinning radar/pulse (use a subtle blue waveform)
//   5. Status text: "CONNECTING TO FIREBASE..." → "SYSTEMS ONLINE" (JetBrainsMono, 11px)
// - Bottom: version tag "v1.0 | HACKATHON BUILD"

// BEHAVIOR:
// - On init: attempt to read /system_state from Firebase
// - If connected: show "SYSTEMS ONLINE" in green for 1 second, then go('/dashboard')
// - If failed: show "CONNECTION ERROR — CHECK SERVER" in red
// - Auto-navigate to /dashboard after 3.5 seconds regardless (for demo reliability)

// ANIMATION SEQUENCE (use flutter_animate):
// 1. Logo fades+slides up: delay 200ms, duration 600ms
// 2. Tagline fades in: delay 700ms
// 3. Lottie starts: delay 900ms
// 4. Status text types out: delay 1200ms
// 5. Navigate: delay 3500ms
```

---

### 10.8 Screen 2: Dashboard Screen (MAIN SCREEN)

**File: `flutter_app/lib/screens/dashboard_screen.dart`**
```dart
// PURPOSE: Primary coordinator view — everything the emergency coordinator needs at a glance.
// This is the screen that will be on camera for 80% of the demo.

// LAYOUT STRUCTURE:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "CIRO" logo + system mode badge + timestamp │
// ├─────────────────────────────────────────────────────┤
// │ [SYSTEM STATUS BAR] — full width colored strip:     │
// │   MONITORING (blue) | CRISIS ACTIVE (pulsing red)  │
// ├─────────────────────────────────────────────────────┤
// │ [ACTIVE CRISES SECTION]                             │
// │   Title: "ACTIVE CRISES" + count badge             │
// │   → ListView of CrisisCard widgets                  │
// │   → If empty: "All Clear — No Active Crises" (green)│
// ├─────────────────────────────────────────────────────┤
// │ [UNIT STATUS GRID] — 2-column grid                  │
// │   Title: "RESCUE UNITS"                             │
// │   → Grid of UnitMiniCard widgets (5 units)          │
// ├─────────────────────────────────────────────────────┤
// │ [QUICK ACTIONS ROW] — horizontal scroll             │
// │   [🗺 Live Map] [📡 Alerts] [📋 Agent Logs] [⚙️ Sim]│
// └─────────────────────────────────────────────────────┘
// Bottom NavBar: Dashboard | Map | Units | Alerts | Logs

// WIDGET: CrisisCard
// ┌──────────────────────────────────────────┐
// │ [emoji icon] [CRISIS TYPE LABEL]         │
// │ [SEVERITY badge — colored]               │
// │ Location: G-10 Sector, Islamabad         │
// │ Confidence: ████████░░ 91%              │
// │ People affected: ~2,000                  │
// │ Roads blocked: G-10 Markaz Road          │
// │ [AI Reasoning: "3 social media posts..."]│
// │ [VIEW DETAILS →] button                  │
// └──────────────────────────────────────────┘
// - Tap: goes to /crisis/:id
// - Severity HIGH/CRITICAL: card has pulsing border animation (CSS-like flutter_animate)
// - Background: linear gradient from severity color (5% opacity) to bgCard

// WIDGET: UnitMiniCard
// ┌────────────────┐
// │ [type emoji]   │
// │ Unit name      │
// │ ● AVAILABLE    │  (colored dot + status label)
// │ Type label     │
// └────────────────┘
// - Status dot pulses if dispatched
// - Tap: goes to /units

// BEHAVIOR:
// All data via Riverpod stream providers. No manual refresh.
// SystemState listener: if mode changes to "crisis_active", status bar animates to red.
// Show shimmer loading state while streams are connecting.

// SIMULATION CONTROL (demo button — only show during hackathon demo):
// Floating "TRIGGER SCENARIO" button (bottom right, red FAB)
// → Opens bottom sheet with scenario list from API
// → On select: POST /api/simulation/trigger/{scenario_name}
// → Shows "Scenario Activated — Run Antigravity Pipeline" toast
// → Also has "RESET SYSTEM" button that calls POST /api/simulation/reset
```

---

### 10.9 Screen 3: Crisis Detail Screen

**File: `flutter_app/lib/screens/crisis_detail_screen.dart`**
```dart
// PURPOSE: Deep dive into a specific crisis. Shows all data Analyst generated,
//          the action plan, and the outcome metrics.

// LAYOUT:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "[emoji] Urban Flooding" + severity badge   │
// ├─────────────────────────────────────────────────────┤
// │ [CRISIS HEADER CARD]                                │
// │   Location: G-10 Sector, Islamabad                 │
// │   Detected: [timestamp formatted nicely]            │
// │   Confidence: [large percentage + label]            │
// │   People at risk: [number]                          │
// ├─────────────────────────────────────────────────────┤
// │ [AI REASONING SECTION]                              │
// │   Label: "🤖 ANALYST ASSESSMENT"                    │
// │   Body: reasoning_summary text (full text, italic)  │
// │   Style: bgElevated card, cyan left border accent   │
// ├─────────────────────────────────────────────────────┤
// │ [IMPACT ASSESSMENT]                                 │
// │   Row: Roads blocked (list pills)                   │
// │   Row: Vehicles stranded: YES/NO                    │
// │   Row: Casualties likely: NO (green) / YES (red)    │
// │   Row: Infra damage: [severity pill]                │
// ├─────────────────────────────────────────────────────┤
// │ [RESPONSE ACTIONS]                                  │
// │   Title: "⚡ RESPONSE ACTIONS"                      │
// │   → ActionItem list (each with icon, title, status) │
// ├─────────────────────────────────────────────────────┤
// │ [OUTCOME METRICS] — Before vs After                 │
// │   Two-column comparison:                            │
// │   BEFORE              AFTER                         │
// │   Congestion: 96%  →  38%  (bar chart, red→green)   │
// │   Stranded: 35     →  5    (number diff)            │
// │   Units active: 0  →  1                             │
// │   [fl_chart bar chart showing comparison]           │
// └─────────────────────────────────────────────────────┘

// WIDGET: ActionItem
// Row with:
// - Left: action type icon (🚤 dispatch | 🗺 reroute | 📢 alert | 🏘 relief)
// - Center: action title + one-line instruction
// - Right: status pill ("EXECUTED" in green | "PENDING" in yellow)

// OUTCOME CHART:
// Use fl_chart BarChart
// Two groups: "Before" and "After"
// Bars: Congestion %, Stranded Vehicles (scaled)
// Before bars: severityHigh color
// After bars: severityLow color
// Show percentage change labels above bars

// BEHAVIOR:
// Load crisis by ID from activeCrisesProvider
// Load outcome metrics from outcomeMetricsProvider
// All real-time — updates live as Dispatcher writes to Firebase
```

---

### 10.10 Screen 4: Map Screen

**File: `flutter_app/lib/screens/map_screen.dart`**
```dart
// PURPOSE: Live Google Maps view showing crisis locations, unit positions,
//          and active reroutes. The most visually impressive screen for the demo.

// LAYOUT:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "LIVE OPERATIONS MAP"                        │
// │ [Legend row]: 🔴 Crisis  🟠 Dispatched  🟢 Available │
// ├─────────────────────────────────────────────────────┤
// │ [GOOGLE MAP — takes 85% of screen height]           │
// │                                                      │
// │  Custom Markers:                                     │
// │  - Crisis zone: pulsing red circle + warning icon   │
// │  - Crisis radius: semi-transparent red circle        │
// │  - Available unit: green rescue icon marker          │
// │  - Dispatched unit: orange moving marker             │
// │  - Alternate route: cyan dashed polyline             │
// │  - Blocked road: red solid polyline                  │
// │  - Relief point: blue cross marker                   │
// └─────────────────────────────────────────────────────┘
// Bottom panel (draggable): lists active reroutes as cards

// GOOGLE MAPS CONFIGURATION:
// - Map style: Dark map style JSON (custom dark military aesthetic)
// - Initial camera: Pakistan (lat: 30.3753, lng: 69.3451, zoom: 5.5)
// - On crisis detected: camera animates to crisis lat/lng, zoom 13
// - Map type: MapType.normal with dark styling

// DARK MAP STYLE JSON (apply via mapStyle parameter):
// Use a dark military-style map JSON. Key style rules:
// - All water: Color #0A1628
// - All land: Color #080C14
// - Roads: Color #1A2744
// - Labels: Color #4A6080
// - Parks: Color #0A1820
// (Full JSON available at snazzymaps.com — use "Dark Matter" or build custom)

// MARKERS:
// Crisis marker:
//   - BitmapDescriptor.fromAssetImage for custom crisis icon
//   - On tap: show InfoWindow with crisis_type, severity, affected_area_name
//   - Add Circle widget: center=crisis coords, radius=radius_km*1000,
//     fillColor=severityCritical.withOpacity(0.15),
//     strokeColor=severityCritical, strokeWidth=2

// Unit markers:
//   - Color coded by status (green/orange/blue)
//   - On tap: show InfoWindow with unit name, type, status, ETA if dispatched

// Reroute polylines:
//   - Blocked road: Polyline color=severityCritical, width=4, patterns=[dot,gap]
//   - Alternate route: Polyline color=accentCyan, width=3, patterns=[dash,gap]

// BEHAVIOR:
// All markers and polylines built from Riverpod streams
// activeCrisesProvider → place crisis circles and markers
// unitsProvider → place unit markers, update positions
// activeReroutesProvider → draw polylines
// When new crisis appears: camera animates to crisis location
// When unit status changes: marker color updates instantly
```

---

### 10.11 Screen 5: Unit Tracker Screen

**File: `flutter_app/lib/screens/unit_tracker_screen.dart`**
```dart
// PURPOSE: Detailed Rescue 1122 and PDMA unit management view.
// Shows all 5 units with full status, assignment, and ETA information.

// LAYOUT:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "RESCUE UNITS" + available count badge      │
// │ Summary: "[N] Available  [M] Deployed  [P] Standby" │
// ├─────────────────────────────────────────────────────┤
// │ [UNIT CARDS LIST — vertical scroll]                 │
// │                                                      │
// │  ┌────────────────────────────────────────────┐     │
// │  │ 🚤 Rescue 1122 — Delta Team (Flood)         │     │
// │  │ ID: 1122-ISB-04          Type: Flood Rescue │     │
// │  │ Status: ● DISPATCHED (pulsing orange dot)   │     │
// │  │ Destination: G-10 Markaz Road               │     │
// │  │ ETA: 8 minutes                              │     │
// │  │ Crisis: crisis_001 (link)                   │     │
// │  │ [ETA countdown animation bar]               │     │
// │  └────────────────────────────────────────────┘     │
// └─────────────────────────────────────────────────────┘

// UNIT CARD DETAILS:
// - Large unit type emoji (48px)
// - Unit name (titleLarge)
// - Unit ID (labelSmall, monospace)
// - Status indicator: colored dot + label
//   If DISPATCHED: show animated countdown progress bar for ETA
//   If AVAILABLE: show "Ready for Dispatch" in statusAvailable color
//   If ON_SCENE: show pulsing "ON SCENE" badge
// - If dispatched: show destination address + linked crisis name
// - Agency badge: "RESCUE 1122" or "PDMA" pill

// BEHAVIOR:
// All data from unitsProvider stream
// Countdown timer: if unit has eta_minutes, show countdown from dispatch time
//   (store dispatch_time locally in app state)
// After ETA elapses: automatically change displayed status to "ON_SCENE" in UI
//   (Firebase will update separately from agent; app should handle gracefully)
```

---

### 10.12 Screen 6: Alert Feed Screen

**File: `flutter_app/lib/screens/alert_feed_screen.dart`**
```dart
// PURPOSE: Chronological feed of all alerts broadcast by the system.
// Shows both English and Urdu text for each alert.

// LAYOUT:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "ACTIVE ALERTS" + unacknowledged count      │
// ├─────────────────────────────────────────────────────┤
// │ [ALERT CARDS — reverse chronological]              │
// │                                                      │
// │  ┌────────────────────────────────────────────┐     │
// │  │ 🚨 HIGH SEVERITY              14:36:03     │     │
// │  │ ─────────────────────────────────────────  │     │
// │  │ FLOOD ALERT — G-10 Islamabad               │     │
// │  │ Heavy flooding reported in G-10. Avoid     │     │
// │  │ G-10 Markaz Road. Rescue 1122 deployed.    │     │
// │  │ ─────────────────────────────────────────  │     │
// │  │ [اردو] جی-10 میں شدید سیلاب۔ جی-10 مرکز  │     │
// │  │ روڈ سے بچیں۔ ریسکیو 1122 تعینات۔          │     │
// │  │ ─────────────────────────────────────────  │     │
// │  │ Channels: in-app  SMS  PDMA Dashboard      │     │
// │  │ [MARK ACKNOWLEDGED] button                 │     │
// │  └────────────────────────────────────────────┘     │
// └─────────────────────────────────────────────────────┘

// ALERT CARD DESIGN:
// - Left border: 4px solid, severity color
// - Header: severity badge + timestamp
// - English text: normal body
// - Divider
// - Urdu text: right-aligned, Noto Nastaliq Urdu font if available,
//   else use arabic-capable system font with textDirection: TextDirection.rtl
// - Channel pills: small filled pills for each channel
// - Acknowledge button: updates Firebase /alerts/[id]/acknowledged to true
//   → Card gets slightly dimmed opacity when acknowledged

// BEHAVIOR:
// All data from alertsProvider stream
// New alerts animate in from top (slide + fade)
// Unacknowledged count shown in AppBar badge and in Dashboard bottom nav tab
```

---

### 10.13 Screen 7: Agent Logs Screen

**File: `flutter_app/lib/screens/agent_logs_screen.dart`**
```dart
// PURPOSE: Real-time log feed showing every agent's reasoning steps and decisions.
// This is the "transparency" screen — proves the system is genuinely agentic.
// CRITICAL for demo: show this during the Antigravity pipeline execution.

// LAYOUT:
// ┌─────────────────────────────────────────────────────┐
// │ AppBar: "AGENT PIPELINE LOGS"                       │
// │ Filter tabs: [ALL] [SENTINEL] [ANALYST] [COMMANDER] │
// │             [DISPATCHER]                            │
// ├─────────────────────────────────────────────────────┤
// │ [LOG ENTRIES — reverse chronological, auto-scroll]  │
// │                                                      │
// │  ┌────────────────────────────────────────────┐     │
// │  │ [ANALYST]            14:34:22              │     │
// │  │ Crisis DETECTED: Urban flooding G-10.      │     │
// │  │ Severity: HIGH. Confidence: 91%.           │     │
// │  │ Reasoning: 3 corroborating social media    │     │
// │  │ reports + PMD weather alert. Forwarding    │     │
// │  │ CrisisProfile to Commander.               │     │
// │  └────────────────────────────────────────────┘     │
// └─────────────────────────────────────────────────────┘

// LOG ENTRY DESIGN:
// Agent name pill colors:
//   - Sentinel:   accentCyan background + dark text
//   - Analyst:    purple (Color 0xFF9B59B6) background
//   - Commander:  orange (Color 0xFFFF9F0A) background
//   - Dispatcher: green (statusAvailable) background
// Timestamp: JetBrainsMono 11px, textTertiary
// Message: body text, textPrimary
// Entry background: bgCard with 1px borderSubtle
// Entry left border: 3px solid matching agent color

// FILTER TABS:
// Tab buttons styled as pills
// Active tab: filled with agent color
// Inactive: outlined

// BEHAVIOR:
// Stream from agentLogsProvider
// Auto-scroll to newest entry when new log arrives
// Filter by tapping agent name tab
// Each new entry animates in with a flash (brief highlight then fades to normal)
// "PIPELINE ACTIVE" indicator shown in AppBar when system_state.mode == "crisis_active"
```

---

### 10.14 main.dart

**File: `flutter_app/lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: CiroApp()));
}

class CiroApp extends StatelessWidget {
  const CiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CIRO — Crisis Intelligence & Response Orchestrator',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
```

---

## 11. END-TO-END DATA FLOW

This section describes the exact sequence of events from scenario trigger to UI update.
Every step maps to a component defined above.

```
TIME    EVENT                              COMPONENT           FIREBASE CHANGE
──────  ─────────────────────────────────  ──────────────────  ───────────────────────────────────
T+0s    Admin taps "Trigger Scenario"      Flutter Dashboard   None yet
        → POST /api/simulation/trigger/    FastAPI             
          urban_flood_g10

T+1s    FastAPI loads urban_flood_g10.json FastAPI             /system_state/mode → "simulation"
        Activates crisis mode on generator
        Returns: "scenario_activated"

T+2s    Flutter receives API response       Flutter Dashboard   Reads /system_state → shows
        Shows toast: "Scenario Activated"                       "SIMULATION" mode badge

T+3s    Operator runs Antigravity pipeline  Antigravity Manager None yet — pipeline starting
        Manager triggers Agent 1 (Sentinel)

T+5s    Sentinel calls GET /api/signals/all FastAPI             Sentinel gets 8 signals
        Receives: 6 crisis signals,                             (5 flood-related, 1 normal)
        1 weather WARNING, 2 traffic anomalies

T+12s   Sentinel normalizes Roman Urdu      Antigravity         None yet
        Identifies G-10 flooding cluster
        Outputs SignalBundle JSON

T+13s   Sentinel writes agent log           Antigravity→Firebase /agent_logs/log_xxx created
                                                                Flutter AgentLogs screen
                                                                shows new Sentinel entry

T+15s   Manager passes SignalBundle to      Antigravity Manager None
        Agent 2 (Analyst)

T+18s   Analyst scores signals:             Antigravity         None — reasoning in progress
        5 crisis signals (HIGH quality)
        Weather: HIGH corroboration
        Traffic: YES corroboration
        Score: 7 → CRITICAL/HIGH severity
        Confidence: 0.50+0.25+0.15+0.10+0.05 = 0.91 (capped 0.98 → 0.91)

T+25s   Analyst outputs CrisisProfile       Antigravity→Firebase /active_crises/crisis_001 CREATED
        crisis_type: urban_flooding                             /system_state/mode → "crisis_active"
        severity: HIGH                                          /outcome_metrics/before SET
        confidence: 0.91                                        /agent_logs/log_yyy created

T+26s   Flutter detects /active_crises      Flutter             Dashboard: CrisisCard appears
        change via onValue stream           Dashboard           with pulsing red border
                                            MapScreen           Map: red circle appears at G-10
                                                                System status bar → RED

T+28s   Manager passes CrisisProfile to     Antigravity Manager None
        Agent 3 (Commander)

T+30s   Commander fetches available units   Commander→FastAPI   GET /api/units/available
        Selects 1122-ISB-04 (flood_rescue)
        Plans 4 actions

T+40s   Commander outputs ActionPlan        Antigravity         /agent_logs/log_zzz created
        Writes agent log                    →Firebase           Flutter: Commander log appears

T+42s   Manager passes ActionPlan to        Antigravity Manager None
        Agent 4 (Dispatcher)

T+44s   Dispatcher executes Action 1:       Dispatcher→Firebase /units/1122-ISB-04 UPDATED:
        dispatch_unit (1122-ISB-04)                             status: "dispatched"
                                                                destination: "G-10 Markaz Road"
                                                                eta_minutes: 8

T+44s   Flutter detects /units change       Flutter UnitTracker UnitCard: status → DISPATCHED
        via onValue stream                  Flutter MapScreen   Map: unit marker → orange
                                                                ETA countdown starts

T+46s   Dispatcher executes Action 2:       Dispatcher→Firebase /routes/active_reroutes/reroute_001
        traffic_reroute                                         CREATED:
                                                                blocked_road: G-10 Markaz Road
                                                                alternate: Srinagar Highway
                                                                waypoints: [...]

T+46s   Flutter detects /routes change      Flutter MapScreen   Map: red polyline on G-10 Markaz
                                                                Cyan polyline on Srinagar Hwy

T+48s   Dispatcher executes Action 3:       Dispatcher→Firebase /alerts/alert_001 CREATED:
        broadcast_alert                                         title, body, urdu_body

T+48s   Flutter detects /alerts change      Flutter AlertFeed   New alert card slides in
                                            Flutter Dashboard   Alert count badge updates

T+50s   Dispatcher executes Action 4:       Dispatcher→Firebase /active_crises/crisis_001/
        open_relief_point                                       relief_points/rp_001 CREATED

T+52s   Dispatcher writes outcome_metrics   Dispatcher→Firebase /outcome_metrics/after SET:
        Congestion: 96→40, Stranded: 35→5                      Flutter CrisisDetail:
                                                                Before/After chart updates

T+53s   Dispatcher writes ExecutionLog      Dispatcher→Firebase /agent_logs/log_final CREATED
                                                                Flutter AgentLogs: shows
                                                                "Execution complete" entry

T+55s   Manager collects all agent outputs  Antigravity         Produces CIRO_Agent_Trace
        Writes combined artifact                                markdown file (deliverable)

T+56s   Full pipeline complete              All                 Firebase fully updated
        Demo: show Dashboard, then Map,                         All Flutter screens reflect
        then CrisisDetail (before/after),                       final system state
        then AgentLogs, then reset
```

---

## 12. PRE-BUILT DEMO CRISIS SCENARIOS

### Scenario Execution Cheat Sheet (for Demo Day)

| Scenario | Trigger Command | Primary Unit Dispatched | Route Change | Alert Type |
|---|---|---|---|---|
| G-10 Urban Flood | `/api/simulation/trigger/urban_flood_g10` | 1122-ISB-04 (Flood) | G-10 Markaz → Srinagar Hwy | 🚨 HIGH FLOOD |
| M-2 Road Accident | `/api/simulation/trigger/road_accident_m2` | 1122-ISB-02 (Medical) | M-2 → N-5 Highway | 🚨 CRITICAL ACCIDENT |
| Lahore Heatwave | `/api/simulation/trigger/heatwave_lahore` | 1122-ISB-02 (Medical) | None (citywide) | 🌡️ CRITICAL HEAT |
| I-8 Transformer | `/api/simulation/trigger/power_failure_i8` | 1122-ISB-03 (Fire) | I-8 area cordon | ⚡ MEDIUM INFRA |

### Recommended Demo Scenario: `urban_flood_g10`
Use this as your primary demo scenario because:
1. It uses Roman Urdu ("G-10 mein pani bhar gaya hai") — showcases localization
2. All 4 action types fire (dispatch, reroute, alert, relief point) — maximizes visible simulation
3. Map changes are dramatic (red circle + route polylines on Islamabad)
4. Before/after metrics are stark (congestion 96→40, stranded 35→5)

### Reset Between Demos
Call `POST /api/simulation/reset` — this:
1. Clears Firebase of all crises, alerts, routes, agent logs
2. Resets all units to "available"
3. Sets system_state back to "monitoring"
4. Flutter app returns to "All Clear" state within 2 seconds

---

## 13. DEMO VIDEO SCRIPT (3–5 MINUTES)

**Target Duration: 4 minutes 30 seconds**
**Screen capture: Phone screen + Antigravity workspace side-by-side**

---

### [00:00–00:25] OPENING — System Introduction
**Show:** Flutter Splash Screen loading, then Dashboard (all clear state)
**Say (or text overlay):**
"This is CIRO — Pakistan's Crisis Intelligence and Response Orchestrator.
A 4-agent AI system that ingests real-world signals, detects emerging disasters,
and coordinates Rescue 1122 and PDMA response — automatically."

**Visual:** Slow pan across Dashboard showing all 5 units AVAILABLE (green),
system status "MONITORING", no active crises.

---

### [00:25–01:00] SIGNAL INJECTION — "The Crisis Begins"
**Show:** Switch to showing the FastAPI trigger, then immediately back to Flutter
**Say:**
"Signals start arriving. Social media posts — in Roman Urdu and English —
report flooding in G-10 Islamabad. The PMD weather system issues a heavy
rainfall warning. Traffic data shows a 96% congestion spike on G-10 Markaz Road."

**Action:** Trigger the scenario via the Flutter "TRIGGER SCENARIO" button.
**Visual:** Show the raw signal data briefly (either from FastAPI or Agent Logs screen
as Sentinel starts logging).

---

### [01:00–02:00] AGENT PIPELINE — "The AI Thinks"
**Show:** Switch to Antigravity Manager Surface view
**Say:**
"The CIRO agent pipeline activates. Four specialized agents work in sequence."

**Walk through each agent as it runs:**
- "Agent 1 — The Sentinel — collects and normalizes signals. It translates
  'gaariyan phans gayi hain' — vehicles stranded — from Roman Urdu."
- "Agent 2 — The Analyst — clusters the signals. 5 flooding reports,
  weather corroboration, traffic anomaly. Confidence: 91%. Crisis confirmed: HIGH severity."
- "Agent 3 — The Commander — selects Rescue 1122 Delta Flood Team,
  plans the traffic reroute via Srinagar Highway, and drafts bilingual alerts."
- "Agent 4 — The Dispatcher — simulates execution, pushing every decision
  into our live Firebase database."

**Visual:** Show the Antigravity reasoning steps / artifact output as each agent produces output.
Show the Agent Logs screen in Flutter updating in real time as each agent writes its log entry.

---

### [02:00–03:00] LIVE RESPONSE — "The System Acts"
**Show:** Flutter app — switch between screens as each action fires

1. **Dashboard:** Crisis card appears with pulsing red border
   "The crisis appears on the coordinator dashboard instantly."

2. **Map Screen:** Red circle over G-10, orange route polyline
   "The map shows the crisis zone in G-10. The blocked road is flagged."

3. **Map Screen:** Cyan alternate route polyline appears
   "Srinagar Highway is designated as the alternate route."

4. **Unit Tracker:** 1122-ISB-04 status flips to DISPATCHED with ETA countdown
   "Rescue 1122 Delta Flood Team is dispatched. 8-minute ETA."

5. **Alert Feed:** New alert slides in with English + Urdu text
   "A bilingual alert is broadcast across all channels — English and Urdu."

---

### [03:00–03:45] OUTCOME — "Before vs After"
**Show:** Flutter CrisisDetail screen, scrolled to Outcome Metrics section
**Say:**
"Here's the impact. Before intervention: 96% congestion, 35 vehicles stranded.
After coordinated response: congestion drops to 40%, stranded vehicles down to 5.
Projected resolution: 45 minutes."

**Visual:** The fl_chart bar chart showing the before/after comparison with the bars
animating in. Camera lingers for 10 seconds on the chart.

---

### [03:45–04:15] AGENT LOGS — "Full Transparency"
**Show:** Agent Logs screen showing all 4 agent entries
**Say:**
"Every decision is logged. The Sentinel's normalization, the Analyst's reasoning,
the Commander's plan, the Dispatcher's execution — full end-to-end accountability.
These logs are our Agent Trace deliverable."

**Visual:** Slowly scroll through the 4 log entries, each with their colored agent badge.

---

### [04:15–04:30] CLOSING
**Show:** Dashboard returning to "All Clear" state after reset
**Say:**
"CIRO. Real-time crisis intelligence. Coordinated response. Pakistan-ready."

**Visual:** Fade to CIRO logo with tagline.

---

## 14. EVALUATION CRITERIA MAPPING

Every evaluation criterion is explicitly addressed by a component in this blueprint.

### Criterion 1: Use of Google Antigravity (25%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Core orchestration via Antigravity | Manager Surface orchestrates all 4 agents in defined sequence |
| Multi-agent planning + execution | Sentinel → Analyst → Commander → Dispatcher, distinct roles |
| Tool integration | Agents use HTTP tools (FastAPI), Firebase Admin write tools |
| Antigravity artifacts as logs | Each agent produces markdown artifact, combined as CIRO_Agent_Trace |

### Criterion 2: Agentic Reasoning & Coordination (20%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Multi-agent interaction | 4 agents with explicit handoff — each receives previous agent's JSON |
| Logical reasoning | Analyst uses weighted scoring, confidence formula, hard override rules |
| Decision-making quality | Commander selects units by type match, plans by protocol, writes bilingual alerts |

### Criterion 3: Situation Detection & Analysis (20%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Accuracy of event detection | 3-source corroboration (social + weather + traffic) required for HIGH confidence |
| Quality of insights | Analyst produces detailed impact assessment (people, roads, vehicles) |
| Clear explanations | reasoning_summary field is human-readable prose, shown on CrisisDetail screen |

### Criterion 4: Action Planning & Simulation (15%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Realistic response actions | Rescue 1122 units, PDMA protocols, NHA rerouting — all Pakistan-specific |
| Effective simulation | Dispatcher writes to Firebase → Flutter updates in ~1 second real time |
| Clear system state change | Before vs After metrics chart + unit status changes are visually obvious |

### Criterion 5: Technical Implementation (10%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Clean architecture | Strict separation: FastAPI (mock), Firebase (state), Flutter (UI), Antigravity (AI) |
| API integration | FastAPI → Antigravity (HTTP polling), Antigravity → Firebase (Admin SDK) |
| Robustness | Error handling in all agents, reset endpoint, shimmer loading states in Flutter |

### Criterion 6: Innovation & UX (10%)
| Sub-criterion | How CIRO Addresses It |
|---|---|
| Creativity | Pakistan-specific: Roman Urdu NLP, Rescue 1122 branding, PDMA/NHA agencies |
| Usability | Flutter dark mode, severity color system, real-time streams, no manual refresh |
| Demo clarity | Structured 4.5-minute script, side-by-side Antigravity + Flutter view |

---

## 15. README TEMPLATE

```markdown
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

Agent prompts are in `/antigravity/`. Combined Agent Trace log exported as artifact.

## Tools & APIs Used

| Tool | Version | Purpose |
|---|---|---|
| Google Antigravity | Latest | Multi-agent orchestration |
| Python / FastAPI | 3.11 / 0.111 | Mock signal server |
| Firebase Realtime Database | Latest | Real-time state sync |
| Flutter | 3.22 | Mobile application |
| Google Maps Flutter | 2.7.0 | Crisis & unit mapping |
| Firebase Admin SDK | 6.5.0 | Agent→Firebase writes |

## How to Run

### 1. Start the Mock Signal Server
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env  # add your Firebase Database URL
uvicorn main:app --reload --port 8000
```

### 2. Initialize Firebase
- Create Firebase project at console.firebase.google.com
- Enable Realtime Database
- Download serviceAccountKey.json → place in backend/firebase_config/
- Run reset: `POST http://localhost:8000/api/simulation/reset`

### 3. Build and Run Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

### 4. Run Antigravity Pipeline
- Open Antigravity Manager Surface
- Load agent prompts from /antigravity/ folder
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
```

---

## APPENDIX: ENVIRONMENT VARIABLES

**File: `backend/.env`**
```env
FIREBASE_DATABASE_URL=https://your-project-id-default-rtdb.firebaseio.com
FASTAPI_HOST=0.0.0.0
FASTAPI_PORT=8000
SIMULATION_MODE=true
```

**File: `backend/requirements.txt`**
```
fastapi==0.111.0
uvicorn==0.30.0
firebase-admin==6.5.0
httpx==0.27.0
faker==25.0.0
apscheduler==3.10.4
python-dotenv==1.0.1
pydantic==2.7.0
```

---

## APPENDIX: DEVELOPMENT BUILD ORDER

Follow this exact sequence to build CIRO without integration issues:

**Phase 1 — Foundation (Build First, Test First)**
1. Set up Firebase project, enable Realtime Database, get service account key
2. Build FastAPI server (`main.py` + all routers) — test all endpoints via browser/Postman
3. Verify `POST /api/simulation/reset` correctly writes baseline to Firebase (check Firebase console)
4. Verify `POST /api/simulation/trigger/urban_flood_g10` activates crisis mode in generator

**Phase 2 — Flutter Shell**
5. Create Flutter project, install dependencies (`flutter pub get`)
6. Configure Firebase (`flutterfire configure`)
7. Build models (CrisisModel, UnitModel, AlertModel) — no UI yet
8. Build FirebaseService with all stream methods
9. Build Riverpod providers
10. Build DashboardScreen — connect to streams, verify data flows from Firebase to UI
11. Build remaining screens in order: Map → Units → Alerts → AgentLogs → CrisisDetail

**Phase 3 — Antigravity Agents**
12. Open Antigravity, create Manager Surface
13. Configure Agent 1 (Sentinel) with system prompt, test HTTP tool call to FastAPI
14. Verify Sentinel outputs correct SignalBundle JSON structure
15. Configure Agent 2 (Analyst), test with Sentinel output
16. Verify Analyst writes CrisisProfile to Firebase (check Firebase console live)
17. Confirm Flutter Dashboard shows the crisis card (end-to-end test 1)
18. Configure Agent 3 (Commander), test with Analyst output
19. Configure Agent 4 (Dispatcher), test Firebase writes for all 4 action types
20. Confirm Flutter app fully updates (end-to-end test 2)

**Phase 4 — Polish & Demo Prep**
21. Verify Reset flow works cleanly (Firebase clears, UI returns to all-clear)
22. Record demo video per script in Section 13
23. Export Antigravity artifact as Agent Trace log
24. Complete README using template in Section 15

---

*End of CIRO Implementation Blueprint v1.0*
*Built for Google Antigravity Hackathon — Challenge 3: Crisis Intelligence & Response Orchestrator*
*Pakistan National Emergency Response System — Rescue 1122 | PDMA | NHA Integration*
