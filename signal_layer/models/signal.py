from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class LocationData(BaseModel):
    area: str
    city: str
    lat: float
    lng: float


class SignalMetadata(BaseModel):
    platform: Optional[str] = None
    engagement_score: Optional[int] = None
    language_detected: Optional[str] = None


class RawSignal(BaseModel):
    signal_id: str
    source: str  # "social_media" | "weather" | "traffic" | "citizen_report"
    timestamp: str
    raw_text: str
    normalized_text: str
    location: LocationData
    metadata: SignalMetadata


class WeatherAlert(BaseModel):
    alert_id: str
    type: str  # "HEAVY_RAINFALL" | "CLEAR" | "FOG" | "EXTREME_HEAT"
    severity: str  # "NONE" | "WATCH" | "WARNING" | "EMERGENCY"
    area: str
    message: str
    issued_by: str = "Pakistan Meteorological Department (Mock)"
    valid_until: Optional[str] = None
    rainfall_mm_expected: Optional[int] = None
    temperature_c: Optional[int] = None
    visibility_m: Optional[int] = None


class TrafficSegment(BaseModel):
    segment_id: str
    road_name: str
    congestion_score: int  # 0-100
    anomaly_detected: bool
    anomaly_type: Optional[str] = None  # "SEVERE_CONGESTION" | "HIGH_CONGESTION"
    from_coords: Optional[dict] = Field(None, alias="from")
    to_coords: Optional[dict] = Field(None, alias="to")
    direction: Optional[str] = None


class SignalBundle(BaseModel):
    bundle_id: str
    generated_at: str
    signals: List[RawSignal] = []
    signal_count: int = 0
    dominant_location: Optional[str] = None
    dominant_event_type: Optional[str] = None
    time_window_minutes: int = 30
