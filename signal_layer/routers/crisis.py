from fastapi import APIRouter, HTTPException
from services.firebase_service import FirebaseService
from models.crisis import CrisisInjectRequest
from datetime import datetime, timezone

router = APIRouter()
firebase = FirebaseService()


@router.post("/inject")
def inject_crisis(request: CrisisInjectRequest):
    """
    Injects a pre-built crisis scenario into the system.
    Used by Admin/Demo to manually trigger crisis profiles.
    """
    return {
        "status": "crisis_injected",
        "scenario": request.scenario_name,
        "message": "Crisis scenario injected. Run Antigravity pipeline to detect and respond."
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
    firebase.update(f"active_crises/{crisis_id}", {
        "status": "resolved",
        "resolved_at": datetime.now(timezone.utc).isoformat()
    })
    return {
        "status": "resolved",
        "crisis_id": crisis_id,
        "resolved_at": datetime.now(timezone.utc).isoformat()
    }
