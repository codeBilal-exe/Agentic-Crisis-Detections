from pydantic import BaseModel
from typing import Optional, List, Dict, Any


class ActionTarget(BaseModel):
    unit_id: Optional[str] = None
    unit_name: Optional[str] = None
    unit_type: Optional[str] = None
    location: Optional[Dict[str, Any]] = None


class AlternateRoute(BaseModel):
    name: str
    waypoints: List[Dict[str, float]] = []


class Action(BaseModel):
    action_id: str
    action_type: str  # "dispatch_unit" | "traffic_reroute" | "broadcast_alert" | "open_relief_point" | "agency_coordination"
    priority: int
    target: Optional[ActionTarget] = None
    instruction: str = ""
    coordinates: Optional[Dict[str, float]] = None
    affected_road: Optional[str] = None
    alternate_route: Optional[AlternateRoute] = None
    alert_text: Optional[str] = None
    urdu_alert_text: Optional[str] = None
    target_channels: Optional[List[str]] = None
    severity: Optional[str] = None
    additional_data: Optional[Dict[str, Any]] = None


class ActionPlan(BaseModel):
    plan_id: str
    crisis_id: str
    generated_at: str
    response_protocol: str
    actions: List[Action] = []
    estimated_resolution_minutes: int = 45
    coordinating_agencies: List[str] = []
    commander_brief: str = ""


class ExecutionStep(BaseModel):
    step: int
    action_id: str
    action_type: str = ""
    status: str = "EXECUTED"
    firebase_path: str = ""
    change_summary: str = ""
    change: Optional[Dict[str, Any]] = None
    timestamp: str = ""


class ExecutionLog(BaseModel):
    log_id: str
    plan_id: str
    crisis_id: str
    executed_at: str
    execution_steps: List[ExecutionStep] = []
    overall_status: str = "COMPLETE"
    firebase_sync_confirmed: bool = True
    simulation_summary: str = ""
