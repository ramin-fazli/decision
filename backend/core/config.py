"""
Core configuration module for the Decision platform.
Manages environment variables and application settings.
"""

from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List, Optional
import os
from functools import lru_cache
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Application
    APP_NAME: str = "Decision Platform"
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    API_VERSION: str = "v1"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    DATABASE_URL: Optional[str] = None
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "decision"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "postgres"
    
    # Supabase Configuration
    SUPABASE_URL: str = "https://poobxzfazqitrzmxsizg.supabase.co"
    SUPABASE_KEY: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvb2J4emZhenFpdHJ6bXhzaXpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwNjc3MDksImV4cCI6MjA2OTY0MzcwOX0.pLjT1tqXoEB8e45bSKOhF5bQx8QhPEZylhAMcKcdCmE"
    SUPABASE_DB_PASSWORD: Optional[str] = None
    
    # Redis
    REDIS_URL: Optional[str] = None
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    
    # ML Configuration
    ML_MODEL_PATH: str = "/app/models"
    ML_FEATURE_STORE_PATH: str = "/app/features"
    ML_EXPERIMENT_TRACKING: bool = True
    MLFLOW_TRACKING_URI: Optional[str] = None
    
    # API Configuration
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]
    ALLOWED_HOSTS: List[str] = ["*"]
    API_RATE_LIMIT: str = "100/minute"
    
    # File Upload
    MAX_UPLOAD_SIZE: int = 100 * 1024 * 1024  # 100MB
    ALLOWED_FILE_TYPES: List[str] = [".csv", ".xlsx", ".json"]
    UPLOAD_PATH: str = "/app/uploads"
    
    # Celery (Task Queue)
    CELERY_BROKER_URL: Optional[str] = None
    CELERY_RESULT_BACKEND: Optional[str] = None
    
    # Cloud Providers
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    
    GCP_PROJECT_ID: Optional[str] = None
    GCP_CREDENTIALS_PATH: Optional[str] = None
    
    AZURE_SUBSCRIPTION_ID: Optional[str] = None
    AZURE_RESOURCE_GROUP: Optional[str] = None
    
    # Monitoring and Logging
    LOG_LEVEL: str = "INFO"
    SENTRY_DSN: Optional[str] = None
    
    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def build_database_url(cls, v: Optional[str]) -> str:
        """Build database URL if not provided"""
        if isinstance(v, str):
            return v
        
        # Use environment variables directly since we can't access other field values in v2
        import os
        
        # Check if DATABASE_URL is set directly
        database_url = os.getenv('DATABASE_URL')
        if database_url:
            return database_url
        
        # Use Supabase PostgreSQL configuration
        supabase_url = os.getenv('SUPABASE_URL', 'https://poobxzfazqitrzmxsizg.supabase.co')
        
        # Extract project reference from Supabase URL
        supabase_host = supabase_url.replace('https://', '').replace('http://', '')
        project_ref = supabase_host.split('.')[0]  # poobxzfazqitrzmxsizg
        
        # Supabase PostgreSQL connection details
        db_host = f"db.{project_ref}.supabase.co"
        db_port = "5432"
        db_name = "postgres"
        db_user = "postgres"
        
        # Get the database password from environment
        db_password = os.getenv('SUPABASE_DB_PASSWORD')
        
        if not db_password:
            raise ValueError(
                "SUPABASE_DB_PASSWORD environment variable is required. "
                "Please set it to your Supabase database password. "
                "You can find this in Supabase Dashboard > Settings > Database"
            )
        
        # URL encode the password in case it has special characters
        from urllib.parse import quote_plus
        encoded_password = quote_plus(db_password)
        
        # Add connection parameters for better reliability with Supabase
        connection_params = [
            "sslmode=require",
            "connect_timeout=30",
            "application_name=decision-platform"
        ]
        params_string = "&".join(connection_params)
        
        return f"postgresql://{db_user}:{encoded_password}@{db_host}:{db_port}/{db_name}?{params_string}"
    
    @field_validator("REDIS_URL", mode="before")
    @classmethod
    def build_redis_url(cls, v: Optional[str]) -> str:
        """Build Redis URL if not provided"""
        if isinstance(v, str):
            return v
        
        import os
        redis_host = os.getenv('REDIS_HOST', 'localhost')
        redis_port = os.getenv('REDIS_PORT', '6379')
        redis_db = os.getenv('REDIS_DB', '0')
        
        return f"redis://{redis_host}:{redis_port}/{redis_db}"
    
    @field_validator("CELERY_BROKER_URL", mode="before")
    @classmethod
    def build_celery_broker_url(cls, v: Optional[str]) -> str:
        """Build Celery broker URL if not provided"""
        if isinstance(v, str):
            return v
        
        import os
        redis_host = os.getenv('REDIS_HOST', 'localhost')
        redis_port = os.getenv('REDIS_PORT', '6379')
        redis_db = os.getenv('REDIS_DB', '0')
        
        return f"redis://{redis_host}:{redis_port}/{redis_db}"
    
    @field_validator("CELERY_RESULT_BACKEND", mode="before")
    @classmethod
    def build_celery_result_backend(cls, v: Optional[str]) -> str:
        """Build Celery result backend URL if not provided"""
        if isinstance(v, str):
            return v
        
        import os
        redis_host = os.getenv('REDIS_HOST', 'localhost')
        redis_port = os.getenv('REDIS_PORT', '6379')
        redis_db = os.getenv('REDIS_DB', '0')
        
        return f"redis://{redis_host}:{redis_port}/{redis_db}"
    
    @field_validator("DEBUG", mode="before")
    @classmethod
    def parse_debug(cls, v):
        """Parse DEBUG from string if needed"""
        if isinstance(v, str):
            return v.lower() in ("true", "1", "yes", "on")
        return v
    
    model_config = {"env_file": ".env", "case_sensitive": True}


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()


# Global settings instance
settings = get_settings()
