import time

# UUID -> {"count": int, "first_request_ts": float}
_rate_store: dict[str, dict] = {}

MAX_REQUESTS = 10
WINDOW_SECONDS = 24 * 60 * 60  # 24 hours


def check_rate_limit(device_uuid: str) -> bool:
    """
    Returns True if the request is allowed, False if the limit is reached.
    Resets the window automatically when 24 hours have passed.
    """
    now = time.time()
    entry = _rate_store.get(device_uuid)

    if entry is None:
        # First ever request from this device
        _rate_store[device_uuid] = {"count": 1, "first_request_ts": now}
        return True

    elapsed = now - entry["first_request_ts"]

    if elapsed >= WINDOW_SECONDS:
        # 24-hour window has passed — reset
        _rate_store[device_uuid] = {"count": 1, "first_request_ts": now}
        return True

    if entry["count"] >= MAX_REQUESTS:
        return False

    entry["count"] += 1
    return True
