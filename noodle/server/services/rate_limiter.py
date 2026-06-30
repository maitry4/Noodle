import time
from services.db import get_db

MAX_REQUESTS = 10
WINDOW_SECONDS = 24 * 60 * 60

def check_rate_limit(device_uuid: str) -> bool:
    now = time.time()
    
    with get_db() as conn:
        cursor = conn.cursor()
        
        cursor.execute('SELECT count, first_request_ts FROM rate_limits WHERE device_uuid = ?', (device_uuid,))
        row = cursor.fetchone()
        
        if row is None:
            cursor.execute('INSERT INTO rate_limits (device_uuid, count, first_request_ts) VALUES (?, ?, ?)',
                           (device_uuid, 1, now))
            conn.commit()
            return True
            
        count, first_request_ts = row['count'], row['first_request_ts']
        elapsed = now - first_request_ts
        
        if elapsed >= WINDOW_SECONDS:
            cursor.execute('UPDATE rate_limits SET count = 1, first_request_ts = ? WHERE device_uuid = ?',
                           (now, device_uuid))
            conn.commit()
            return True
            
        if count >= MAX_REQUESTS:
            return False
            
        cursor.execute('UPDATE rate_limits SET count = count + 1 WHERE device_uuid = ?', (device_uuid,))
        conn.commit()
        return True
