import os
import uuid
from datetime import datetime, timezone

import httpx


OPEN_METEO_BASE = "https://api.open-meteo.com/v1/forecast"
ISLAMABAD = {
    "area": "Islamabad",
    "lat": 33.6844,
    "lng": 73.0479,
}


class WeatherApiService:
    def __init__(self):
        self.enabled = os.getenv("OPEN_METEO_ENABLED", "true").lower() == "true"
        self.timeout_seconds = float(os.getenv("OPEN_METEO_TIMEOUT_SECONDS", "6"))

    def _build_alert_from_current(self, current: dict) -> dict:
        temperature = current.get("temperature_2m", 0.0) or 0.0
        rain = current.get("rain", 0.0) or 0.0
        precipitation = current.get("precipitation", 0.0) or 0.0
        wind_speed = current.get("wind_speed_10m", 0.0) or 0.0
        weather_code = current.get("weather_code", 0)

        alert_type = "CLEAR"
        severity = "NONE"
        message = "Clear skies. No weather alerts."

        if temperature >= 45:
            alert_type = "EXTREME_HEAT"
            severity = "EMERGENCY"
            message = (
                f"Extreme heat emergency in Islamabad: {temperature:.1f}C. "
                "Heatstroke risk is critical."
            )
        elif temperature >= 40:
            alert_type = "HIGH_HEAT"
            severity = "WARNING"
            message = (
                f"High heat warning in Islamabad: {temperature:.1f}C. "
                "Limit outdoor exposure."
            )
        elif rain >= 20 or precipitation >= 30:
            alert_type = "HEAVY_RAINFALL"
            severity = "WARNING"
            message = (
                f"Heavy rainfall warning in Islamabad: rain {rain:.1f} mm, "
                f"precipitation {precipitation:.1f} mm."
            )
        elif rain >= 5 or precipitation >= 10:
            alert_type = "MODERATE_RAINFALL"
            severity = "WATCH"
            message = (
                f"Moderate rainfall watch in Islamabad: rain {rain:.1f} mm, "
                f"precipitation {precipitation:.1f} mm."
            )
        elif weather_code in {95, 96, 99}:
            alert_type = "THUNDERSTORM"
            severity = "WARNING"
            message = "Thunderstorm warning in Islamabad. Move indoors and avoid open areas."

        return {
            "alert_id": f"wx_{uuid.uuid4().hex[:8]}",
            "type": alert_type,
            "severity": severity,
            "area": ISLAMABAD["area"],
            "message": message,
            "issued_by": "Open-Meteo / CIRO",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "source": "open_meteo_real",
            "temperature_c": round(float(temperature), 1),
            "rainfall_mm": round(float(rain), 1),
            "precipitation_mm": round(float(precipitation), 1),
            "wind_kmh": round(float(wind_speed), 1),
            "weather_code": weather_code,
        }

    def get_real_weather_sync(self) -> list:
        if not self.enabled:
            return []

        params = {
            "latitude": ISLAMABAD["lat"],
            "longitude": ISLAMABAD["lng"],
            "current": "temperature_2m,precipitation,rain,weather_code,wind_speed_10m",
            "timezone": "Asia/Karachi",
            "forecast_days": 1,
        }

        try:
            with httpx.Client(timeout=self.timeout_seconds) as client:
                response = client.get(OPEN_METEO_BASE, params=params)
                response.raise_for_status()
            payload = response.json()
            current = payload.get("current", {})
            if not current:
                return []
            return [self._build_alert_from_current(current)]
        except Exception as error:
            print(f"[WeatherAPI] Open-Meteo fetch failed: {error}")
            return []

    def get_weather_for_islamabad(self) -> dict:
        alerts = self.get_real_weather_sync()
        return alerts[0] if alerts else {}
