from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from services.firebase_service import FirebaseService
from datetime import datetime, timezone

router = APIRouter()
firebase = FirebaseService()


class DispatchRequest(BaseModel):
    unit_id: str
    destination: str
    crisis_id: str
    eta_minutes: int = 10
    destination_lat: Optional[float] = None
    destination_lng: Optional[float] = None


# Default unit data (mirrors Firebase baseline)
DEFAULT_UNITS = {
    "1122-ISB-01": {
        "unit_id": "1122-ISB-01",
        "name": "Rescue 1122 — Alpha Team",
        "type": "general_rescue",
        "status": "available",
        "base_lat": 33.7294,
        "base_lng": 73.0931,
        "current_lat": 33.7294,
        "current_lng": 73.0931,
        "destination": None,
        "eta_minutes": None,
        "assigned_crisis_id": None
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
        "destination": None,
        "eta_minutes": None,
        "assigned_crisis_id": None
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
        "destination": None,
        "eta_minutes": None,
        "assigned_crisis_id": None
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
        "destination": None,
        "eta_minutes": None,
        "assigned_crisis_id": None
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
        "destination": None,
        "eta_minutes": None,
        "assigned_crisis_id": None
    }
}


@router.get("/available")
def get_available_units():
    """
    Lists all Rescue units and their status.
    Tries Firebase first; falls back to default data.
    """
    units = firebase.get("units")
    if not units:
        units = DEFAULT_UNITS
    return {
        "units": list(units.values()) if isinstance(units, dict) else [],
        "total": len(units),
        "available": sum(
            1 for u in units.values()
            if isinstance(u, dict) and u.get("status") == "available"
        )
    }


@router.post("/dispatch")
def dispatch_unit(request: DispatchRequest):
    """
    Simulates dispatching a unit to a crisis location.
    Updates Firebase with new unit status.
    """
    now = datetime.now(timezone.utc).isoformat()

    update_data = {
        "status": "dispatched",
        "destination": request.destination,
        "eta_minutes": request.eta_minutes,
        "assigned_crisis_id": request.crisis_id,
        "last_updated": now
    }

    if request.destination_lat and request.destination_lng:
        # Move unit to midpoint between base and destination
        unit_data = firebase.get(f"units/{request.unit_id}")
        if unit_data:
            base_lat = unit_data.get("base_lat", 33.7)
            base_lng = unit_data.get("base_lng", 73.0)
            update_data["current_lat"] = (base_lat + request.destination_lat) / 2
            update_data["current_lng"] = (base_lng + request.destination_lng) / 2

    firebase.update(f"units/{request.unit_id}", update_data)

    return {
        "status": "dispatched",
        "unit_id": request.unit_id,
        "destination": request.destination,
        "eta_minutes": request.eta_minutes,
        "dispatched_at": now
    }
