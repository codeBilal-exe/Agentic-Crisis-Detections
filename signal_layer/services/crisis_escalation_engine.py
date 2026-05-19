"""
CIRO Crisis Escalation Engine
Monitors active crises for escalation indicators based on new signals,
trigger keywords, time thresholds, and geographic proximity.
"""

import math
from datetime import datetime, timezone


# Escalation rules per crisis type
ESCALATION_RULES = {
    "urban_flooding": {
        "triggers": ["rainfall_increasing", "second_location_report", "casualty_mention"],
        "trigger_keywords": {
            "rainfall_increasing": ["barish badh rahi", "rain increasing", "more flooding", "paani badh raha", "water rising"],
            "second_location_report": [],  # checked via location analysis
            "casualty_mention": ["maut", "khoon", "zakhmi", "dead", "injured", "behosh", "drowned", "doob gaya"],
        },
        "action": "dispatch_backup_unit",
        "time_threshold_minutes": 30,
    },
    "heatwave": {
        "triggers": ["temperature_rising", "hospital_reports", "power_grid_stress"],
        "trigger_keywords": {
            "temperature_rising": ["garmi badh rahi", "temperature rising", "aur garmi", "record heat"],
            "hospital_reports": ["hospital", "emergency ward", "heatstroke", "behosh", "admitted"],
            "power_grid_stress": ["bijli gul", "load shedding", "power cut", "blackout", "transformer"],
        },
        "action": "activate_additional_cooling_centers",
        "time_threshold_minutes": 60,
    },
    "road_accident": {
        "triggers": ["secondary_collision", "emergency_vehicle_blocked"],
        "trigger_keywords": {
            "secondary_collision": ["aur accident", "another crash", "doosra accident", "pile-up", "more vehicles"],
            "emergency_vehicle_blocked": ["ambulance phas", "rescue stuck", "road completely blocked", "rasta band"],
        },
        "action": "request_police_clearance",
        "time_threshold_minutes": 20,
    },
    "infrastructure_failure": {
        "triggers": ["cascading_failure", "gas_leak_detected", "fire_spreading"],
        "trigger_keywords": {
            "cascading_failure": ["doosra transformer", "another transformer", "aur bijli gul", "cascading"],
            "gas_leak_detected": ["gas leak", "gas ki badboo", "gas smell", "gas pipeline"],
            "fire_spreading": ["aag phail", "fire spreading", "aur aag", "buildings affected", "dhuan badh raha"],
        },
        "action": "evacuate_area",
        "time_threshold_minutes": 15,
    },
}


def calculate_distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Calculate distance between two coordinates using haversine formula."""
    R = 6371.0  # Earth radius in km

    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)

    a = math.sin(dlat / 2) ** 2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlng / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


def analyze_signal_triggers(signals: list, crisis_type: str) -> dict:
    """Check signal texts for escalation trigger keywords."""
    rules = ESCALATION_RULES.get(crisis_type, {})
    trigger_keywords = rules.get("trigger_keywords", {})

    matched_triggers = []
    for trigger_name, keywords in trigger_keywords.items():
        for signal in signals:
            raw_text = signal.get("raw_text", "").lower()
            normalized_text = signal.get("normalized_text", "").lower()
            combined_text = f"{raw_text} {normalized_text}"

            for keyword in keywords:
                if keyword.lower() in combined_text:
                    matched_triggers.append(trigger_name)
                    break
            if trigger_name in matched_triggers:
                break

    return {
        "matched_triggers": list(set(matched_triggers)),
        "trigger_count": len(set(matched_triggers)),
    }


def check_escalation_needed(crisis_profile: dict, new_signals: list) -> dict:
    """
    Check if an active crisis needs escalation based on new signals.

    Args:
        crisis_profile: The active CrisisProfile from Firebase
        new_signals: Recent signals from the signal feed

    Returns:
        dict with escalation_needed, reason, recommended_action, etc.
    """
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

    # Get crisis location
    crisis_lat = crisis_profile.get("affected_lat", 0)
    crisis_lng = crisis_profile.get("affected_lng", 0)
    if not crisis_lat:
        affected_area = crisis_profile.get("affected_area", {})
        crisis_lat = affected_area.get("lat", 0)
        crisis_lng = affected_area.get("lng", 0)

    # Check how many new signals are from the crisis zone (within 3km)
    signals_in_zone = []
    for signal in new_signals:
        location = signal.get("location", {})
        sig_lat = location.get("lat", 0)
        sig_lng = location.get("lng", 0)
        if sig_lat and sig_lng and crisis_lat and crisis_lng:
            distance = calculate_distance_km(crisis_lat, crisis_lng, sig_lat, sig_lng)
            if distance <= 3.0:
                signals_in_zone.append(signal)

    # Check time since crisis detected
    detected_at = crisis_profile.get("detected_at", "")
    minutes_elapsed = 0
    if detected_at:
        try:
            detected_time = datetime.fromisoformat(detected_at.replace("Z", "+00:00"))
            now = datetime.now(timezone.utc)
            minutes_elapsed = (now - detected_time).total_seconds() / 60
        except (ValueError, TypeError):
            minutes_elapsed = 0

    time_threshold = rules["time_threshold_minutes"]
    time_exceeded = minutes_elapsed > time_threshold

    # Analyze trigger keywords in new signals
    trigger_analysis = analyze_signal_triggers(new_signals, crisis_type)

    # Determine escalation
    escalation_needed = False
    reasons = []
    trigger_matched = "none"

    # Condition 1: 2+ new signals from crisis zone
    if len(signals_in_zone) >= 2:
        escalation_needed = True
        reasons.append(f"{len(signals_in_zone)} new signals detected within 3km of crisis zone")

    # Condition 2: Time threshold exceeded with ongoing signals
    if time_exceeded and len(signals_in_zone) >= 1:
        escalation_needed = True
        reasons.append(f"Time threshold exceeded ({minutes_elapsed:.0f} min > {time_threshold} min) with ongoing activity")

    # Condition 3: Trigger keywords matched
    if trigger_analysis["trigger_count"] >= 1:
        escalation_needed = True
        trigger_matched = ", ".join(trigger_analysis["matched_triggers"])
        reasons.append(f"Escalation triggers matched: {trigger_matched}")

    reason = ". ".join(reasons) if reasons else "No escalation indicators detected"

    return {
        "escalation_needed": escalation_needed,
        "reason": reason,
        "recommended_action": rules["action"] if escalation_needed else "continue_monitoring",
        "trigger_matched": trigger_matched,
        "new_signal_count": len(new_signals),
        "signals_in_crisis_zone": len(signals_in_zone),
        "minutes_elapsed": round(minutes_elapsed, 1),
        "time_threshold_minutes": time_threshold,
        "crisis_type": crisis_type,
    }
