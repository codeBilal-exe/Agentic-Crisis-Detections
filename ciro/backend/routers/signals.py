from fastapi import APIRouter, Query
from services.scenario_loader import get_shared_generator

router = APIRouter()


@router.get("/social")
def get_social_signals(limit: int = Query(default=10, le=50)):
    """
    Returns the most recent mock social media signals.
    In crisis scenario mode, these contain flooding/accident reports in Roman Urdu and English.
    """
    generator = get_shared_generator()
    return {
        "source": "social_media_mock",
        "signals": generator.get_social_signals(limit)
    }


@router.get("/weather")
def get_weather_alerts():
    """
    Returns simulated weather alert data for major Pakistani cities.
    Severity: NONE | WATCH | WARNING | EMERGENCY
    """
    generator = get_shared_generator()
    return {
        "source": "pakistan_met_department_mock",
        "timestamp": generator.now_iso(),
        "alerts": generator.get_weather_alerts()
    }


@router.get("/traffic")
def get_traffic_data():
    """
    Returns mock traffic congestion data. Congestion score 0-100.
    Anomaly threshold: score > 70.
    """
    generator = get_shared_generator()
    return {
        "source": "google_maps_traffic_mock",
        "timestamp": generator.now_iso(),
        "segments": generator.get_traffic_segments()
    }


@router.get("/all")
def get_all_signals():
    """
    Aggregated endpoint — returns social + weather + traffic in one call.
    Used by Sentinel agent for efficiency.
    """
    generator = get_shared_generator()
    return {
        "bundle_id": generator.new_bundle_id(),
        "timestamp": generator.now_iso(),
        "social": generator.get_social_signals(15),
        "weather": generator.get_weather_alerts(),
        "traffic": generator.get_traffic_segments()
    }
