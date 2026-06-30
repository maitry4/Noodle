import time
from services.db import get_db

MAX_REQUESTS = 10
WINDOW_SECONDS = 24 * 60 * 60  # 24 hours

def check_rate_limit(device_uuid: str) -> bool:
    """
    Returns True if the request is allowed, False if the limit is reached.
    Resets the window automatically when 24 hours have passed.
    """
    now = time.time()
    
    with get_db() as conn:
        cursor = conn.cursor()
        
        cursor.execute('SELECT count, first_request_ts FROM rate_limits WHERE device_uuid = ?', (device_uuid,))
        row = cursor.fetchone()
        
        if row is None:
            # First ever request from this device
            cursor.execute('INSERT INTO rate_limits (device_uuid, count, first_request_ts) VALUES (?, ?, ?)',
                           (device_uuid, 1, now))
            conn.commit()
            return True
            
        count, first_request_ts = row['count'], row['first_request_ts']
        elapsed = now - first_request_ts
        
        if elapsed >= WINDOW_SECONDS:
            # 24-hour window has passed — reset
            cursor.execute('UPDATE rate_limits SET count = 1, first_request_ts = ? WHERE device_uuid = ?',
                           (now, device_uuid))
            conn.commit()
            return True
            
        if count >= MAX_REQUESTS:
            return False
            
        cursor.execute('UPDATE rate_limits SET count = count + 1 WHERE device_uuid = ?', (device_uuid,))
        conn.commit()
        return True
