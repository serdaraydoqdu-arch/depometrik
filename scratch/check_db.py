import pg8000.dbapi
import ssl

# Database credentials
host = "db.napqcopzozmipkuzmdee.supabase.co"
password = "opI2AxavJxLZFdM0"
user = "postgres"
database = "postgres"

# Try different ports and ssl configurations
configs = [
    {"port": 6543, "use_ssl": True, "desc": "Port 6543 (Pooler) with SSL"},
    {"port": 5432, "use_ssl": True, "desc": "Port 5432 (Direct) with SSL"},
    {"port": 6543, "use_ssl": False, "desc": "Port 6543 (Pooler) without SSL"},
    {"port": 5432, "use_ssl": False, "desc": "Port 5432 (Direct) without SSL"},
]

connected = False
for cfg in configs:
    port = cfg["port"]
    use_ssl = cfg["use_ssl"]
    desc = cfg["desc"]
    print(f"Trying connection: {desc}...")
    
    try:
        ssl_context = ssl.create_default_context() if use_ssl else None
        if ssl_context:
            # Supabase self-signed certificates might not verify normally, disable verification
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE
            
        conn = pg8000.dbapi.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database,
            ssl_context=ssl_context,
            timeout=10
        )
        cursor = conn.cursor()
        print(f"CONNECTED SUCCESSFULLY using {desc}!")
        
        # Query pg_policies
        cursor.execute("SELECT policyname, tablename, cmd, roles, qual, with_check FROM pg_policies WHERE schemaname = 'public' AND tablename = 'profiles';")
        policies = cursor.fetchall()
        
        print("\n--- Policies on table public.profiles ---")
        if not policies:
            print("No policies found on public.profiles!")
        for p in policies:
            print(f"Policy: {p[0]}")
            print(f"  Table: {p[1]}")
            print(f"  Command: {p[2]}")
            print(f"  Roles: {p[3]}")
            print(f"  Using: {p[4]}")
            print(f"  With Check: {p[5]}")
            print("-" * 40)
            
        cursor.close()
        conn.close()
        connected = True
        break
    except Exception as e:
        print(f"Failed {desc}: {e}")

if not connected:
    print("\nCould not connect to database on any configuration. This is likely due to firewall/ISP blocking Postgres ports 5432/6543.")
