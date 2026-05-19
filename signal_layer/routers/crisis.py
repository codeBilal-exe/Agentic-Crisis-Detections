from fastapi import APIRouter, HTTPException
from services.firebase_service import FirebaseService
from services.scenario_loader import get_shared_generator
from services.crisis_escalation_engine import check_escalation_needed
from models.crisis import CrisisInjectRequest
from datetime import datetime, timezone
import uuid

router = APIRouter()
firebase = FirebaseService()


@router.post("/inject")
def inject_crisis(request: CrisisInjectRequest):
    """
    Injects a pre-built crisis scenario into the system.
    Now actually activates crisis mode on the signal generator and writes to Firebase.
    """
    generator = get_shared_generator()

    # Activate crisis mode on the signal generator
    location = request.location if hasattr(request, 'location') else "Islamabad"
    generator.activate_crisis_mode(request.crisis_type, location)

    # Write crisis profile to Firebase
    crisis_id = f"crisis_{uuid.uuid4().hex[:6]}"
    crisis_data = {
        "crisis_id": crisis_id,
        "crisis_type": request.crisis_type,
        "severity": request.severity if hasattr(request, 'severity') else "HIGH",
        "status": "active",
        "detected_at": datetime.now(timezone.utc).isoformat(),
        "source": "manual_injection",
        "scenario_name": request.scenario_name,
    }

    firebase.set(f"active_crises/{crisis_id}", crisis_data)
    firebase.update("system_state", {
        "mode": "crisis_active",
        "active_crisis_count": 1,
        "last_updated": datetime.now(timezone.utc).isoformat(),
    })

    return {
        "status": "crisis_injected",
        "crisis_id": crisis_id,
        "scenario": request.scenario_name,
        "crisis_type": request.crisis_type,
        "message": "Crisis scenario injected and activated. Signal generator now producing crisis signals. Run Antigravity pipeline to detect and respond."
    }


@router.get("/active")
def get_active_crises():
    """
    Lists all active crisis profiles from Firebase.
    Used by Commander Agent to see current crises.
    """
    crises = firebase.get("active_crises")
    if not crises:
        return {"crises": [], "count": 0}
    active = {k: v for k, v in crises.items() if isinstance(v, dict) and v.get("status") == "active"}
    return {"crises": list(active.values()), "count": len(active)}


@router.post("/resolve/{crisis_id}")
def resolve_crisis(crisis_id: str):
    """
    Marks a crisis as resolved.
    Used by Dispatcher Agent after response is complete.
    """
    # Deactivate crisis mode on signal generator
    generator = get_shared_generator()
    generator.deactivate_crisis_mode()

    firebase.update(f"active_crises/{crisis_id}", {
        "status": "resolved",
        "resolved_at": datetime.now(timezone.utc).isoformat()
    })
    firebase.update("system_state", {
        "mode": "monitoring",
        "active_crisis_count": 0,
        "last_updated": datetime.now(timezone.utc).isoformat(),
    })
    return {
        "status": "resolved",
        "crisis_id": crisis_id,
        "resolved_at": datetime.now(timezone.utc).isoformat()
    }


@router.get("/escalation-check/{crisis_id}")
def check_crisis_escalation(crisis_id: str):
    """
    Check if an active crisis needs escalation based on new signals,
    time elapsed, and trigger keyword analysis.
    """
    # Get the crisis profile from Firebase
    crisis_profile = firebase.get(f"active_crises/{crisis_id}")
    if not crisis_profile:
        raise HTTPException(status_code=404, detail=f"Crisis {crisis_id} not found")

    if crisis_profile.get("status") != "active":
        return {
            "escalation_needed": False,
            "reason": "Crisis is no longer active",
            "crisis_id": crisis_id,
        }

    # Get recent signals from the signal generator
    generator = get_shared_generator()
    recent_signals = generator.get_social_signals(limit=10)

    # Run escalation check
    result = check_escalation_needed(crisis_profile, recent_signals)
    result["crisis_id"] = crisis_id
    return result
