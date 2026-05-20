"""
CIRO Traffic API Service - Real Traffic Flow Integration
Uses TomTom Traffic API free tier (2500 calls/day free).
Sign up at developer.tomtom.com for free API key.
Falls back to mock data if key not available.
"""

import asyncio
import os
import random

import httpx


ISLAMABAD_ROADS = [
    {"road": "G-10 Markaz Road", "from": [33.6844, 73.0479], "to": [33.6900, 73.0550]},
    {"road": "IJP Road", "from": [33.6700, 73.0400], "to": [33.6800, 73.0600]},
    {"road": "Srinagar Highway", "from": [33.7000, 73.0300], "to": [33.7200, 73.0500]},
    {"road": "Margalla Road", "from": [33.7100, 73.0400], "to": [33.7300, 73.0700]},
]


def _road_to_segment_id(road_name: str) -> str:
    slug = road_name.lower().replace("-", "").replace("/", " ").replace(" ", "_")
    return f"seg_{slug}"


def _normalize_congestion(current_speed: float, free_flow_speed: float) -> int:
    if free_flow_speed <= 0:
        return 0
    ratio = max(0.0, min(1.0, current_speed / free_flow_speed))
    return int(round((1.0 - ratio) * 100))


def get_mock_traffic(road_segment: dict) -> dict:
    road_name = road_segment.get("road", "Unknown Road")
    from_lat, from_lng = road_segment.get("from", [33.6844, 73.0479])
    to_lat, to_lng = road_segment.get("to", [33.6900, 73.0550])

    if "G-10" in road_name:
        congestion_score = random.randint(72, 96)
    elif "IJP" in road_name:
        congestion_score = random.randint(58, 88)
    elif "Srinagar" in road_name:
        congestion_score = random.randint(25, 55)
    else:
        congestion_score = random.randint(30, 65)

    if congestion_score > 85:
        anomaly_type = "SEVERE_CONGESTION"
    elif congestion_score > 70:
        anomaly_type = "HIGH_CONGESTION"
    else:
        anomaly_type = None

    return {
        "segment_id": _road_to_segment_id(road_name),
        "road_name": road_name,
        "congestion_score": congestion_score,
        "anomaly_detected": anomaly_type is not None,
        "anomaly_type": anomaly_type,
        "from": {"lat": from_lat, "lng": from_lng},
        "to": {"lat": to_lat, "lng": to_lng},
        "metadata": {
            "source": "tomtom_mock_fallback",
            "real_data": False,
        },
    }


async def get_traffic_flow(road_segment: dict) -> dict:
    api_key = os.getenv("TOMTOM_API_KEY", "")
    if not api_key or api_key == "your_key_here":
        return get_mock_traffic(road_segment)  # graceful fallback

    lat, lng = road_segment["from"]
    url = "https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json"
    params = {"point": f"{lat},{lng}", "key": api_key}

    try:
        timeout_seconds = float(os.getenv("TOMTOM_TIMEOUT_SECONDS", "6"))
        async with httpx.AsyncClient(timeout=timeout_seconds) as client:
            response = await client.get(url, params=params)
            response.raise_for_status()

        payload = response.json()
        flow = payload.get("flowSegmentData", {}) or {}

        current_speed = float(flow.get("currentSpeed", 0.0) or 0.0)
        free_flow_speed = float(flow.get("freeFlowSpeed", 0.0) or 0.0)
        congestion_score = _normalize_congestion(current_speed, free_flow_speed)
        road_closed = bool(flow.get("roadClosure", False))

        if road_closed:
            congestion_score = 100
            anomaly_type = "SEVERE_CONGESTION"
        elif congestion_score > 85:
            anomaly_type = "SEVERE_CONGESTION"
        elif congestion_score > 70:
            anomaly_type = "HIGH_CONGESTION"
        else:
            anomaly_type = None

        road_name = road_segment.get("road", flow.get("frc", "Unknown Road"))
        from_lat, from_lng = road_segment.get("from", [lat, lng])
        to_lat, to_lng = road_segment.get("to", [lat, lng])

        return {
            "segment_id": _road_to_segment_id(road_name),
            "road_name": road_name,
            "congestion_score": int(congestion_score),
            "anomaly_detected": anomaly_type is not None,
            "anomaly_type": anomaly_type,
            "from": {"lat": from_lat, "lng": from_lng},
            "to": {"lat": to_lat, "lng": to_lng},
            "metadata": {
                "source": "tomtom_real",
                "real_data": True,
                "current_speed_kmh": current_speed,
                "free_flow_speed_kmh": free_flow_speed,
                "current_travel_time_sec": flow.get("currentTravelTime"),
                "free_flow_travel_time_sec": flow.get("freeFlowTravelTime"),
                "confidence": flow.get("confidence"),
                "road_closure": road_closed,
            },
        }
    except Exception as error:
        print(f"[TrafficAPI] TomTom fetch failed for {road_segment.get('road')}: {error}")
        return get_mock_traffic(road_segment)


class TrafficApiService:
    def __init__(self):
        self.api_key = os.getenv("TOMTOM_API_KEY", "")

    async def get_islamabad_traffic_async(self) -> list:
        tasks = [get_traffic_flow(segment) for segment in ISLAMABAD_ROADS]
        return await asyncio.gather(*tasks)

    def get_islamabad_traffic_sync(self) -> list:
        return asyncio.run(self.get_islamabad_traffic_async())

