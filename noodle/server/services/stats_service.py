from services.db import get_db

def increment_rant_resolved() -> int:
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute('UPDATE stats SET rant_resolved = rant_resolved + 1 WHERE id = 1')
        conn.commit()
        
        cursor.execute('SELECT rant_resolved FROM stats WHERE id = 1')
        return cursor.fetchone()[0]

def get_rant_resolved() -> int:
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute('SELECT rant_resolved FROM stats WHERE id = 1')
        row = cursor.fetchone()
        return row[0] if row else 0