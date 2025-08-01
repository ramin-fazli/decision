#!/usr/bin/env python3
"""
Debug script to test environment variable loading
"""

import os
from pathlib import Path
from dotenv import load_dotenv

print("=== Environment Debug ===")
print(f"Current working directory: {os.getcwd()}")
print(f"Python path: {__file__}")

# Check if .env file exists
env_file = Path(".env")
print(f".env file exists: {env_file.exists()}")
if env_file.exists():
    print(f".env file path: {env_file.absolute()}")
    print(f".env file size: {env_file.stat().st_size} bytes")
    
    # Read and print .env file contents
    print("\n.env file contents:")
    with open(env_file, 'r') as f:
        print(f.read())

# Try loading .env
print("\n=== Loading .env ===")
load_result = load_dotenv()
print(f"load_dotenv() result: {load_result}")

# Check environment variables
print("\n=== Environment Variables ===")
password = os.getenv('SUPABASE_DB_PASSWORD')
print(f"SUPABASE_DB_PASSWORD: {password}")
print(f"Password length: {len(password) if password else 0}")

# List all SUPABASE env vars
supabase_vars = {k: v for k, v in os.environ.items() if k.startswith('SUPABASE')}
print(f"All SUPABASE env vars: {list(supabase_vars.keys())}")

# Try building database URL
try:
    from core.config import Settings
    settings = Settings()
    print(f"Settings loaded successfully")
    print(f"DATABASE_URL: {settings.DATABASE_URL}")
except Exception as e:
    print(f"Error loading settings: {e}")

print("=== Debug Complete ===")
