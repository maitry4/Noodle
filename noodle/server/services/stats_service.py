import json
import os

STATS_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "visit_stats.json")


def _read() -> dict:
    try:
        with open(STATS_FILE, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"rant_resolved": 0}


def _write(data: dict):
    os.makedirs(os.path.dirname(STATS_FILE), exist_ok=True)
    with open(STATS_FILE, "w") as f:
        json.dump(data, f)


def increment_rant_resolved() -> int:
    data = _read()
    data["rant_resolved"] = data.get("rant_resolved", 0) + 1
    _write(data)
    return data["rant_resolved"]


def get_rant_resolved() -> int:
    return _read().get("rant_resolved", 0)