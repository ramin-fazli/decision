"""User schemas for authentication and user management"""

from typing import Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool = True


class UserCreate(UserBase):
    """Schema for creating a new user"""
    password: str


class UserUpdate(UserBase):
    """Schema for updating user information"""
    password: Optional[str] = None


class UserResponse(UserBase):
    """Schema for user responses (excluding password)"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    """JWT token response schema"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class TokenData(BaseModel):
    """Token payload data schema"""
    email: Optional[str] = None
    user_id: Optional[int] = None


class LoginRequest(BaseModel):
    """Login request schema"""
    email: EmailStr
    password: str
