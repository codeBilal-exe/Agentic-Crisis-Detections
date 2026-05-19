"""
CIRO News API Service — Real News Signal Integration
Uses NewsAPI.org (free tier, requires API key)
Gracefully returns empty results if key not configured
"""

import httpx
import uuid
import os
from datetime import datetime, timezone


NEWSAPI_BASE = "https://newsapi.org/v2/everything"

# Pakistan-specific crisis keywords (max 3 to stay in free tier limits)
CRISIS_KEYWORDS = [
    "Pakistan flood",
    "Pakistan rescue emergency",
    "Islamabad flood accident",
]


class NewsApiService:
    """Fetches Pakistan crisis news from NewsAPI and converts to CIRO signal format."""

    def __init__(self):
        self.api_key = os.getenv("NEWS_API_KEY", "")

    def _article_to_signal(self, article: dict) -> dict:
        """Convert a news article to CIRO signal format."""
        title = article.get("title", "")
        description = article.get("description", "") or ""
        source_name = article.get("source", {}).get("name", "Unknown")
        published = article.get("publishedAt", datetime.now(timezone.utc).isoformat())

        raw_text = f"{title}. {description}".strip()
        if raw_text.endswith("."):
            raw_text = raw_text

        return {
            "signal_id": f"sig_{uuid.uuid4().hex[:8]}",
            "source": "news_feed",
            "timestamp": published,
            "raw_text": raw_text,
            "normalized_text": title,
            "location": {
                "area": "Pakistan",
                "city": "Pakistan",
                "lat": 30.3753,
                "lng": 69.3451,
            },
            "metadata": {
                "platform": source_name,
                "engagement_score": 30,
                "language_detected": "english",
                "article_url": article.get("url", ""),
            },
        }

    def get_news_signals(self, max_signals: int = 5) -> list:
        """Fetch Pakistan crisis news and return as CIRO signal format."""
        if not self.api_key or self.api_key == "your_newsapi_key_here":
            print("[NewsAPI] No API key configured. Returning empty news signals.")
            return []

        all_signals = []

        for keyword in CRISIS_KEYWORDS:
            if len(all_signals) >= max_signals:
                break

            try:
                with httpx.Client(timeout=5.0) as client:
                    response = client.get(
                        NEWSAPI_BASE,
                        params={
                            "q": keyword,
                            "language": "en",
                            "sortBy": "publishedAt",
                            "pageSize": 3,
                            "apiKey": self.api_key,
                        },
                    )
                    if response.status_code == 200:
                        data = response.json()
                        articles = data.get("articles", [])
                        for article in articles:
                            if len(all_signals) >= max_signals:
                                break
                            signal = self._article_to_signal(article)
                            all_signals.append(signal)
                    else:
                        print(f"[NewsAPI] Non-200 for '{keyword}': {response.status_code}")
            except Exception as e:
                print(f"[NewsAPI] Error searching '{keyword}': {e}")
                continue

        return all_signals[:max_signals]
