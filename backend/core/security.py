"""
Security utilities for authentication and authorization.
"""

from datetime import datetime, timedelta
from typing import Optional, Union
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from core.config import settings
from core.database import get_db

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT token scheme
security = HTTPBearer()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Generate password hash"""
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """Create JWT refresh token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> Optional[dict]:
    """Verify and decode JWT token"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


def authenticate_user(email: str, password: str, db: Session) -> Union[dict, bool]:
    """Authenticate user with email and password"""
    # Mock authentication for now - replace with actual database lookup
    mock_users = {
        "demo@decision.is": {
            "id": 1,
            "email": "demo@decision.is",
            "full_name": "Demo User",
            "hashed_password": get_password_hash("demo123"),
            "is_active": True
        }
    }
    
    user = mock_users.get(email)
    if not user:
        return False
        
    if not verify_password(password, user["hashed_password"]):
        return False
        
    return user


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> dict:
    """Get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        token = credentials.credentials
        payload = verify_token(token)
        
        if payload is None:
            raise credentials_exception
            
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
            
    except JWTError:
        raise credentials_exception
    
    # Mock user lookup - replace with actual database query
    mock_users = {
        "demo@decision.is": {
            "id": 1,
            "email": "demo@decision.is",
            "full_name": "Demo User",
            "is_active": True
        }
    }
    
    user = mock_users.get(email)
    if user is None:
        raise credentials_exception
        
    return user
