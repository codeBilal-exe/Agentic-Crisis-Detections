import uuid
import random
from datetime import datetime, timezone
from faker import Faker

fake = Faker()

# Crisis-specific signal templates
FLOOD_SOCIAL_SIGNALS = [
    "G-10 mein pani bhar gaya hai, gaariyan phans gayi hain",
    "G10 sector completely flooded. Main road blocked. Rescue needed ASAP!",
    "Yaar G-10 markaz ke paas itna paani hai ke guzarna mushkil hai",
    "Flash flood G-10 Islamabad! Cars stuck. Roads impassable. Where is rescue?",
    "Heavy rain causing flooding in G-10, multiple vehicles stranded on main road",
    "G-10 paani mein doob gaya hai bhai. Rescue 1122 bulao jaldi",
    "Islamabad G-10 main road blocked due to heavy flooding. Avoid this area!",
    "IJP Road G-10 crossing completely under water. Major traffic jam building up"
]

FLOOD_NORMALIZED = [
    "G-10 sector flooded, vehicles stranded",
    "G-10 main road blocked, flooding critical",
    "G-10 area flooded, road impassable",
    "Flash flood G-10, vehicles stuck, rescue needed",
    "Heavy flooding G-10, vehicles stranded on main road",
    "G-10 flooded, requesting Rescue 1122",
    "G-10 main road blocked by flooding",
    "IJP Road G-10 submerged, traffic blocked"
]

ACCIDENT_SOCIAL_SIGNALS = [
    "Huge accident on M-2 motorway near Bhera! Multiple cars involved. Need ambulance immediately!",
    "M-2 pe bada accident hua hai. Blood on road. Someone call rescue!",
    "M2 completely blocked near KM45. Serious accident. Motorway police on scene.",
    "3 gaariyan takra gayi hain M-2 pe. Bohot bura manzar hai bhai",
    "M-2 accident - ambulances needed urgently at KM 45"
]

ACCIDENT_NORMALIZED = [
    "Major multi-vehicle accident on M-2 motorway near Bhera, ambulance needed",
    "Serious accident on M-2, blood on road, rescue needed",
    "M-2 blocked at KM45, serious accident, motorway police present",
    "3-vehicle collision on M-2, severe scene",
    "M-2 accident at KM 45, urgent ambulance request"
]

HEATWAVE_SOCIAL_SIGNALS = [
    "52 degree garmi Lahore mein. 3 log behosh ho gaye near Data Darbar",
    "Lahore is on FIRE. Heatstroke casualties being reported from multiple areas",
    "Bijli nahi aur itni garmi. Hospitals overwhelmed. Where is government?",
    "Old city area Lahore - elderly and children affected by extreme heat. Need help."
]

HEATWAVE_NORMALIZED = [
    "52°C heat in Lahore, 3 people collapsed near Data Darbar",
    "Lahore heatstroke casualties from multiple areas",
    "Power outage combined with extreme heat, hospitals overwhelmed",
    "Old city Lahore - elderly and children affected by extreme heat"
]

INFRA_SOCIAL_SIGNALS = [
    "Bada dhamaka hua I-8 mein. Bijli ka transformer phat gaya. Kala dhuan!",
    "I-8 transformer explosion. Fire visible. Evacuate nearby area!",
    "I-8 sector blackout. Smells like burning plastic everywhere.",
    "IESCO please fix the transformer in I-8/4. Entire sector without power."
]

INFRA_NORMALIZED = [
    "Large explosion in I-8, transformer exploded, black smoke visible",
    "I-8 transformer explosion, fire visible, evacuation needed",
    "I-8 sector complete blackout, burning smell",
    "I-8/4 transformer failure, entire sector without power"
]

EARTHQUAKE_SOCIAL_SIGNALS = [
    "Bahut zor ka jhatka aaya Rawalpindi mein! Deewarein gir rahi hain. Madad karo!",
    "Earthquake in Rawalpindi! 5.8 magnitude. Buildings shaking. People running outside.",
    "Saddar area Rawalpindi mein building collapse. Log phansey hue hain andar.",
    "Bhookamp! Gas leak smell aa rahi hai. Bijli bhi gul ho gayi. RESCUE!",
    "R.A. Bazaar area badly hit. Cracked roads. Multiple injured. 1122 please respond.",
    "Rawalpindi earthquake! Ghar ke andar se bhaago! Zameen hil rahi hai!",
    "Aftershock felt in Rawalpindi. People are too scared to go back inside.",
    "Building girne wali hai Saddar Rawalpindi mein! Fire brigade bulao!",
    "Holy Family Hospital mein injured patients aa rahe hain. Bhookamp ka nateeja.",
    "Rawalpindi se Islamabad tak jhatke mehsoos huye. Cracks deewarein mein."
]

EARTHQUAKE_NORMALIZED = [
    "Strong earthquake in Rawalpindi, walls collapsing, requesting help",
    "5.8 magnitude earthquake in Rawalpindi, buildings shaking, evacuations underway",
    "Building collapse in Saddar area Rawalpindi, people trapped inside",
    "Earthquake with gas leak detected, power outage, emergency rescue needed",
    "R.A. Bazaar Rawalpindi severely damaged, roads cracked, multiple injuries reported",
    "Rawalpindi earthquake, evacuate buildings immediately, ground shaking",
    "Aftershock in Rawalpindi, people afraid to re-enter buildings",
    "Building at risk of collapse in Saddar Rawalpindi, fire brigade requested",
    "Holy Family Hospital receiving earthquake injured patients",
    "Earthquake tremors felt from Rawalpindi to Islamabad, wall cracks"
]

LANDSLIDE_SOCIAL_SIGNALS = [
    "Murree road pe pahar se mitti gir gayi. Raasta bilkul band. 20+ gaariyan phansi hain!",
    "Landslide on Murree-Islamabad road near Bari Imam. Complete blockage.",
    "Zamin khisak gayi Murree road pe. Log phanse hue hain. NHA kab action lega?",
    "Heavy rocks on road between Murree and Islamabad. Road impassable. Rescue needed.",
    "Barish ke baad landslide! Murree road completely blocked. Use GT Road alternate.",
    "Pahari ilaqe mein zamin khisak gayi. 3 gaariyan dab gayi hain. Rescue 1122!",
    "Bari Imam ke paas landslide. Mitti aur patthar road pe. Koi guzar nahi sakta."
]

LANDSLIDE_NORMALIZED = [
    "Mountain soil collapse on Murree road, road completely blocked, 20+ vehicles trapped",
    "Landslide on Murree-Islamabad road near Bari Imam, complete road blockage",
    "Ground shifted on Murree road, people trapped, NHA response requested",
    "Heavy rocks blocking Murree-Islamabad road, road impassable, rescue needed",
    "Post-rain landslide, Murree road completely blocked, use GT Road alternate",
    "Landslide in hilly area, 3 vehicles buried under debris, Rescue 1122 needed",
    "Landslide near Bari Imam, soil and rocks on road, no passage possible"
]

HOSPITAL_SOCIAL_SIGNALS = [
    "PIMS hospital mein jagah nahi. Patients bahar dhoop mein hain. Koi madad karo.",
    "PIMS generator fail. ICU patients at risk. Emergency situation inside hospital.",
    "PIMS Islamabad is FULL. Redirecting patients to Poly Clinic. Please spread.",
    "Doctor friend says PIMS cannot take more patients. System crash imminent.",
    "PIMS emergency ward overflow. Heatstroke patients on stretchers in corridors.",
    "PIMS ka AC band. Generator fail. Patients ki haalat kharab ho rahi hai.",
    "WAPDA se baat karo! PIMS hospital ko bijli do. Lives at stake.",
    "Poly Clinic bhi full hone wala hai. Islamabad hospitals crisis mein hain."
]

HOSPITAL_NORMALIZED = [
    "PIMS hospital at full capacity, patients outside in sun, help needed",
    "PIMS generator failure, ICU patients at risk, emergency situation",
    "PIMS Islamabad full, patients redirecting to Poly Clinic",
    "PIMS cannot accept more patients, system overload imminent",
    "PIMS emergency ward overflow, heatstroke patients in corridors",
    "PIMS AC system down, generator failed, patient conditions deteriorating",
    "WAPDA power emergency for PIMS hospital, lives at stake",
    "Poly Clinic near capacity, Islamabad hospital crisis developing"
]

NORMAL_SOCIAL_SIGNALS = [
    "Traffic moving smoothly on Constitution Avenue today",
    "Nice weather in Islamabad this morning",
    "F-10 Markaz parking is crowded as usual",
    "Blue Area office hours traffic picking up",
    "Margalla road clear and scenic today"
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

    def new_signal_id(self): return f"sig_{uuid.uuid4().hex[:8]}"
    def new_bundle_id(self): return f"bundle_{uuid.uuid4().hex[:8]}"
    def now_iso(self): return datetime.now(timezone.utc).isoformat()

    def get_social_signals(self, limit: int = 10) -> list:
        signals = []
        if self._crisis_mode:
            if self._crisis_type == "urban_flooding":
                signals = self._generate_crisis_signals(
                    FLOOD_SOCIAL_SIGNALS, FLOOD_NORMALIZED,
                    "G-10", "Islamabad", 33.6844, 73.0479, limit
                )
            elif self._crisis_type == "road_accident":
                signals = self._generate_crisis_signals(
                    ACCIDENT_SOCIAL_SIGNALS, ACCIDENT_NORMALIZED,
                    "M-2 Motorway KM 45", "Islamabad-Lahore", 33.0, 73.0, limit
                )
            elif self._crisis_type == "heatwave":
                signals = self._generate_crisis_signals(
                    HEATWAVE_SOCIAL_SIGNALS, HEATWAVE_NORMALIZED,
                    "Lahore", "Lahore", 31.5204, 74.3587, limit
                )
            elif self._crisis_type == "infrastructure_failure":
                # Check if it's hospital overload scenario
                if self._crisis_location and "PIMS" in self._crisis_location:
                    signals = self._generate_crisis_signals(
                        HOSPITAL_SOCIAL_SIGNALS, HOSPITAL_NORMALIZED,
                        "PIMS Hospital", "Islamabad", 33.7104, 73.0479, limit
                    )
                else:
                    signals = self._generate_crisis_signals(
                        INFRA_SOCIAL_SIGNALS, INFRA_NORMALIZED,
                        "I-8", "Islamabad", 33.6611, 73.0769, limit
                    )
            elif self._crisis_type == "earthquake":
                signals = self._generate_crisis_signals(
                    EARTHQUAKE_SOCIAL_SIGNALS, EARTHQUAKE_NORMALIZED,
                    "Saddar, Rawalpindi", "Rawalpindi", 33.5651, 73.0451, limit
                )
            elif self._crisis_type == "landslide":
                signals = self._generate_crisis_signals(
                    LANDSLIDE_SOCIAL_SIGNALS, LANDSLIDE_NORMALIZED,
                    "Murree Road", "Islamabad", 33.7300, 73.0900, limit
                )
            else:
                for _ in range(limit):
                    signals.append(self._generate_normal_signal())
        else:
            for _ in range(limit):
                signals.append(self._generate_normal_signal())

        random.shuffle(signals)
        return signals

    def _generate_crisis_signals(self, raw_texts, normalized_texts, area, city, lat, lng, limit):
        signals = []
        n_crisis = min(limit, random.randint(4, 7))
        n_normal = limit - n_crisis

        for i in range(n_crisis):
            idx = i % len(raw_texts)
            norm_idx = idx % len(normalized_texts)
            signals.append({
                "signal_id": self.new_signal_id(),
                "source": "social_media",
                "timestamp": self.now_iso(),
                "raw_text": raw_texts[idx],
                "normalized_text": normalized_texts[norm_idx],
                "location": {
                    "area": area,
                    "city": city,
                    "lat": lat + random.uniform(-0.005, 0.005),
                    "lng": lng + random.uniform(-0.005, 0.005)
                },
                "metadata": {
                    "platform": random.choice(["Twitter/X", "Facebook", "WhatsApp Group"]),
                    "engagement_score": random.randint(20, 150),
                    "language_detected": random.choice(["roman_urdu", "english"])
                }
            })

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
                "lat": 33.7 + random.uniform(-0.05, 0.05),
                "lng": 73.0 + random.uniform(-0.05, 0.05)
            },
            "metadata": {
                "platform": random.choice(["Twitter/X", "Facebook"]),
                "engagement_score": random.randint(1, 15),
                "language_detected": "english"
            }
        }

    def get_weather_alerts(self) -> list:
        if self._crisis_mode:
            if self._crisis_type == "urban_flooding":
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "HEAVY_RAINFALL",
                    "severity": "WARNING",
                    "area": "Islamabad / Rawalpindi",
                    "message": "Heavy to very heavy rainfall expected. Flash flooding possible in low-lying areas. PMD issues RED alert.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "valid_until": self.now_iso(),
                    "rainfall_mm_expected": random.randint(60, 120)
                }]
            elif self._crisis_type == "road_accident":
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "FOG",
                    "severity": "WATCH",
                    "area": "Motorway M-2 Corridor",
                    "message": "Dense fog patches on M-2 motorway. Visibility below 50m. Drive with caution.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "visibility_m": 50
                }]
            elif self._crisis_type == "heatwave":
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "EXTREME_HEAT",
                    "severity": "EMERGENCY",
                    "area": "Lahore (citywide)",
                    "message": "Extreme heat emergency. Temperature exceeding 52°C. Heatstroke risk CRITICAL. Stay indoors.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "temperature_c": 52
                }]
            elif self._crisis_type == "infrastructure_failure":
                if self._crisis_location and "PIMS" in self._crisis_location:
                    return [{
                        "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                        "type": "EXTREME_HEAT",
                        "severity": "EMERGENCY",
                        "area": "Islamabad",
                        "message": "Extreme heat 49°C. Hospital cooling systems under stress. Generator failures reported.",
                        "issued_by": "Pakistan Meteorological Department (Mock)",
                        "temperature_c": 49
                    }]
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "CLEAR",
                    "severity": "NONE",
                    "area": "Islamabad",
                    "message": "Clear skies. No weather alerts.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "rainfall_mm_expected": 0
                }]
            elif self._crisis_type == "earthquake":
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "CLEAR",
                    "severity": "NONE",
                    "area": "Rawalpindi / Islamabad",
                    "message": "Clear weather. No meteorological correlation with seismic event.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "rainfall_mm_expected": 0
                }]
            elif self._crisis_type == "landslide":
                return [{
                    "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
                    "type": "HEAVY_RAINFALL",
                    "severity": "WARNING",
                    "area": "Murree Hills / Islamabad",
                    "message": "Continuous heavy rainfall 95mm in Murree hills. Landslide risk VERY HIGH. Avoid hill roads.",
                    "issued_by": "Pakistan Meteorological Department (Mock)",
                    "rainfall_mm_expected": 95
                }]
        return [{
            "alert_id": f"weather_{uuid.uuid4().hex[:6]}",
            "type": "CLEAR",
            "severity": "NONE",
            "area": "Islamabad",
            "message": "Clear skies. No weather alerts.",
            "issued_by": "Pakistan Meteorological Department (Mock)",
            "rainfall_mm_expected": 0
        }]

    def get_traffic_segments(self) -> list:
        if self._crisis_mode:
            if self._crisis_type == "urban_flooding":
                return [
                    {
                        "segment_id": "seg_g10_main",
                        "road_name": "G-10 Markaz Road",
                        "congestion_score": random.randint(88, 100),
                        "anomaly_detected": True,
                        "anomaly_type": "SEVERE_CONGESTION",
                        "from": {"lat": 33.6820, "lng": 73.0460},
                        "to": {"lat": 33.6870, "lng": 73.0510}
                    },
                    {
                        "segment_id": "seg_ijp_g10",
                        "road_name": "IJP Road (G-10 Junction)",
                        "congestion_score": random.randint(75, 90),
                        "anomaly_detected": True,
                        "anomaly_type": "HIGH_CONGESTION",
                        "from": {"lat": 33.6800, "lng": 73.0430},
                        "to": {"lat": 33.6830, "lng": 73.0470}
                    },
                    {
                        "segment_id": "seg_srinagar",
                        "road_name": "Srinagar Highway",
                        "congestion_score": random.randint(30, 50),
                        "anomaly_detected": False,
                        "anomaly_type": None,
                        "from": {"lat": 33.6950, "lng": 73.0380},
                        "to": {"lat": 33.7100, "lng": 73.0600}
                    }
                ]
            elif self._crisis_type == "road_accident":
                return [
                    {
                        "segment_id": "seg_m2_km45",
                        "road_name": "M-2 Motorway KM 45",
                        "congestion_score": 100,
                        "anomaly_detected": True,
                        "anomaly_type": "SEVERE_CONGESTION",
                        "from": {"lat": 32.95, "lng": 73.05},
                        "to": {"lat": 33.05, "lng": 73.15}
                    },
                    {
                        "segment_id": "seg_n5_bhera",
                        "road_name": "N-5 National Highway (Bhera)",
                        "congestion_score": random.randint(25, 40),
                        "anomaly_detected": False,
                        "anomaly_type": None,
                        "from": {"lat": 32.48, "lng": 72.92},
                        "to": {"lat": 32.55, "lng": 73.00}
                    }
                ]
            elif self._crisis_type == "heatwave":
                return [
                    {
                        "segment_id": "seg_lahore_mall",
                        "road_name": "Mall Road Lahore",
                        "congestion_score": random.randint(45, 60),
                        "anomaly_detected": False,
                        "anomaly_type": None,
                        "from": {"lat": 31.55, "lng": 74.33},
                        "to": {"lat": 31.57, "lng": 74.36}
                    }
                ]
            elif self._crisis_type == "infrastructure_failure":
                return [
                    {
                        "segment_id": "seg_i8_main",
                        "road_name": "I-8 Main Road",
                        "congestion_score": random.randint(60, 75),
                        "anomaly_detected": True,
                        "anomaly_type": "HIGH_CONGESTION",
                        "from": {"lat": 33.6580, "lng": 73.0740},
                        "to": {"lat": 33.6650, "lng": 73.0800}
                    }
                ]
            elif self._crisis_type == "earthquake":
                return [
                    {
                        "segment_id": "seg_saddar_rwp",
                        "road_name": "Saddar Road Rawalpindi",
                        "congestion_score": random.randint(85, 100),
                        "anomaly_detected": True,
                        "anomaly_type": "SEVERE_CONGESTION",
                        "from": {"lat": 33.5930, "lng": 73.0400},
                        "to": {"lat": 33.5700, "lng": 73.0500}
                    },
                    {
                        "segment_id": "seg_murree_rd",
                        "road_name": "Murree Road Rawalpindi",
                        "congestion_score": random.randint(70, 85),
                        "anomaly_detected": True,
                        "anomaly_type": "HIGH_CONGESTION",
                        "from": {"lat": 33.5800, "lng": 73.0600},
                        "to": {"lat": 33.6000, "lng": 73.0700}
                    },
                    {
                        "segment_id": "seg_gt_road",
                        "road_name": "GT Road Rawalpindi",
                        "congestion_score": random.randint(50, 70),
                        "anomaly_detected": True,
                        "anomaly_type": "MODERATE_CONGESTION",
                        "from": {"lat": 33.5500, "lng": 73.0300},
                        "to": {"lat": 33.5800, "lng": 73.0500}
                    }
                ]
            elif self._crisis_type == "landslide":
                return [
                    {
                        "segment_id": "seg_murree_isl",
                        "road_name": "Murree-Islamabad Road",
                        "congestion_score": 100,
                        "anomaly_detected": True,
                        "anomaly_type": "ROAD_BLOCKED",
                        "from": {"lat": 33.7300, "lng": 73.0900},
                        "to": {"lat": 33.7500, "lng": 73.1200}
                    },
                    {
                        "segment_id": "seg_bari_imam",
                        "road_name": "Bari Imam Road",
                        "congestion_score": random.randint(80, 95),
                        "anomaly_detected": True,
                        "anomaly_type": "HIGH_CONGESTION",
                        "from": {"lat": 33.7350, "lng": 73.0850},
                        "to": {"lat": 33.7400, "lng": 73.0950}
                    }
                ]
        # Normal traffic
        return [
            {
                "segment_id": f"seg_{i}",
                "road_name": name,
                "congestion_score": random.randint(10, 40),
                "anomaly_detected": False,
                "anomaly_type": None
            }
            for i, name in enumerate(["Constitution Ave", "Margalla Road", "GT Road", "IJP Road"])
        ]
