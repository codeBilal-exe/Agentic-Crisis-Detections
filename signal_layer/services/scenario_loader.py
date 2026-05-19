import json
import os
from datetime import datetime, timezone
from services.signal_generator import SignalGenerator


# Shared generator instance
_generator = SignalGenerator()


class ScenarioLoader:
    def __init__(self):
        self.scenarios_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "scenarios"
        )
        self.generator = _generator

    def now_iso(self):
        return datetime.now(timezone.utc).isoformat()

    def list_available_scenarios(self) -> list:
        """Lists all available scenario JSON files."""
        scenarios = []
        if os.path.exists(self.scenarios_dir):
            for filename in os.listdir(self.scenarios_dir):
                if filename.endswith(".json"):
                    filepath = os.path.join(self.scenarios_dir, filename)
                    try:
                        with open(filepath, "r", encoding="utf-8") as f:
                            data = json.load(f)
                        scenarios.append({
                            "scenario_id": data.get("scenario_id", filename.replace(".json", "")),
                            "scenario_name": data.get("scenario_name", filename),
                            "crisis_type": data.get("crisis_type", "unknown"),
                            "location": data.get("location", ""),
                            "severity": data.get("severity", "MEDIUM"),
                            "description": data.get("description", "")
                        })
                    except Exception as e:
                        print(f"Error loading scenario {filename}: {e}")
        return scenarios

    def load_scenario(self, scenario_name: str) -> dict | None:
        """Loads a scenario by name (filename without extension)."""
        filepath = os.path.join(self.scenarios_dir, f"{scenario_name}.json")
        if not os.path.exists(filepath):
            return None
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading scenario {scenario_name}: {e}")
            return None

    def activate_scenario(self, scenario: dict):
        """Activates crisis mode on the signal generator based on scenario data."""
        crisis_type = scenario.get("crisis_type", "unknown")
        location = scenario.get("location", "Unknown")
        self.generator.activate_crisis_mode(crisis_type, location)

    def deactivate_scenario(self):
        """Returns signal generator to normal mode."""
        self.generator.deactivate_crisis_mode()


def get_shared_generator() -> SignalGenerator:
    """Returns the shared SignalGenerator instance so routers use the same one."""
    return _generator
