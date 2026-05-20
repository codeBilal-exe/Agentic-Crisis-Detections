from fastapi import APIRouter, HTTPException

from services.firebase_service import FirebaseService
from services.scenario_loader import ScenarioLoader


router = APIRouter()
loader = ScenarioLoader()
firebase = FirebaseService()


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
        }
    status["firebase_connected"] = firebase._is_connected
    return status
