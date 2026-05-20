import random
import uuid
from datetime import datetime, timezone


FLOOD_SOCIAL_SIGNALS = [
    "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain",
    "G10 sector completely flooded. Main road blocked. Rescue needed ASAP!",
    "Yaar G-10 markaz ke paas itna paani hai ke guzarna mushkil hai",
    "Flash flood G-10 Islamabad! Cars stuck. Roads impassable. Where is rescue?",
    "Heavy rain causing flooding in G-10, multiple vehicles stranded on main road",
    "G-10 paani mein doob gaya hai bhai. Rescue 1122 bulao jaldi",
    "Islamabad G-10 main road blocked due to heavy flooding. Avoid this area!",
    "IJP Road G-10 crossing completely under water. Major traffic jam building up",
]

FLOOD_NORMALIZED = [
    "G-10 sector flooded, vehicles stranded",
    "G-10 main road blocked, flooding critical",
    "G-10 area flooded, road impassable",
    "Flash flood G-10, vehicles stuck, rescue needed",
    "Heavy flooding G-10, vehicles stranded on main road",
    "G-10 flooded, requesting Rescue 1122",
    "G-10 main road blocked by flooding",
    "IJP Road G-10 submerged, traffic blocked",
]

ACCIDENT_SOCIAL_SIGNALS = [
    "Huge accident on M-2 motorway near Bhera! Multiple cars involved. Need ambulance immediately!",
    "M-2 pe bada accident hua hai. Blood on road. Someone call rescue!",
    "M2 completely blocked near KM45. Serious accident. Motorway police on scene.",
    "3 gaariyan takra gayi hain M-2 pe. Bohot bura manzar hai bhai",
    "M-2 accident - ambulances needed urgently at KM 45",
]

ACCIDENT_NORMALIZED = [
    "Major multi-vehicle accident on M-2 motorway near Bhera, ambulance needed",
    "Serious accident on M-2, blood on road, rescue needed",
    "M-2 blocked at KM45, serious accident, motorway police present",
    "3-vehicle collision on M-2, severe scene",
    "M-2 accident at KM 45, urgent ambulance request",
]

HEATWAVE_SOCIAL_SIGNALS = [
    "52 degree garmi Lahore mein. 3 log behosh ho gaye near Data Darbar",
    "Lahore is on FIRE. Heatstroke casualties being reported from multiple areas",
    "Bijli nahi aur itni garmi. Hospitals overwhelmed. Where is government?",
    "Old city area Lahore - elderly and children affected by extreme heat. Need help.",
]

HEATWAVE_NORMALIZED = [
    "52C heat in Lahore, 3 people collapsed near Data Darbar",
    "Lahore heatstroke casualties from multiple areas",
    "Power outage combined with extreme heat, hospitals overwhelmed",
    "Old city Lahore - elderly and children affected by extreme heat",
]

INFRA_SOCIAL_SIGNALS = [
    "Bada dhamaka hua I-8 mein. Bijli ka transformer phat gaya. Kala dhuan!",
    "I-8 transformer explosion. Fire visible. Evacuate nearby area!",
    "I-8 sector blackout. Smells like burning plastic everywhere.",
    "IESCO please fix the transformer in I-8/4. Entire sector without power.",
]

INFRA_NORMALIZED = [
    "Large explosion in I-8, transformer exploded, black smoke visible",
    "I-8 transformer explosion, fire visible, evacuation needed",
    "I-8 sector complete blackout, burning smell",
    "I-8/4 transformer failure, entire sector without power",
]

NORMAL_SOCIAL_SIGNALS = [
    "Traffic moving smoothly on Constitution Avenue today",
    "Nice weather in Islamabad this morning",
    "F-10 Markaz parking is crowded as usual",
    "Blue Area office hours traffic picking up",
    "Margalla road clear and scenic today",
]

CITIZEN_REPORTER_SIGNALS = [
    {
        "type": "video_report",
        "text": "Live video: G-10 underpass completely submerged. Cars abandoned. Water level rising fast.",
        "engagement_score": 450,
        "platform": "Twitter/X",
        "has_media": True,
    },
    {
        "type": "eye_witness",
        "text": "Main hun G-10 mein abhi. Knee deep pani hai road pe. Bijli bhi gul ho gayi.",
        "engagement_score": 230,
        "platform": "WhatsApp",
        "has_media": False,
    },
]

RESCUE_TEAM_SIGNALS = [
    {
        "source": "Rescue_1122_Official",
        "text": "Rescue 1122 Islamabad: Teams deployed at G-10. 3 vehicles recovered. Operations ongoing. Citizens advised to avoid area.",
        "credibility": 1.0,
        "is_official": True,
    }
]

TRAFFIC_AUTHORITY_SIGNALS = [
    {
        "source": "CDA_Traffic",
        "text": "CDA Traffic Advisory: G-10 Markaz Road closed due to flooding. Use Srinagar Highway as alternate.",
        "credibility": 1.0,
        "is_official": True,
    }
]

PDMA_OFFICIAL_SIGNALS = [
    {
        "source": "PDMA_Official",
        "text": "PDMA advisory: Urban flood risk elevated in G-10 Islamabad. Coordinate with Rescue 1122 and avoid low-lying roads.",
        "credibility": 1.0,
        "is_official": True,
    }
]


class SignalGenerator:
    def __init__(self):
        self._crisis_mode = False
        self._crisis_type = None
        self._crisis_location = None

    def activate_crisis_mode(self, crisis_type: str, location: str):
        self._crisis_mode = True
        self._crisis_type = crisis_type
        self._crisis_location = location

    def deactivate_crisis_mode(self):
        self._crisis_mode = False
        self._crisis_type = None
        self._crisis_location = None

    def new_signal_id(self):
        return f"sig_{uuid.uuid4().hex[:8]}"

    def new_bundle_id(self):
        return f"bundle_{uuid.uuid4().hex[:8]}"

    def now_iso(self):
        return datetime.now(timezone.utc).isoformat()

    def _build_citizen_reporter_signal(
        self,
        template: dict,
        area: str,
        city: str,
        lat: float,
        lng: float,
    ) -> dict:
        raw_text = template["text"]
        normalized_text = raw_text
        if template.get("type") == "eye_witness":
            normalized_text = (
                "I am currently in G-10. The road has knee-deep water and electricity is out."
            )

        return {
            "signal_id": self.new_signal_id(),
            "source": "citizen_reporter",
            "timestamp": self.now_iso(),
            "raw_text": raw_text,
            "normalized_text": normalized_text,
            "signal_type": template.get("type", "citizen_report"),
            "location": {
                "area": area,
                "city": city,
                "lat": lat + random.uniform(-0.002, 0.002),
                "lng": lng + random.uniform(-0.002, 0.002),
            },
            "metadata": {
                "platform": template.get("platform", "Twitter/X"),
                "engagement_score": int(template.get("engagement_score", 100)),
                "language_detected": (
                    "roman_urdu" if template.get("type") == "eye_witness" else "english"
                ),
                "has_media": bool(template.get("has_media", False)),
                "citizen_reporter": True,
            },
        }

    def _build_official_signal(
        self,
        template: dict,
        area: str,
        city: str,
        lat: float,
        lng: float,
    ) -> dict:
        return {
            "signal_id": self.new_signal_id(),
            "source": template.get("source", "Official_Authority"),
            "timestamp": self.now_iso(),
            "raw_text": template["text"],
            "normalized_text": template["text"],
            "credibility": float(template.get("credibility", 1.0)),
            "is_official": bool(template.get("is_official", True)),
            "location": {
                "area": area,
                "city": city,
                "lat": lat + random.uniform(-0.001, 0.001),
                "lng": lng + random.uniform(-0.001, 0.001),
            },
            "metadata": {
                "platform": "Official Bulletin",
                "engagement_score": random.randint(300, 850),
                "language_detected": "english",
                "is_official": bool(template.get("is_official", True)),
                "authority_source": template.get("source", "Official_Authority"),
            },
        }

    def _inject_urban_flood_realism_signals(
        self,
        signals: list,
        area: str,
        city: str,
        lat: float,
        lng: float,
        limit: int,
    ) -> list:
        realism_signals = []

        for template in RESCUE_TEAM_SIGNALS:
            realism_signals.append(self._build_official_signal(template, area, city, lat, lng))
        for template in TRAFFIC_AUTHORITY_SIGNALS:
            realism_signals.append(self._build_official_signal(template, area, city, lat, lng))
        for template in PDMA_OFFICIAL_SIGNALS:
            realism_signals.append(self._build_official_signal(template, area, city, lat, lng))
        for template in CITIZEN_REPORTER_SIGNALS:
            realism_signals.append(
                self._build_citizen_reporter_signal(template, area, city, lat, lng)
            )

        # Prioritize official confirmations first, then blend with social chatter.
        combined = realism_signals + signals
        return combined[:limit]

    def get_social_signals(self, limit: int = 10) -> list:
        if not self._crisis_mode:
            return [self._generate_normal_signal() for _ in range(limit)]

        if self._crisis_type == "urban_flooding":
            signals = self._generate_crisis_signals(
                FLOOD_SOCIAL_SIGNALS,
                FLOOD_NORMALIZED,
                area="G-10",
                city="Islamabad",
                lat=33.6844,
                lng=73.0479,
                limit=limit,
            )
            signals = self._inject_urban_flood_realism_signals(
                signals=signals,
                area="G-10",
                city="Islamabad",
                lat=33.6844,
                lng=73.0479,
                limit=limit,
            )
        elif self._crisis_type == "road_accident":
            signals = self._generate_crisis_signals(
                ACCIDENT_SOCIAL_SIGNALS,
                ACCIDENT_NORMALIZED,
                area="M-2 Motorway KM 45",
                city="Islamabad-Lahore",
                lat=33.0000,
                lng=73.0000,
                limit=limit,
            )
        elif self._crisis_type == "heatwave":
            signals = self._generate_crisis_signals(
                HEATWAVE_SOCIAL_SIGNALS,
                HEATWAVE_NORMALIZED,
                area="Lahore",
                city="Lahore",
                lat=31.5204,
                lng=74.3587,
                limit=limit,
            )
        elif self._crisis_type == "infrastructure_failure":
            signals = self._generate_crisis_signals(
                INFRA_SOCIAL_SIGNALS,
                INFRA_NORMALIZED,
                area="I-8",
                city="Islamabad",
                lat=33.6611,
                lng=73.0769,
                limit=limit,
            )
        else:
            signals = [self._generate_normal_signal() for _ in range(limit)]

        random.shuffle(signals)
        return signals

    def _generate_crisis_signals(
        self,
        raw_texts: list[str],
        normalized_texts: list[str],
        area: str,
        city: str,
        lat: float,
        lng: float,
        limit: int,
    ) -> list:
        signals = []
        n_crisis = min(limit, random.randint(4, 7))
        n_normal = max(0, limit - n_crisis)

        for i in range(n_crisis):
            idx = i % len(raw_texts)
            norm_idx = i % len(normalized_texts)
            signals.append(
                {
                    "signal_id": self.new_signal_id(),
                    "source": "social_media",
                    "timestamp": self.now_iso(),
                    "raw_text": raw_texts[idx],
                    "normalized_text": normalized_texts[norm_idx],
                    "location": {
                        "area": area,
                        "city": city,
                        "lat": lat + random.uniform(-0.005, 0.005),
                        "lng": lng + random.uniform(-0.005, 0.005),
                    },
                    "metadata": {
                        "platform": random.choice(["Twitter/X", "Facebook", "WhatsApp Group"]),
                        "engagement_score": random.randint(20, 150),
                        "language_detected": random.choice(["roman_urdu", "english"]),
                    },
                }
            )

        for _ in range(n_normal):
            signals.append(self._generate_normal_signal())

        return signals

    def _generate_normal_signal(self) -> dict:
        text = random.choice(NORMAL_SOCIAL_SIGNALS)
        return {
            "signal_id": self.new_signal_id(),
            "source": "social_media",
            "timestamp": self.now_iso(),
            "raw_text": text,
            "normalized_text": text,
            "location": {
                "area": random.choice(["F-7", "G-6", "Blue Area", "F-10", "E-7"]),
                "city": "Islamabad",
                "lat": 33.7000 + random.uniform(-0.05, 0.05),
                "lng": 73.0000 + random.uniform(-0.05, 0.05),
            },
            "metadata": {
                "platform": random.choice(["Twitter/X", "Facebook"]),
                "engagement_score": random.randint(1, 15),
                "language_detected": "english",
            },
        }

    def get_weather_alerts(self) -> list:
        if self._crisis_mode and self._crisis_type == "urban_flooding":
            return [
                {
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "HEAVY_RAINFALL",
                    "severity": "WARNING",
                    "area": "Islamabad / Rawalpindi",
                    "message": "Heavy to very heavy rainfall expected. Flash flooding possible in low-lying areas. PMD issues RED alert.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "valid_until": self.now_iso(),
                    "rainfall_mm_expected": random.randint(60, 120),
                }
            ]

        if self._crisis_mode and self._crisis_type == "road_accident":
            return [
                {
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "FOG",
                    "severity": "WATCH",
                    "area": "Motorway M-2 Corridor",
                    "message": "Dense fog patches on M-2 motorway. Visibility below 50m. Drive with caution.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "visibility_m": 50,
                }
            ]

        if self._crisis_mode and self._crisis_type == "heatwave":
            return [
                {
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "EXTREME_HEAT",
                    "severity": "EMERGENCY",
                    "area": "Lahore (citywide)",
                    "message": "Extreme heat emergency. Temperature exceeding 52C. Heatstroke risk CRITICAL. Stay indoors.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "temperature_c": 52,
                }
            ]

        return [
            {
                "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                "type": "CLEAR",
                "severity": "NONE",
                "area": "Islamabad",
                "message": "Clear skies. No weather alerts.",
                "issued_by": "Pakistan Meteorological Department (Mock)",
                "rainfall_mm_expected": 0,
            }
        ]

    def get_traffic_segments(self) -> list:
        if self._crisis_mode and self._crisis_type == "urban_flooding":
            return [
                {
                    "segment_id": "seg_g10_main",
                    "road_name": "G-10 Markaz Road",
                    "congestion_score": random.randint(88, 100),
                    "anomaly_detected": True,
                    "anomaly_type": "SEVERE_CONGESTION",
                    "from": {"lat": 33.6820, "lng": 73.0460},
                    "to": {"lat": 33.6870, "lng": 73.0510},
                },
                {
                    "segment_id": "seg_ijp_g10",
                    "road_name": "IJP Road (G-10 Junction)",
                    "congestion_score": random.randint(75, 90),
                    "anomaly_detected": True,
                    "anomaly_type": "HIGH_CONGESTION",
                    "from": {"lat": 33.6800, "lng": 73.0430},
                    "to": {"lat": 33.6830, "lng": 73.0470},
                },
                {
                    "segment_id": "seg_srinagar",
                    "road_name": "Srinagar Highway",
                    "congestion_score": random.randint(30, 50),
                    "anomaly_detected": False,
                    "anomaly_type": None,
                    "from": {"lat": 33.6950, "lng": 73.0380},
                    "to": {"lat": 33.7100, "lng": 73.0600},
                },
            ]

        if self._crisis_mode and self._crisis_type == "road_accident":
            return [
                {
                    "segment_id": "seg_m2_km45",
                    "road_name": "M-2 Motorway KM 45",
                    "congestion_score": 100,
                    "anomaly_detected": True,
                    "anomaly_type": "SEVERE_CONGESTION",
                    "from": {"lat": 32.9500, "lng": 73.0500},
                    "to": {"lat": 33.0500, "lng": 73.1500},
                },
                {
                    "segment_id": "seg_n5_bhera",
                    "road_name": "N-5 National Highway (Bhera)",
                    "congestion_score": random.randint(25, 40),
                    "anomaly_detected": False,
                    "anomaly_type": None,
                    "from": {"lat": 32.4800, "lng": 72.9200},
                    "to": {"lat": 32.5500, "lng": 73.0000},
                },
            ]

        if self._crisis_mode and self._crisis_type == "heatwave":
            return [
                {
                    "segment_id": "seg_lahore_mall",
                    "road_name": "Mall Road Lahore",
                    "congestion_score": random.randint(45, 60),
                    "anomaly_detected": False,
                    "anomaly_type": None,
                    "from": {"lat": 31.5500, "lng": 74.3300},
                    "to": {"lat": 31.5700, "lng": 74.3600},
                }
            ]

        if self._crisis_mode and self._crisis_type == "infrastructure_failure":
            return [
                {
                    "segment_id": "seg_i8_main",
                    "road_name": "I-8 Main Road",
                    "congestion_score": random.randint(60, 75),
                    "anomaly_detected": True,
                    "anomaly_type": "HIGH_CONGESTION",
                    "from": {"lat": 33.6580, "lng": 73.0740},
                    "to": {"lat": 33.6650, "lng": 73.0800},
                }
            ]

        return [
            {
                "segment_id": f"seg_{index}",
                "road_name": road_name,
                "congestion_score": random.randint(10, 40),
                "anomaly_detected": False,
                "anomaly_type": None,
            }
            for index, road_name in enumerate(["Constitution Ave", "Margalla Road", "GT Road", "IJP Road"])
        ]
