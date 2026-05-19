from fastapi import APIRouter, HTTPException
from services.scenario_loader import ScenarioLoader
from services.firebase_service import FirebaseService

router = APIRouter()
loader = ScenarioLoader()
firebase = FirebaseService()


@router.get("/scenarios")
def list_scenarios():
    """Lists all available demo crisis scenarios."""
    return {"scenarios": loader.list_available_scenarios()}


@router.post("/trigger/{scenario_name}")
def trigger_scenario(scenario_name: str):
    """
    Loads a scenario JSON and injects signals into the mock feed.
    Also sets system_state.mode = "simulation" in Firebase.
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
    # Also deactivate crisis mode on the signal generator
    loader.deactivate_scenario()
    firebase.reset_to_baseline()
    return {"status": "reset_complete", "message": "System returned to monitoring baseline."}


@router.get("/status")
def get_simulation_status():
    """Returns current simulation/system status."""
    status = firebase.get("system_state")
    if not status:
        return {
            "mode": "monitoring",
            "last_updated": loader.now_iso(),
            "active_crisis_count": 0,
            "signal_ingestion_active": True,
            "firebase_connected": firebase._is_connected
        }
    status["firebase_connected"] = firebase._is_connected
    return status
