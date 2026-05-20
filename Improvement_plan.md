CIRO - Teammate Development Plan

**Your Goal: Make CIRO More Powerful & Win the Hackathon**

# WHAT HAS BEEN DONE (Your Starting Point)

The project already has:

- ✅ FastAPI backend with signal generation and Firebase sync
- ✅ 4 Antigravity agent prompts (Sentinel, Analyst, Commander, Dispatcher)
- ✅ Firebase real-time database connected
- ✅ Flutter app basic structure
- ✅ Crisis scenarios (flooding, accident, heatwave, infrastructure)
- ✅ Bilingual alerts (English + Urdu)

Your job is to make it smarter, more realistic, and more impressive for judges.

# WHAT YOU NEED TO READ FIRST

- Read CIRO_Implementation_Blueprint.pdf - full document
- Read all 4 files in antigravity/ folder
- Read backend/services/signal_generator.py
- Understand Firebase schema in blueprint Section 6

# JUDGE SCORING BREAKDOWN (Know What Wins)

| **Criteria**                 | **Weight** | **Your Target**                     |
| ---------------------------- | ---------- | ----------------------------------- |
| Antigravity Usage            | 25%        | Must be the brain of everything     |
| Agentic Reasoning            | 20%        | Deep, explainable, chain-of-thought |
| Situation Detection          | 20%        | Multi-source, accurate, confident   |
| Action Planning & Simulation | 15%        | Realistic authority dispatch        |
| Technical Implementation     | 10%        | Clean, working, integrated          |
| Innovation & UX              | 10%        | Bilingual, impressive demo          |

**Focus on top 3 rows. That is 65% of your score.**

# YOUR DEVELOPMENT PLAN

## PHASE 1 - ANTIGRAVITY ENHANCEMENT (Most Important)

**Tool: Antigravity (your fresh account) | Priority: HIGHEST**

This is where you spend most of your Antigravity limit. The goal is to make agents think deeper and take more realistic authority actions.

### TASK 1.1 - Upload to Antigravity and Run Audit

Open Antigravity. Upload:  
\- CIRO_Implementation_Blueprint.pdf  
\- All files from antigravity/ folder  
\- backend/services/signal_generator.py  
<br/>Then paste this prompt:

Read CIRO_Implementation_Blueprint.pdf completely.  
Read all 4 agent prompt files in the antigravity/ folder.  
Read signal_generator.py.  
<br/>Do a gap analysis and tell me:  
1\. What is missing or weak in the current agent prompts  
2\. What advanced features can be added to make agents more intelligent  
3\. Specifically check if these are implemented:  
\- Authority notification (Police, Fire Department, PDMA, NDMA, NHA)  
\- Hospital capacity checking before dispatch  
\- Multi-crisis simultaneous handling  
\- Predictive escalation before crisis worsens  
\- Casualty estimation with specific numbers  
\- Resource conflict resolution (two crises need same unit)  
<br/>Then improve all 4 agent prompts with these enhancements.  
Keep everything consistent with the blueprint architecture.

### TASK 1.2 - Add Authority Dispatch to Commander Agent

The current Commander dispatches rescue units. Upgrade it to dispatch real authorities.  
In Antigravity, improve agent_3_commander_prompt.md to include:  
Real Authority Actions:

AUTHORITY NOTIFICATION SYSTEM:  
<br/>When severity is HIGH or CRITICAL, Commander must notify relevant authorities:  
<br/>POLICE (via Police Emergency 15):  
\- Trigger: road_accident, civil_disturbance, infrastructure_failure  
\- Action: Generate formal police dispatch ticket with location, incident type, units needed  
\- Message format: "CIRO DISPATCH - Police Unit Required: \[Location\]. Incident: \[Type\].  
Severity: \[Level\]. Coordinate with Rescue 1122."  
<br/>FIRE DEPARTMENT:  
\- Trigger: infrastructure_failure with fire/explosion keywords, any aag/dhuan signals  
\- Action: Dispatch fire brigade with cordon radius recommendation  
\- Message: "FIRE ALERT - \[Location\]. Transformer/Building fire reported.  
Dispatch 2 units. Cordon \[X\] meter radius. Evacuate \[N\] households."  
<br/>PDMA (Provincial Disaster Management Authority):  
\- Trigger: urban_flooding HIGH/CRITICAL, earthquake, landslide  
\- Action: Formal PDMA activation request with relief center recommendation  
\- Message: "PDMA ACTIVATION REQUEST - \[Crisis Type\] at \[Location\].  
Estimated \[N\] people affected. Request relief camp at \[Location\].  
CIRO Confidence: \[X\]%."  
<br/>NDMA (National Disaster Management Authority):  
\- Trigger: earthquake CRITICAL, multi-city crisis, CRITICAL + CRITICAL simultaneously  
\- Action: National-level escalation with full situation report  
<br/>NHA (National Highway Authority):  
\- Trigger: motorway accident, landslide on highway  
\- Action: Road closure order with alternate route activation  
<br/>WAPDA/IESCO (Power Authority):  
\- Trigger: transformer explosion, power grid failure  
\- Action: Emergency power restoration request with affected area grid reference  
<br/>HOSPITALS:  
\- Trigger: casualties_likely = true in any crisis  
\- Action: Pre-alert nearest hospitals with estimated casualty count  
\- Check capacity: if estimated_casualties > 20 alert multiple hospitals  
\- Nearest hospitals database:  
Islamabad: PIMS, Poly Clinic, PMC, Benazir Bhutto Hospital  
Lahore: Services Hospital, Mayo Hospital, Jinnah Hospital  
Rawalpindi: Holy Family Hospital, CMH Rawalpindi  
<br/>Each authority action generates:  
\- A formal dispatch_ticket with unique ticket_id  
\- Written to Firebase at /dispatch_tickets/\[ticket_id\]  
\- Logged in agent_logs as AUTHORITY_NOTIFIED

### TASK 1.3 - Add Predictive Intelligence to Analyst Agent

Improve agent_2_analyst_prompt.md with predictive capabilities:

PREDICTIVE CRISIS MODELING:  
<br/>After assessing current severity, Analyst must predict next 3 time windows:  
<br/>T+15 minutes prediction:  
\- If urban_flooding and rainfall continuing: spread radius increases by 1.5x  
\- If road_accident and no clearance: secondary collision probability 65%  
\- If heatwave and no intervention: hospital admissions increase by 40%  
<br/>T+30 minutes prediction:  
\- Model cascading failures based on current crisis type  
\- urban_flooding → power outage probability if water reaches grid  
\- infrastructure_failure → gas leak probability if explosion involved  
<br/>T+60 minutes prediction:  
\- Full escalation scenario if zero intervention  
\- Estimated total casualties without response  
\- Estimated recovery time  
<br/>Output these as:  
"prediction_timeline": {  
"t_plus_15": "\[specific prediction with numbers\]",  
"t_plus_30": "\[specific prediction with numbers\]",  
"t_plus_60": "\[worst case if no action taken\]"  
}  
<br/>This makes judges see CIRO is PROACTIVE not just REACTIVE.  
<br/>RESOURCE CONFLICT DETECTION:  
If two simultaneous crises both need flood_rescue unit:  
\- Identify the conflict explicitly  
\- Rank crises by: severity score × estimated_people_affected  
\- Assign unit to higher priority  
\- Put lower priority on STANDBY_REQUESTED status  
\- Log: "RESOURCE CONFLICT DETECTED: Unit \[X\] needed by Crisis A and Crisis B.  
Assigned to Crisis A (higher population impact). Crisis B escalated to PDMA."

### TASK 1.4 - Add Live Signal Monitoring Loop

This makes CIRO feel truly autonomous. Add to manager_orchestration.md:

AUTONOMOUS MONITORING LOOP:  
<br/>Every 90 seconds during active crisis:  
1\. Sentinel re-ingests fresh signals  
2\. Compare new signals with active crisis profile  
3\. If 3+ new signals from same location: ESCALATION DETECTED  
4\. Analyst re-scores with updated data  
5\. Commander checks if new resources needed  
6\. Dispatcher executes additional actions if required  
<br/>This creates a feedback loop that judges can watch in real time.  
Log each monitoring cycle to Firebase at /monitoring_cycles/\[cycle_id\]  
<br/>RESOLUTION DETECTION:  
If new signals from crisis zone drop to 0 AND traffic normalizes:  
Analyst outputs CRISIS_RESOLVING status.  
Dispatcher begins close-out sequence:  
\- Mark units as returning_to_base  
\- Update routes as cleared  
\- Write outcome_metrics/resolved_at timestamp  
\- Calculate total_response_time_minutes  
\- Generate resolution_report with full timeline

## PHASE 2 - DATA AND API IMPROVEMENT

**Tool: Codex or Copilot | Priority: HIGH**

### TASK 2.1 - Improve Signal Generator Realism

In backend/services/signal_generator.py add these new signal categories:  
Citizen Reporter Signals (most realistic):

CITIZEN_REPORTER_SIGNALS = \[  
{  
"type": "video_report",  
"text": "Live video: G-10 underpass completely submerged. Cars abandoned. Water level rising fast.",  
"engagement_score": 450,  
"platform": "Twitter/X",  
"has_media": True  
},  
{  
"type": "eye_witness",  
"text": "Main hun G-10 mein abhi. Knee deep pani hai road pe. Bijli bhi gul ho gayi.",  
"engagement_score": 230,  
"platform": "WhatsApp",  
"has_media": False  
}  
\]  
<br/>RESCUE_TEAM_SIGNALS = \[  
{  
"source": "Rescue_1122_Official",  
"text": "Rescue 1122 Islamabad: Teams deployed at G-10. 3 vehicles recovered. Operations ongoing. Citizens advised to avoid area.",  
"credibility": 1.0,  
"is_official": True  
}  
\]  
<br/>TRAFFIC_AUTHORITY_SIGNALS = \[  
{  
"source": "CDA_Traffic",  
"text": "CDA Traffic Advisory: G-10 Markaz Road closed due to flooding. Use Srinagar Highway as alternate.",  
"credibility": 1.0,  
"is_official": True  
}  
\]

When official signals (Rescue 1122, CDA, PDMA) are present:  
\- Sentinel gives them credibility_score of 1.0  
\- Analyst gets confidence boost of +0.20  
\- Analyst notes in reasoning: "Official Rescue 1122 confirmation received - confidence elevated to near-maximum"

### TASK 2.2 - Add Real Traffic API

In backend/services/traffic_service.py create:

"""  
Uses TomTom Traffic API free tier (2500 calls/day free).  
Sign up at developer.tomtom.com for free API key.  
Falls back to mock data if key not available.  
"""  
<br/>ISLAMABAD_ROADS = \[  
{"road": "G-10 Markaz Road", "from": \[33.6844, 73.0479\], "to": \[33.6900, 73.0550\]},  
{"road": "IJP Road", "from": \[33.6700, 73.0400\], "to": \[33.6800, 73.0600\]},  
{"road": "Srinagar Highway", "from": \[33.7000, 73.0300\], "to": \[33.7200, 73.0500\]},  
{"road": "Margalla Road", "from": \[33.7100, 73.0400\], "to": \[33.7300, 73.0700\]},  
\]  
<br/>async def get_traffic_flow(road_segment: dict) -> dict:  
api_key = os.getenv("TOMTOM_API_KEY", "")  
if not api_key:  
return get_mock_traffic(road_segment) # graceful fallback  
<br/>lat, lng = road_segment\["from"\]  
url = f"<https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json>"  
params = {"point": f"{lat},{lng}", "key": api_key}  
\# fetch and map to CIRO format

**Add TOMTOM_API_KEY=your_key_here to .env**

### TASK 2.3 - Add Dispatch Ticket System

Create backend/models/dispatch_ticket.py:

from pydantic import BaseModel  
from datetime import datetime  
<br/>class DispatchTicket(BaseModel):  
ticket*id: str # TICKET*\[6char_hex\]  
crisis_id: str  
authority: str # POLICE / FIRE / PDMA / NDMA / NHA / HOSPITAL  
authority_contact: str # Emergency number  
priority: str # P1_IMMEDIATE / P2_URGENT / P3_STANDARD  
incident_type: str  
location: str  
coordinates: dict # lat, lng  
message: str # Formal dispatch message  
estimated_units_needed: int  
issued_by: str # Commander Agent  
issued_at: str  
status: str # ISSUED / ACKNOWLEDGED / UNITS_DISPATCHED / ON_SCENE  
<br/>AUTHORITY_CONTACTS = {  
"POLICE": "15",  
"FIRE": "16",  
"RESCUE_1122": "1122",  
"PDMA": "0800-02345",  
"NDMA": "1700",  
"EDHI": "115",  
"CHIPPA": "1020"  
}

Add endpoint GET /api/dispatch/tickets and GET /api/dispatch/tickets/{crisis_id} to expose tickets to Flutter.

## PHASE 3 - FLUTTER UI FOR NEW FEATURES

**Tool: Copilot Pro in VS Code | Priority: MEDIUM**

### TASK 3.1 - Dispatch Tickets Screen

Create flutter_app/lib/screens/dispatch_tickets_screen.dart:  
\- Shows all dispatch tickets from Firebase /dispatch_tickets  
\- Each ticket card shows: authority name, priority badge, location, status, issued time  
\- Color coding: P1 = red, P2 = orange, P3 = yellow  
\- Status timeline: ISSUED → ACKNOWLEDGED → UNITS_DISPATCHED → ON_SCENE  
\- Filter by authority type

### TASK 3.2 - Prediction Timeline Widget

Add to crisis_detail_screen.dart a new section showing the 3-window prediction:

┌─────────────────────────────────────┐  
│ ⏱ PREDICTIVE TIMELINE │  
├─────────────────────────────────────┤  
│ T+15min: Flood spread to 2.5x area │  
│ T+30min: Power outage probable 70% │  
│ T+60min: 4,500 people affected │  
│ without intervention │  
└─────────────────────────────────────┘

### TASK 3.3 - Live Monitoring Cycle Indicator

Add to agent_logs_screen.dart:  
\- Show monitoring cycle counter "Cycle 3 of ongoing monitoring"  
\- Progress bar showing time until next Sentinel scan  
\- Green pulse dot when cycle is running

### TASK 3.4 - Authority Coordination Panel

Add to dashboard_screen.dart a new section below units:

AUTHORITY COORDINATION  
┌──────────┬──────────┬──────────┐  
│ 🚓 Police │ 🚒 Fire │ 🏥 PDMA │  
│ NOTIFIED │ STANDBY │ ACTIVE │  
└──────────┴──────────┴──────────┘

Updates in real time from Firebase /dispatch_tickets.

## PHASE 4 - ADVANCED SCENARIOS

Add these to repo, Antigravity will use them

### TASK 4.1 - Cascading Disaster Scenario

Create backend/scenarios/cascading_flood_power.json:

{  
"scenario_id": "cascading_flood_power",  
"scenario_name": "Cascading Crisis - Flood Triggers Power Failure",  
"crisis_type": "cascading",  
"stages": \[  
{  
"stage": 1,  
"time_offset_minutes": 0,  
"crisis_type": "urban_flooding",  
"location": "G-10, Islamabad",  
"severity": "HIGH"  
},  
{  
"stage": 2,  
"time_offset_minutes": 20,  
"crisis_type": "infrastructure_failure",  
"location": "I-8 Grid Station, Islamabad",  
"severity": "HIGH",  
"trigger": "flooding_reached_electrical_grid"  
},  
{  
"stage": 3,  
"time_offset_minutes": 40,  
"crisis_type": "heatwave_amplified",  
"location": "Multiple sectors, Islamabad",  
"severity": "CRITICAL",  
"trigger": "power_outage_disables_cooling"  
}  
\]  
}

This is the most impressive demo scenario - shows CIRO detecting one crisis, predicting the next, and preparing before it happens. Judges will love this.

### TASK 4.2 - Multi-City Scenario

Create backend/scenarios/multi_city_crisis.json:

{  
"scenario_id": "multi_city_crisis",  
"scenario_name": "Simultaneous Crises - Islamabad + Lahore",  
"crisis_type": "multi_city",  
"crises": \[  
{  
"crisis_type": "urban_flooding",  
"location": "G-10, Islamabad",  
"severity": "HIGH"  
},  
{  
"crisis_type": "heatwave",  
"location": "Data Darbar, Lahore",  
"severity": "CRITICAL"  
}  
\],  
"resource_conflict": true,  
"expected_behavior": "CIRO detects resource conflict, prioritizes by casualties, notifies NDMA for coordination"  
}

This demonstrates multi-agent coordination under pressure - directly hits the 20% Agentic Reasoning criteria.

## PHASE 5 - DOCUMENTATION (Do This Last)

Tool: Manual writing, Copilot can help  
Create README.md with these sections:

\# CIRO - Crisis Intelligence & Response Orchestrator  
<br/>\## System Architecture  
\[diagram or description of 4-agent pipeline\]  
<br/>\## Antigravity Usage  
\- Agent 1 Sentinel: signal ingestion and normalization  
\- Agent 2 Analyst: crisis reasoning and severity scoring  
\- Agent 3 Commander: authority dispatch and resource planning  
\- Agent 4 Dispatcher: execution and outcome monitoring  
\- Manager: orchestrates full pipeline with monitoring loop  
<br/>\## APIs Used  
\- Open-Meteo: real weather data (free, no key)  
\- TomTom Traffic: real congestion data (free tier)  
\- NewsAPI: crisis news signals (free tier)  
\- Firebase Realtime Database: live sync  
<br/>\## Key Features  
\- Roman Urdu signal normalization  
\- 3-window predictive timeline  
\- Authority dispatch (Police, Fire, PDMA, NDMA, NHA, Hospitals)  
\- Cascading crisis detection  
\- Multi-city simultaneous crisis handling  
\- Bilingual alerts (English + Urdu)  
\- Before/after outcome visualization  
<br/>\## How to Run  
\[setup instructions\]

# ANTIGRAVITY PROMPT FOR YOUR TEAMMATE

Tell him to paste this into his fresh Antigravity account:

You are working on CIRO - Crisis Intelligence and Response Orchestrator.  
<br/>STEP 1: Read CIRO_Implementation_Blueprint.pdf completely.  
<br/>STEP 2: Read all files in antigravity/ folder -  
these are existing agent prompts.  
<br/>STEP 3: Improve the system with these specific enhancements:  
<br/>A) Add authority dispatch system to Commander agent:  
Police (15), Fire (16), Rescue 1122, PDMA, NDMA, NHA, Hospitals.  
Each authority gets a formal dispatch_ticket written to Firebase.  
<br/>B) Add predictive timeline to Analyst agent:  
T+15, T+30, T+60 minute predictions with specific numbers.  
<br/>C) Add resource conflict detection:  
If two crises need same unit, rank by severity x population impact.  
Assign to higher priority, escalate lower to PDMA.  
<br/>D) Add autonomous monitoring loop to Manager:  
Re-run Sentinel every 90 seconds during active crisis.  
Detect escalation or resolution automatically.  
<br/>E) Add cascading crisis detection:  
If flood detected near electrical grid → pre-alert power authority.  
If heatwave + power outage → immediately activate cooling centers.  
<br/>STEP 4: Run full pipeline test using urban_flood_g10 scenario.  
Output complete Agent Trace showing all 4 agent decisions.  
<br/>STEP 5: Run cascading scenario showing CIRO predicting  
the power failure BEFORE it happens based on flood spread prediction.  
<br/>Keep everything consistent with blueprint architecture.  
Write all outputs to Firebase paths as specified in blueprint Section 6.

# PRIORITY ORDER FOR TEAMMATE

| **Day** | **Task**                                          | **Tool**      |
| ------- | ------------------------------------------------- | ------------- |
| Day 1   | Run Antigravity prompt above, get agent trace     | Antigravity   |
| Day 1   | Add authority dispatch system                     | Antigravity   |
| Day 2   | Add predictive timeline and cascading detection   | Antigravity   |
| Day 2   | Improve signal_generator.py with official signals | Codex/Copilot |
| Day 3   | Add dispatch tickets screen in Flutter            | Copilot       |
| Day 3   | Add prediction timeline widget in Flutter         | Copilot       |
| Day 4   | Create cascading and multi-city scenarios         | Manual/Codex  |
| Day 4   | Write README documentation                        | Manual        |
| Day 5   | Full end-to-end demo test                         | All tools     |

# THE ONE THING THAT WINS

The single most impressive thing you can show judges is this sequence:

**CIRO detects flooding → predicts power failure in 30 minutes → pre-dispatches WAPDA before failure happens → failure occurs → CIRO says "as predicted, escalating" → activates cooling centers → notifies hospitals → all with full reasoning visible in agent logs**

That is proactive autonomous intelligence. No other team will have that.