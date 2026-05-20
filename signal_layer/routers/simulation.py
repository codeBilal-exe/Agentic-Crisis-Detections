from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta, timezone

from services.firebase_service import FirebaseService
from services.scenario_loader import ScenarioLoader


router = APIRouter()
loader = ScenarioLoader()
firebase = FirebaseService()


def _iso_with_offset(minutes: int) -> str:
    return (datetime.now(timezone.utc) + timedelta(minutes=minutes)).isoformat()


@router.get("/scenarios")
def list_scenarios():
    return {"scenarios": loader.list_available_scenarios()}


@router.post("/trigger/{scenario_name}")
def trigger_scenario(scenario_name: str):
    scenario = loader.load_scenario(scenario_name)
    if not scenario:
        raise HTTPException(status_code=404, detail=f"Scenario '{scenario_name}' not found")

    loader.activate_scenario(scenario)
    firebase.update(
        "system_state",
        {
            "mode": "simulation",
            "last_updated": loader.now_iso(),
            "active_crisis_count": 1,
        },
    )

    return {
        "status": "scenario_activated",
        "scenario": scenario_name,
        "signal_count_injected": scenario.get("signal_count", 0),
        "message": "Signals injected. Run Antigravity pipeline to detect and respond.",
    }


@router.post("/reset")
def reset_simulation():
    loader.deactivate_scenario()
    firebase.reset_to_baseline()
    return {"status": "reset_complete", "message": "System returned to monitoring baseline."}


@router.post("/seed-phase3")
def seed_phase3_demo_data():
    """
    Seeds deterministic Phase 3 data into Firebase for fast UI/API validation.
    """
    now = datetime.now(timezone.utc)
    now_iso = now.isoformat()
    crisis_id = "crisis_phase3_demo"

    active_crisis = {
        "crisis_id": crisis_id,
        "crisis_type": "urban_flooding",
        "severity": "HIGH",
        "confidence": 0.93,
        "confidence_label": "HIGH",
        "detected_at": (now - timedelta(minutes=12)).isoformat(),
        "affected_area": {
            "name": "G-10 Sector, Islamabad",
            "lat": 33.6844,
            "lng": 73.0479,
            "radius_km": 2.0,
        },
        "impact_assessment": {
            "estimated_people_affected": 4500,
            "roads_blocked": ["G-10 Markaz Road", "IJP Road Junction"],
            "vehicles_stranded": True,
            "casualties_likely": True,
        },
        "reasoning_summary": (
            "Flood signals corroborated by Rescue 1122 and CDA Traffic. "
            "High congestion and heavy rainfall indicate rapid spread risk."
        ),
        "prediction_timeline": {
            "t_plus_15": "Flood spread to 2.5x area, adjacent roads likely submerged.",
            "t_plus_30": "Power outage probable 70% as water approaches cable ducts.",
            "t_plus_60": "Up to 4,500 people affected without intervention.",
        },
        "status": "active",
        "plan_id": "plan_phase3_demo",
    }

    dispatch_tickets = {
        "ticket_phase3_001": {
            "ticket_id": "ticket_phase3_001",
            "crisis_id": crisis_id,
            "authority": "POLICE",
            "authority_type": "police",
            "priority": "P1_IMMEDIATE",
            "incident_type": "urban_flooding",
            "location": "G-10 Markaz Road, Islamabad",
            "coordinates": {"lat": 33.6848, "lng": 73.0485},
            "notification_message": "Police unit required for flood cordon support.",
            "authority_contact": "15",
            "estimated_units_needed": 2,
            "issued_by": "Commander Agent",
            "sent_at": _iso_with_offset(-8),
            "status": "ON_SCENE",
        },
        "ticket_phase3_002": {
            "ticket_id": "ticket_phase3_002",
            "crisis_id": crisis_id,
            "authority": "FIRE",
            "authority_type": "fire",
            "priority": "P2_URGENT",
            "incident_type": "infrastructure_failure",
            "location": "I-8 Grid Feeder (Support), Islamabad",
            "coordinates": {"lat": 33.6611, "lng": 73.0769},
            "notification_message": "Fire standby for transformer short-circuit risk.",
            "authority_contact": "16",
            "estimated_units_needed": 1,
            "issued_by": "Commander Agent",
            "sent_at": _iso_with_offset(-6),
            "status": "ACKNOWLEDGED",
        },
        "ticket_phase3_003": {
            "ticket_id": "ticket_phase3_003",
            "crisis_id": crisis_id,
            "authority": "PDMA",
            "authority_type": "pdma",
            "priority": "P3_STANDARD",
            "incident_type": "urban_flooding",
            "location": "G-10 Community Center, Islamabad",
            "coordinates": {"lat": 33.6850, "lng": 73.0490},
            "notification_message": "PDMA relief point activation request.",
            "authority_contact": "0800-02345",
            "estimated_units_needed": 1,
            "issued_by": "Commander Agent",
            "sent_at": _iso_with_offset(-5),
            "status": "UNITS_DISPATCHED",
        },
        "ticket_phase3_004": {
            "ticket_id": "ticket_phase3_004",
            "crisis_id": crisis_id,
            "authority": "HOSPITAL",
            "authority_type": "hospital",
            "priority": "P1_IMMEDIATE",
            "incident_type": "medical_support",
            "location": "PIMS Hospital, Islamabad",
            "coordinates": {"lat": 33.7215, "lng": 73.0433},
            "notification_message": "Prepare 16 trauma beds for incoming patients.",
            "authority_contact": "N/A",
            "estimated_units_needed": 1,
            "issued_by": "Commander Agent",
            "sent_at": _iso_with_offset(-3),
            "status": "ISSUED",
        },
    }

    monitoring_cycles = {
        "cycle_phase3_001": {
            "cycle_id": "cycle_phase3_001",
            "cycle_number": 1,
            "crisis_id": crisis_id,
            "started_at": _iso_with_offset(-4),
            "completed_at": _iso_with_offset(-3),
            "next_cycle_scheduled_at": _iso_with_offset(-1),
            "verdict": "ESCALATION",
            "new_signals_count": 4,
            "escalation_detected": True,
            "cycle_summary": "Cycle 1 escalation detected; backup resources advised.",
        },
        "cycle_phase3_002": {
            "cycle_id": "cycle_phase3_002",
            "cycle_number": 2,
            "crisis_id": crisis_id,
            "started_at": _iso_with_offset(-2),
            "completed_at": _iso_with_offset(-1),
            "next_cycle_scheduled_at": _iso_with_offset(1),
            "verdict": "STABLE",
            "new_signals_count": 1,
            "escalation_detected": False,
            "cycle_summary": "Cycle 2 stable; monitoring continues.",
        },
    }

    agent_logs = {
        "log_phase3_analyst": {
            "timestamp": _iso_with_offset(-9),
            "agent": "Analyst",
            "message": "Crisis scored HIGH with 0.93 confidence. Prediction timeline updated.",
            "data_ref": crisis_id,
            "type": "CRISIS_PROFILE",
        },
        "log_phase3_commander": {
            "timestamp": _iso_with_offset(-7),
            "agent": "Commander",
            "message": "Action plan generated with dispatch + authority notifications.",
            "data_ref": "plan_phase3_demo",
            "type": "ACTION_PLAN",
        },
        "log_phase3_manager": {
            "timestamp": _iso_with_offset(-1),
            "agent": "Manager",
            "message": "Monitoring cycle 2 completed. Verdict: STABLE. Next cycle in 90s.",
            "data_ref": "cycle_phase3_002",
            "type": "MONITORING_CYCLE",
        },
    }

    units = {
        "1122-ISB-01": {
            "status": "standby",
            "destination": "G-9 Entry Point",
            "assigned_crisis_id": crisis_id,
            "last_updated": now_iso,
        },
        "1122-ISB-04": {
            "status": "dispatched",
            "destination": "G-10 Markaz Road",
            "eta_minutes": 6,
            "assigned_crisis_id": crisis_id,
            "last_updated": now_iso,
        },
        "pdma-team-01": {
            "status": "active",
            "destination": "G-10 Community Center",
            "assigned_crisis_id": crisis_id,
            "last_updated": now_iso,
        },
    }

    alerts = {
        "alert_phase3_001": {
            "alert_id": "alert_phase3_001",
            "crisis_id": crisis_id,
            "created_at": _iso_with_offset(-5),
            "severity": "HIGH",
            "title": "FLOOD ALERT - G-10 Islamabad",
            "body": "Avoid G-10 Markaz Road. Use Srinagar Highway alternate route.",
            "urdu_body": "G-10 Markaz Road se bachein. Srinagar Highway istemal karein.",
            "channels_sent": ["in_app", "sms_mock", "pdma_dashboard"],
            "acknowledged": False,
        }
    }

    outcome_metrics = {
        "before": {
            "congestion_level": 94,
            "units_available": 5,
            "alerts_active": 0,
            "estimated_stranded_vehicles": 34,
        },
        "after": {
            "congestion_level": 40,
            "units_available": 2,
            "alerts_active": 1,
            "estimated_stranded_vehicles": 6,
            "authorities_notified": 4,
            "hospitals_alerted": 1,
        },
        "resolution_time_minutes": 45,
        "last_updated": now_iso,
    }

    firebase.set(f"active_crises/{crisis_id}", active_crisis)
    firebase.set("dispatch_tickets", dispatch_tickets)
    firebase.set("monitoring_cycles", monitoring_cycles)
    firebase.set("agent_logs", agent_logs)
    firebase.update("units", units)
    firebase.set("alerts", alerts)
    firebase.set("outcome_metrics", outcome_metrics)
    firebase.update(
        "system_state",
        {
            "mode": "crisis_active",
            "active_crisis_count": 1,
            "signal_ingestion_active": True,
            "last_updated": now_iso,
            "phase3_seeded_at": now_iso,
        },
    )

    return {
        "status": "phase3_seed_complete",
        "crisis_id": crisis_id,
        "dispatch_ticket_count": len(dispatch_tickets),
        "monitoring_cycle_count": len(monitoring_cycles),
        "firebase": firebase.diagnostics,
    }


@router.get("/status")
def get_simulation_status():
    status = firebase.get("system_state")
    if not status:
        return {
            "mode": "monitoring",
            "last_updated": loader.now_iso(),
            "active_crisis_count": 0,
            "signal_ingestion_active": True,
            "firebase_connected": firebase._is_connected,
            "firebase": firebase.diagnostics,
        }
    status["firebase_connected"] = firebase._is_connected
    status["firebase"] = firebase.diagnostics
    return status
