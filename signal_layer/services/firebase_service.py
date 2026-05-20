import os
import uuid
from datetime import datetime, timezone

import firebase_admin
from dotenv import load_dotenv
from firebase_admin import credentials, db


load_dotenv()


class FirebaseService:
    _initialized = False
    _mock_store = {}

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

    @property
    def diagnostics(self) -> dict:
        cred_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "firebase_config",
            "serviceAccountKey.json",
        )
        return {
            "connected": self._is_connected,
            "mode": "realtime" if self._is_connected else "mock",
            "database_url_configured": bool(os.getenv("FIREBASE_DATABASE_URL", "").strip()),
            "service_account_file_exists": os.path.exists(cred_path),
        }

    def set(self, path: str, value):
        if not self._is_connected:
            print(f"[Firebase MOCK] SET {path}")
            self._mock_set(path, value)
            return
        db.reference(path).set(value)

    def update(self, path: str, value: dict):
        if not self._is_connected:
            print(f"[Firebase MOCK] UPDATE {path}")
            self._mock_update(path, value)
            return
        db.reference(path).update(value)

    def get(self, path: str):
        if not self._is_connected:
            print(f"[Firebase MOCK] GET {path}")
            return self._mock_get(path)
        return db.reference(path).get()

    def push(self, path: str, value: dict):
        if not self._is_connected:
            print(f"[Firebase MOCK] PUSH {path}")
            key = f"mock_{uuid.uuid4().hex[:8]}"
            current = self._mock_get(path) or {}
            if not isinstance(current, dict):
                current = {}
            current[key] = value
            self._mock_set(path, current)
            return {"key": key}
        return db.reference(path).push(value)

    def _path_parts(self, path: str):
        cleaned = path.strip("/")
        return [part for part in cleaned.split("/") if part] if cleaned else []

    def _mock_set(self, path: str, value):
        parts = self._path_parts(path)
        if not parts:
            FirebaseService._mock_store = value if isinstance(value, dict) else {}
            return

        node = FirebaseService._mock_store
        for part in parts[:-1]:
            child = node.get(part)
            if not isinstance(child, dict):
                child = {}
                node[part] = child
            node = child
        node[parts[-1]] = value

    def _mock_get(self, path: str):
        parts = self._path_parts(path)
        node = FirebaseService._mock_store
        for part in parts:
            if not isinstance(node, dict) or part not in node:
                return None
            node = node[part]
        return node

    def _mock_update(self, path: str, value: dict):
        current = self._mock_get(path)
        if not isinstance(current, dict):
            current = {}
        current.update(value)
        self._mock_set(path, current)

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
            "dispatch_tickets": {},
            "monitoring_cycles": {},
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
