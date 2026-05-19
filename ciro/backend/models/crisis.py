from pydantic import BaseModel
from typing import Optional, List


class AffectedArea(BaseModel):
    name: str
    lat: float
    lng: float
    radius_km: float = 2.0


class ImpactAssessment(BaseModel):
    estimated_people_affected: int = 0
    roads_blocked: List[str] = []
    vehicles_stranded: bool = False
    casualties_likely: bool = False
    infrastructure_damage: str = "none"  # "none" | "minor" | "moderate" | "severe"


class CrisisProfile(BaseModel):
    crisis_id: str
    detected_at: str
    crisis_type: str  # "urban_flooding" | "road_accident" | "heatwave" | "infrastructure_failure" | "unknown"
    severity: str  # "LOW" | "MEDIUM" | "HIGH" | "CRITICAL"
    confidence: float  # 0.0 to 1.0
    confidence_label: str  # "LOW" | "MEDIUM" | "HIGH"
    affected_area: AffectedArea
    impact_assessment: ImpactAssessment
    supporting_signals: List[str] = []
    reasoning_summary: str = ""
    status: str = "active"  # "active" | "resolved" | "false_positive"


class CrisisInjectRequest(BaseModel):
    scenario_name: str
    crisis_type: Optional[str] = None
    location: Optional[str] = None
    severity: Optional[str] = None
