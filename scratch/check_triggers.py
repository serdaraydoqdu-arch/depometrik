import sqlite3

def check_triggers():
    conn = sqlite3.connect('e:/Depometrik/depometrik_powersync.db')
    cursor = conn.cursor()
    
    # Get all triggers
    cursor.execute("SELECT name, tbl_name, sql FROM sqlite_master WHERE type='trigger'")
    triggers = cursor.fetchall()
    
    print("--- TRIGGERS ---")
    for name, tbl_name, sql in triggers:
        print(f"Trigger: {name} on {tbl_name}")
        print(sql)
        print("-" * 40)

if __name__ == '__main__':
    check_triggers()
