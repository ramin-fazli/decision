"""
Core configuration module for the Decision platform.
Manages environment variables and application settings.
"""

from pydantic_settings import BaseSettings
from pydantic import validator
from typing import List, Optional
import os
from functools import lru_cache


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
    
    @validator("DATABASE_URL", pre=True)
    def build_database_url(cls, v: Optional[str], values: dict) -> str:
        """Build database URL if not provided"""
        if isinstance(v, str):
            return v
        
        return (
            f"postgresql://{values.get('DB_USER')}:{values.get('DB_PASSWORD')}"
            f"@{values.get('DB_HOST')}:{values.get('DB_PORT')}/{values.get('DB_NAME')}"
        )
    
    @validator("REDIS_URL", pre=True)
    def build_redis_url(cls, v: Optional[str], values: dict) -> str:
        """Build Redis URL if not provided"""
        if isinstance(v, str):
            return v
        
        return (
            f"redis://{values.get('REDIS_HOST')}:{values.get('REDIS_PORT')}"
            f"/{values.get('REDIS_DB')}"
        )
    
    @validator("CELERY_BROKER_URL", pre=True)
    def build_celery_broker_url(cls, v: Optional[str], values: dict) -> str:
        """Build Celery broker URL if not provided"""
        if isinstance(v, str):
            return v
        
        redis_url = values.get("REDIS_URL") or cls.build_redis_url(None, values)
        return redis_url
    
    @validator("CELERY_RESULT_BACKEND", pre=True)
    def build_celery_result_backend(cls, v: Optional[str], values: dict) -> str:
        """Build Celery result backend URL if not provided"""
        if isinstance(v, str):
            return v
        
        redis_url = values.get("REDIS_URL") or cls.build_redis_url(None, values)
        return redis_url
    
    @validator("DEBUG", pre=True)
    def parse_debug(cls, v):
        """Parse DEBUG from string if needed"""
        if isinstance(v, str):
            return v.lower() in ("true", "1", "yes", "on")
        return v
    
    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()


# Global settings instance
settings = get_settings()
