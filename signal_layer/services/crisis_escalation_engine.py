import math
from datetime import datetime, timezone


ESCALATION_RULES = {
    "urban_flooding": {
        "action": "dispatch_backup_unit",
        "time_threshold_minutes": 30,
        "trigger_keywords": {
            "rainfall_increasing": [
                "rain increasing",
                "barish badh rahi",
                "water rising",
                "paani barh raha",
                "flood getting worse",
            ],
            "casualty_mention": [
                "injured",
                "zakhmi",
                "dead",
                "maut",
                "drowned",
                "doob gaya",
            ],
        },
    },
    "road_accident": {
        "action": "request_police_clearance",
        "time_threshold_minutes": 20,
        "trigger_keywords": {
            "secondary_collision": [
                "another crash",
                "doosra accident",
                "pile-up",
                "more vehicles",
            ],
            "emergency_vehicle_blocked": [
                "ambulance stuck",
                "rescue stuck",
                "road blocked",
                "rasta band",
            ],
        },
    },
    "heatwave": {
        "action": "activate_additional_cooling_centers",
        "time_threshold_minutes": 60,
        "trigger_keywords": {
            "temperature_rising": [
                "temperature rising",
                "record heat",
                "aur garmi",
                "garmi barh rahi",
            ],
            "hospital_overload": [
                "hospital full",
                "heatstroke",
                "emergency ward",
                "patients overflow",
            ],
            "power_grid_stress": [
                "load shedding",
                "power cut",
                "blackout",
                "bijli gul",
            ],
        },
    },
    "infrastructure_failure": {
        "action": "evacuate_area",
        "time_threshold_minutes": 15,
        "trigger_keywords": {
            "fire_spreading": [
                "fire spreading",
                "aag phail",
                "smoke increasing",
                "dhuan barh raha",
            ],
            "gas_leak": [
                "gas leak",
                "gas smell",
                "gas ki badboo",
            ],
            "cascading_failure": [
                "another transformer",
                "more outages",
                "aur bijli gul",
            ],
        },
    },
}


def calculate_distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    earth_radius_km = 6371.0
    lat1_r = math.radians(lat1)
    lat2_r = math.radians(lat2)
    d_lat = math.radians(lat2 - lat1)
    d_lng = math.radians(lng2 - lng1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(lat1_r) * math.cos(lat2_r) * math.sin(d_lng / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return earth_radius_km * c


def _extract_crisis_coords(crisis_profile: dict) -> tuple[float, float]:
    affected_area = crisis_profile.get("affected_area", {}) or {}
    lat = crisis_profile.get("affected_lat") or affected_area.get("lat") or 0.0
    lng = crisis_profile.get("affected_lng") or affected_area.get("lng") or 0.0
    return float(lat), float(lng)


def analyze_signal_triggers(signals: list, crisis_type: str) -> dict:
    rules = ESCALATION_RULES.get(crisis_type, {})
    keyword_groups = rules.get("trigger_keywords", {})
    matched = set()

    for signal in signals:
        raw_text = str(signal.get("raw_text", "")).lower()
        normalized_text = str(signal.get("normalized_text", "")).lower()
        text_blob = f"{raw_text} {normalized_text}"

        for trigger_name, keywords in keyword_groups.items():
            if any(keyword.lower() in text_blob for keyword in keywords):
                matched.add(trigger_name)

    return {
        "matched_triggers": sorted(matched),
        "trigger_count": len(matched),
    }


def check_escalation_needed(crisis_profile: dict, new_signals: list) -> dict:
    crisis_type = crisis_profile.get("crisis_type", "unknown")
    rules = ESCALATION_RULES.get(crisis_type)
    if not rules:
        return {
            "escalation_needed": False,
            "reason": f"No escalation rules defined for crisis type: {crisis_type}",
            "recommended_action": "none",
            "trigger_matched": "none",
            "new_signal_count": len(new_signals),
        }

    crisis_lat, crisis_lng = _extract_crisis_coords(crisis_profile)

    signals_in_crisis_zone = []
    for signal in new_signals:
        location = signal.get("location", {}) or {}
        sig_lat = location.get("lat")
        sig_lng = location.get("lng")
        if sig_lat is None or sig_lng is None or crisis_lat == 0.0 or crisis_lng == 0.0:
            continue
        distance_km = calculate_distance_km(crisis_lat, crisis_lng, float(sig_lat), float(sig_lng))
        if distance_km <= 3.0:
            signals_in_crisis_zone.append(signal)

    minutes_elapsed = 0.0
    detected_at = crisis_profile.get("detected_at")
    if detected_at:
        try:
            start_ts = datetime.fromisoformat(str(detected_at).replace("Z", "+00:00"))
            minutes_elapsed = (datetime.now(timezone.utc) - start_ts).total_seconds() / 60.0
        except (TypeError, ValueError):
            minutes_elapsed = 0.0

    trigger_info = analyze_signal_triggers(new_signals, crisis_type)
    threshold_minutes = int(rules["time_threshold_minutes"])

    reasons = []
    escalation_needed = False

    if len(signals_in_crisis_zone) >= 2:
        escalation_needed = True
        reasons.append(
            f"{len(signals_in_crisis_zone)} new signals found within 3km of crisis zone"
        )

    if minutes_elapsed > threshold_minutes and len(signals_in_crisis_zone) >= 1:
        escalation_needed = True
        reasons.append(
            f"Time threshold exceeded ({minutes_elapsed:.0f} > {threshold_minutes} minutes)"
        )

    if trigger_info["trigger_count"] >= 1:
        escalation_needed = True
        reasons.append(
            "Keyword triggers detected: " + ", ".join(trigger_info["matched_triggers"])
        )

    trigger_matched = (
        ", ".join(trigger_info["matched_triggers"])
        if trigger_info["matched_triggers"]
        else "none"
    )

    return {
        "escalation_needed": escalation_needed,
        "reason": ". ".join(reasons) if reasons else "No escalation indicators detected",
        "recommended_action": rules["action"] if escalation_needed else "continue_monitoring",
        "trigger_matched": trigger_matched,
        "new_signal_count": len(new_signals),
        "signals_in_crisis_zone": len(signals_in_crisis_zone),
        "minutes_elapsed": round(minutes_elapsed, 1),
        "time_threshold_minutes": threshold_minutes,
        "crisis_type": crisis_type,
    }
