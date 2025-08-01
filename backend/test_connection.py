#!/usr/bin/env python3
"""Test Supabase database connection"""

import os
import psycopg2
from urllib.parse import quote_plus
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_connection():
    # Get password from environment
    password = os.getenv('SUPABASE_DB_PASSWORD')
    print(f"Password loaded: {'Yes' if password else 'No'}")
    
    if not password:
        print("ERROR: SUPABASE_DB_PASSWORD not found in environment")
        return False
    
    # URL encode the password
    encoded_password = quote_plus(password)
    
    # Build connection string
    host = "db.poobxzfazqitrzmxsizg.supabase.co"
    port = "5432"
    database = "postgres"
    user = "postgres"
    
    # Try different connection methods
    print(f"Testing connection to {host}:{port}")
    print(f"Database: {database}")
    print(f"User: {user}")
    
    # Method 1: Direct psycopg2 connection
    try:
        print("\n=== Testing direct psycopg2 connection ===")
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password,
            connect_timeout=10  # 10 second timeout
        )
        print("✅ Direct psycopg2 connection successful!")
        conn.close()
        return True
        
    except psycopg2.OperationalError as e:
        print(f"❌ Direct psycopg2 connection failed: {e}")
        
    # Method 2: Connection with SSL
    try:
        print("\n=== Testing connection with SSL ===")
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password,
            sslmode='require',
            connect_timeout=10
        )
        print("✅ SSL connection successful!")
        conn.close()
        return True
        
    except psycopg2.OperationalError as e:
        print(f"❌ SSL connection failed: {e}")
    
    # Method 3: Connection string format
    try:
        print("\n=== Testing connection string format ===")
        conn_string = f"postgresql://{user}:{encoded_password}@{host}:{port}/{database}?sslmode=require"
        conn = psycopg2.connect(conn_string)
        print("✅ Connection string format successful!")
        conn.close()
        return True
        
    except psycopg2.OperationalError as e:
        print(f"❌ Connection string format failed: {e}")
    
    return False

if __name__ == "__main__":
    print("🔍 Testing Supabase database connection...")
    success = test_connection()
    
    if not success:
        print("\n💡 Possible solutions:")
        print("1. Check if your Supabase project is active (not paused)")
        print("2. Verify your firewall/antivirus isn't blocking port 5432")
        print("3. Check if you're behind a corporate firewall")
        print("4. Try connecting from Supabase dashboard to verify credentials")
        print("5. Consider using connection pooling or different SSL settings")
