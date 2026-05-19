from fastapi import APIRouter, Query
from services.scenario_loader import get_shared_generator

# Import real API services with graceful fallback
try:
    from services.weather_api_service import WeatherApiService
    weather_api = WeatherApiService()
except Exception as e:
    print(f"[Signals] WeatherApiService unavailable: {e}")
    weather_api = None

try:
    from services.news_api_service import NewsApiService
    news_api = NewsApiService()
except Exception as e:
    print(f"[Signals] NewsApiService unavailable: {e}")
    news_api = None

router = APIRouter()


@router.get("/social")
def get_social_signals(limit: int = Query(default=10, le=50)):
    """
    Returns social media signals.
    In crisis mode, includes flooding/accident reports in Roman Urdu and English.
    Also appends real news signals from NewsAPI when available.
    """
    generator = get_shared_generator()
    social = generator.get_social_signals(limit)

    # Append real news signals (max 3)
    if news_api:
        try:
            news_signals = news_api.get_news_signals(max_signals=3)
            if news_signals:
                social.extend(news_signals)
        except Exception as e:
            print(f"[Signals] NewsAPI error: {e}")

    return {
        "source": "social_media_mock+news",
        "signals": social
    }


@router.get("/weather")
def get_weather_alerts():
    """
    Returns weather alerts. Tries real Open-Meteo data first,
    falls back to mock data from signal generator.
    """
    generator = get_shared_generator()
    mock_alerts = generator.get_weather_alerts()

    # Try real weather data
    real_alerts = []
    if weather_api:
        try:
            real_alerts = weather_api.get_real_weather_sync()
        except Exception as e:
            print(f"[Signals] WeatherAPI error: {e}")

    # If real alerts available, use them as primary + add mock for crisis scenarios
    if real_alerts:
        return {
            "source": "open_meteo_real+pmd_mock",
            "timestamp": generator.now_iso(),
            "alerts": real_alerts + mock_alerts,
            "real_data_available": True,
        }

    return {
        "source": "pakistan_met_department_mock",
        "timestamp": generator.now_iso(),
        "alerts": mock_alerts,
        "real_data_available": False,
    }


@router.get("/traffic")
def get_traffic_data():
    """
    Returns traffic congestion data. Congestion score 0-100.
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
    Merges real API data (weather, news) with mock data.
    Used by Sentinel agent for efficiency.
    """
    generator = get_shared_generator()

    # Social signals + news integration
    social = generator.get_social_signals(15)
    if news_api:
        try:
            news_signals = news_api.get_news_signals(max_signals=3)
            if news_signals:
                social.extend(news_signals)
        except Exception as e:
            print(f"[Signals] NewsAPI error in /all: {e}")

    # Weather: real + mock combined
    mock_weather = generator.get_weather_alerts()
    real_weather = []
    if weather_api:
        try:
            real_weather = weather_api.get_real_weather_sync()
        except Exception as e:
            print(f"[Signals] WeatherAPI error in /all: {e}")

    # Combine weather: real takes priority, mock adds crisis-specific data
    combined_weather = real_weather + mock_weather if real_weather else mock_weather

    return {
        "bundle_id": generator.new_bundle_id(),
        "timestamp": generator.now_iso(),
        "social": social,
        "weather": combined_weather,
        "traffic": generator.get_traffic_segments(),
        "real_apis": {
            "weather": len(real_weather) > 0,
            "news": news_api is not None,
        }
    }
