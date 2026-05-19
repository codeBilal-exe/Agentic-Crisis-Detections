"""
CIRO Weather API Service — Real Weather Data Integration
Uses Open-Meteo API (free, no API key required)
"""

import httpx
import uuid
import os
from datetime import datetime, timezone


# Pakistan cities with coordinates
PAKISTAN_CITIES = {
    "islamabad": {"lat": 33.6844, "lng": 73.0479, "area": "Islamabad"},
    "lahore": {"lat": 31.5497, "lng": 74.3436, "area": "Lahore"},
    "karachi": {"lat": 24.8607, "lng": 67.0011, "area": "Karachi"},
    "rawalpindi": {"lat": 33.5651, "lng": 73.0169, "area": "Rawalpindi"},
}

OPEN_METEO_BASE = "https://api.open-meteo.com/v1/forecast"


class WeatherApiService:
    """Fetches real weather data from Open-Meteo and maps to CIRO alert format."""

    def __init__(self):
        self.enabled = os.getenv("OPEN_METEO_ENABLED", "true").lower() == "true"

    def _map_to_alert(self, city_name: str, city_info: dict, current: dict) -> dict:
        """Map Open-Meteo current weather to CIRO alert format."""
        temp = current.get("temperature_2m", 0)
        precip = current.get("precipitation", 0)
        rain = current.get("rain", 0)
        weather_code = current.get("weather_code", 0)
        wind = current.get("wind_speed_10m", 0)

        # Determine alert type and severity
        alert_type = "CLEAR"
        severity = "NONE"
        message = f"Weather conditions normal in {city_info['area']}."

        if temp > 45:
            alert_type = "EXTREME_HEAT"
            severity = "EMERGENCY"
            message = f"EXTREME HEAT EMERGENCY in {city_info['area']}: Temperature {temp}°C. Heatstroke risk critical. Stay indoors, hydrate continuously."
        elif temp > 40:
            alert_type = "HIGH_HEAT"
            severity = "WARNING"
            message = f"HIGH HEAT WARNING for {city_info['area']}: Temperature {temp}°C. Avoid outdoor activities during peak hours."
        elif rain > 20 or precip > 30:
            alert_type = "HEAVY_RAINFALL"
            severity = "WARNING"
            message = f"HEAVY RAINFALL WARNING for {city_info['area']}: {rain}mm rain recorded. Flash flooding possible in low-lying areas."
        elif rain > 5 or precip > 10:
            alert_type = "MODERATE_RAINFALL"
            severity = "WATCH"
            message = f"MODERATE RAINFALL WATCH for {city_info['area']}: {rain}mm rain. Roads may be slippery."
        elif weather_code in [95, 96, 99]:
            alert_type = "THUNDERSTORM"
            severity = "WARNING"
            message = f"THUNDERSTORM WARNING for {city_info['area']}: Active thunderstorm detected. Seek shelter immediately."

        return {
            "alert_id": f"wx_{uuid.uuid4().hex[:8]}",
            "type": alert_type,
            "severity": severity,
            "area": city_info["area"],
            "temperature_c": temp,
            "rainfall_mm": rain,
            "precipitation_mm": precip,
            "wind_kmh": wind,
            "weather_code": weather_code,
            "message": message,
            "source": "Open-Meteo API (Real)",
            "issued_by": "Open-Meteo / CIRO",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    def get_real_weather_sync(self, cities: dict = None) -> list:
        """Fetch real weather data synchronously. Returns list of CIRO alerts."""
        if not self.enabled:
            return []

        if cities is None:
            cities = PAKISTAN_CITIES

        alerts = []
        for city_name, city_info in cities.items():
            try:
                with httpx.Client(timeout=5.0) as client:
                    response = client.get(
                        OPEN_METEO_BASE,
                        params={
                            "latitude": city_info["lat"],
                            "longitude": city_info["lng"],
                            "current": "temperature_2m,precipitation,rain,weather_code,wind_speed_10m",
                            "forecast_days": 1,
                        },
                    )
                    if response.status_code == 200:
                        data = response.json()
                        current = data.get("current", {})
                        alert = self._map_to_alert(city_name, city_info, current)
                        alerts.append(alert)
                    else:
                        print(f"[WeatherAPI] Non-200 for {city_name}: {response.status_code}")
            except Exception as e:
                print(f"[WeatherAPI] Error fetching {city_name}: {e}")
                continue

        return alerts

    def get_weather_for_city(self, city_name: str) -> dict:
        """Get weather for a specific city."""
        city_info = PAKISTAN_CITIES.get(city_name.lower())
        if not city_info:
            return {}

        result = self.get_real_weather_sync({city_name: city_info})
        return result[0] if result else {}
