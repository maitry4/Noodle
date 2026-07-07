import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "noodle.db")

def get_db():
    conn = sqlite3.connect(DB_PATH, timeout=10.0)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    with get_db() as conn:
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS stats (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                rant_resolved INTEGER DEFAULT 28
            )
        ''')
        
        cursor.execute('SELECT COUNT(*) FROM stats')
        if cursor.fetchone()[0] == 0:
            cursor.execute('INSERT INTO stats (id, rant_resolved) VALUES (1, 28)')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS rate_limits (
                device_uuid TEXT PRIMARY KEY,
                count INTEGER DEFAULT 1,
                first_request_ts REAL
            )
        ''')
        
        conn.commit()
