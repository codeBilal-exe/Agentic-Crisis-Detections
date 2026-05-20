import os
from datetime import datetime, timezone

import firebase_admin
from dotenv import load_dotenv
from firebase_admin import credentials, db


load_dotenv()


class FirebaseService:
    _initialized = False

    def __init__(self):
        if FirebaseService._initialized or firebase_admin._apps:
            FirebaseService._initialized = True
            return

        try:
            cred_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                "firebase_config",
                "serviceAccountKey.json",
            )
            database_url = os.getenv("FIREBASE_DATABASE_URL", "").strip()

            if os.path.exists(cred_path) and database_url:
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred, {"databaseURL": database_url})
                FirebaseService._initialized = True
            else:
                print(
                    "WARNING: Firebase disabled. Missing service account file or FIREBASE_DATABASE_URL."
                )
        except Exception as error:
            print(f"WARNING: Firebase initialization failed: {error}")

    @property
    def _is_connected(self) -> bool:
        return bool(firebase_admin._apps)

    def set(self, path: str, value):
        if not self._is_connected:
            print(f"[Firebase MOCK] SET {path}")
            return
        db.reference(path).set(value)

    def update(self, path: str, value: dict):
        if not self._is_connected:
            print(f"[Firebase MOCK] UPDATE {path}")
            return
        db.reference(path).update(value)

    def get(self, path: str):
        if not self._is_connected:
            print(f"[Firebase MOCK] GET {path}")
            return None
        return db.reference(path).get()

    def push(self, path: str, value: dict):
        if not self._is_connected:
            print(f"[Firebase MOCK] PUSH {path}")
            return None
        return db.reference(path).push(value)

    def reset_to_baseline(self):
        now = datetime.now(timezone.utc).isoformat()
        baseline = {
            "system_state": {
                "mode": "monitoring",
                "last_updated": now,
                "active_crisis_count": 0,
                "signal_ingestion_active": True,
            },
            "active_crises": {},
            "units": {
                "1122-ISB-01": {
                    "unit_id": "1122-ISB-01",
                    "name": "Rescue 1122 - Alpha Team",
                    "type": "general_rescue",
                    "status": "available",
                    "base_lat": 33.7294,
                    "base_lng": 73.0931,
                    "current_lat": 33.7294,
                    "current_lng": 73.0931,
                    "destination": None,
                    "eta_minutes": None,
                    "assigned_crisis_id": None,
                    "last_updated": now,
                },
                "1122-ISB-02": {
                    "unit_id": "1122-ISB-02",
                    "name": "Rescue 1122 - Bravo Team",
                    "type": "medical",
                    "status": "available",
                    "base_lat": 33.6938,
                    "base_lng": 73.0651,
                    "current_lat": 33.6938,
                    "current_lng": 73.0651,
                    "destination": None,
                    "eta_minutes": None,
                    "assigned_crisis_id": None,
                    "last_updated": now,
                },
                "1122-ISB-03": {
                    "unit_id": "1122-ISB-03",
                    "name": "Rescue 1122 - Charlie Team",
                    "type": "fire",
                    "status": "available",
                    "base_lat": 33.6611,
                    "base_lng": 73.0169,
                    "current_lat": 33.6611,
                    "current_lng": 73.0169,
                    "destination": None,
                    "eta_minutes": None,
                    "assigned_crisis_id": None,
                    "last_updated": now,
                },
                "1122-ISB-04": {
                    "unit_id": "1122-ISB-04",
                    "name": "Rescue 1122 - Delta Team (Flood)",
                    "type": "flood_rescue",
                    "status": "available",
                    "base_lat": 33.6701,
                    "base_lng": 73.0553,
                    "current_lat": 33.6701,
                    "current_lng": 73.0553,
                    "destination": None,
                    "eta_minutes": None,
                    "assigned_crisis_id": None,
                    "last_updated": now,
                },
                "pdma-team-01": {
                    "unit_id": "pdma-team-01",
                    "name": "PDMA Assessment Team - Islamabad",
                    "type": "pdma_assessment",
                    "status": "standby",
                    "base_lat": 33.7215,
                    "base_lng": 73.0433,
                    "current_lat": 33.7215,
                    "current_lng": 73.0433,
                    "destination": None,
                    "eta_minutes": None,
                    "assigned_crisis_id": None,
                    "last_updated": now,
                },
            },
            "alerts": {},
            "routes": {"active_reroutes": {}},
            "agent_logs": {},
            "signal_feed": {"recent_signals": {}},
            "outcome_metrics": {
                "before": {
                    "congestion_level": 20,
                    "units_available": 5,
                    "alerts_active": 0,
                    "estimated_stranded_vehicles": 0,
                },
                "after": {
                    "congestion_level": 20,
                    "units_available": 5,
                    "alerts_active": 0,
                    "estimated_stranded_vehicles": 0,
                },
                "resolution_time_minutes": 0,
                "last_updated": now,
            },
        }
        self.set("/", baseline)
        return baseline
