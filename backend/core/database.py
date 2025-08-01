"""
Database configuration and connection management for Decision platform.
"""

from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import logging

from core.config import settings

logger = logging.getLogger(__name__)

# Create SQLAlchemy engine with better connection handling
engine = create_engine(
    settings.DATABASE_URL,
    connect_args={
        "connect_timeout": 30,
        "options": "-c statement_timeout=30s"
    } if "postgresql" in settings.DATABASE_URL else {
        "check_same_thread": False
    },
    echo=settings.DEBUG,
    pool_recycle=3600,  # Recycle connections every hour
    pool_pre_ping=True  # Verify connections before use
)

# Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class for models
Base = declarative_base()

# Metadata for database operations
metadata = MetaData()


def get_db():
    """
    Dependency to get database session.
    Used with FastAPI's Depends() for automatic session management.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


async def init_db():
    """Initialize database tables with retry logic"""
    import time
    max_retries = 3
    retry_delay = 5  # seconds
    
    for attempt in range(max_retries):
        try:
            logger.info(f"Attempting database connection (attempt {attempt + 1}/{max_retries})")
            
            # Import all models to ensure they are registered with SQLAlchemy
            from models import user, prediction, dataset  # noqa
            
            # Test connection first
            with engine.connect() as conn:
                logger.info("Database connection successful")
            
            # Create all tables
            Base.metadata.create_all(bind=engine)
            logger.info("Database tables created successfully")
            return
            
        except Exception as e:
            logger.error(f"Failed to initialize database (attempt {attempt + 1}): {e}")
            
            if attempt < max_retries - 1:
                logger.info(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
                retry_delay *= 2  # Exponential backoff
            else:
                logger.error("All database connection attempts failed")
                raise


async def close_db():
    """Close database connections"""
    try:
        engine.dispose()
        logger.info("Database connections closed")
    except Exception as e:
        logger.error(f"Error closing database connections: {e}")


# Database health check
def check_db_health() -> bool:
    """Check if database is healthy"""
    try:
        with engine.connect() as connection:
            connection.execute("SELECT 1")
        return True
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return False
