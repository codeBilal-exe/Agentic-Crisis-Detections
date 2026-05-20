import os
import sys
import uuid
from datetime import datetime, timezone

# Add current directory to path so we can import services
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from services.firebase_service import FirebaseService

def main():
    print("Starting pipeline test run (Firebase writes)...")
    firebase = FirebaseService()
    
    if not firebase._is_connected:
        print("ERROR: Firebase not connected!")
        return

    now = datetime.now(timezone.utc).isoformat()
    crisis_id = f"crisis_{uuid.uuid4().hex[:6]}"
    plan_id = f"plan_{uuid.uuid4().hex[:6]}"
    reroute_id = f"reroute_{uuid.uuid4().hex[:6]}"
    alert_id = f"alert_{uuid.uuid4().hex[:6]}"
    relief_id = f"relief_{uuid.uuid4().hex[:6]}"
    log_id = f"log_{uuid.uuid4().hex[:6]}"

    print(f"Using Crisis ID: {crisis_id}")

    try:
        # Analyst writes
        firebase.set(f"/active_crises/{crisis_id}", {
            "crisis_id": crisis_id,
            "detected_at": now,
            "crisis_type": "urban_flooding",
            "severity": "CRITICAL",
            "confidence": 0.98,
            "status": "active"
        })
        print("Analyst write 1 successful")

        firebase.update("/system_state", {
            "mode": "crisis_active",
            "active_crisis_count": 1,
            "last_updated": now
        })
        print("Analyst write 2 successful")

        firebase.update("/outcome_metrics/before", {
            "congestion_level": 96,
            "units_available": 5,
            "alerts_active": 0,
            "estimated_stranded_vehicles": 35
        })
        print("Analyst write 3 successful")

        # Dispatcher writes
        # Step 1: Dispatch Unit
        firebase.update("/units/1122-ISB-04", {
            "status": "dispatched",
            "destination": "G-10 Markaz Road",
            "eta_minutes": 8,
            "assigned_crisis_id": crisis_id,
            "current_lat": 33.68,
            "current_lng": 73.05,
            "last_updated": now
        })
        print("Dispatcher write 1 successful")

        # Update crisis with plan_id
        firebase.update(f"/active_crises/{crisis_id}", {
            "plan_id": plan_id
        })
        print("Dispatcher write 1b successful")

        # Step 2: Traffic Reroute
        firebase.set(f"/routes/active_reroutes/{reroute_id}", {
            "reroute_id": reroute_id,
            "crisis_id": crisis_id,
            "blocked_road": "G-10 Markaz Road",
            "alternate_route_name": "Srinagar Highway",
            "status": "active",
            "created_at": now,
            "waypoints": [{"lat": 33.6900, "lng": 73.0400}, {"lat": 33.7000, "lng": 73.0600}]
        })
        print("Dispatcher write 2 successful")

        # Step 3: Broadcast Alert
        firebase.set(f"/alerts/{alert_id}", {
            "alert_id": alert_id,
            "crisis_id": crisis_id,
            "created_at": now,
            "severity": "CRITICAL",
            "title": "🚨 FLOOD ALERT - G-10 Islamabad",
            "body": "Heavy flooding on G-10 Markaz Road.",
            "urdu_body": "G-10 Markaz Road par seilab hai.",
            "channels_sent": ["in_app", "sms_mock"],
            "acknowledged": False
        })
        print("Dispatcher write 3 successful")

        firebase.update("/system_state", {
            "active_crisis_count": 1
        })
        print("Dispatcher write 3b successful")

        # Step 4: Relief Point
        firebase.set(f"/active_crises/{crisis_id}/relief_points/{relief_id}", {
            "name": "G-10 Community Center",
            "lat": 33.6850,
            "lng": 73.0490,
            "status": "activated",
            "activated_at": now,
            "coordinating_agency": "PDMA"
        })
        print("Dispatcher write 4 successful")

        # Step 5: Agency Coordination log
        firebase.set(f"/agent_logs/{log_id}", {
            "timestamp": now,
            "agent": "Commander via Dispatcher",
            "message": "PDMA please dispatch pumps",
            "data_ref": plan_id,
            "type": "coordination_message"
        })
        print("Dispatcher write 5 successful")

        # Step 6: Update Outcome Metrics After
        firebase.update("/outcome_metrics/after", {
            "congestion_level": 38,
            "units_available": 4,
            "alerts_active": 1,
            "estimated_stranded_vehicles": 5
        })
        firebase.update("/outcome_metrics", {
            "resolution_time_minutes": 45,
            "last_updated": now
        })
        print("Dispatcher write 6 successful")

        print("All writes successful! No Firebase errors detected.")

    except Exception as e:
        print(f"FIREBASE WRITE ERROR OCCURRED: {e}")

if __name__ == "__main__":
    main()
