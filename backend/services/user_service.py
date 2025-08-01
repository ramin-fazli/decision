"""
User service for handling user-related operations.
"""

from typing import Optional, List
from sqlalchemy.orm import Session
from api.schemas.user import UserCreate, UserUpdate
from core.security import get_password_hash


class UserService:
    """Service class for user operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_user(self, user_data: UserCreate) -> dict:
        """Create a new user"""
        # Mock user creation - replace with actual database operations
        hashed_password = get_password_hash(user_data.password)
        
        # Mock user data
        user = {
            "id": 1,  # In real implementation, this would be auto-generated
            "email": user_data.email,
            "full_name": user_data.full_name,
            "is_active": user_data.is_active,
            "created_at": "2024-08-01T18:00:00",
            "updated_at": "2024-08-01T18:00:00"
        }
        
        return user
    
    def get_user_by_email(self, email: str) -> Optional[dict]:
        """Get user by email"""
        # Mock user lookup - replace with actual database query
        mock_users = {
            "demo@decision.is": {
                "id": 1,
                "email": "demo@decision.is",
                "full_name": "Demo User",
                "is_active": True,
                "created_at": "2024-08-01T18:00:00",
                "updated_at": "2024-08-01T18:00:00"
            }
        }
        
        return mock_users.get(email)
    
    def get_user_by_id(self, user_id: int) -> Optional[dict]:
        """Get user by ID"""
        # Mock user lookup - replace with actual database query
        if user_id == 1:
            return {
                "id": 1,
                "email": "demo@decision.is",
                "full_name": "Demo User",
                "is_active": True,
                "created_at": "2024-08-01T18:00:00",
                "updated_at": "2024-08-01T18:00:00"
            }
        return None
    
    def update_user(self, user_id: int, user_data: UserUpdate) -> Optional[dict]:
        """Update user information"""
        # Mock user update - replace with actual database operations
        existing_user = self.get_user_by_id(user_id)
        if not existing_user:
            return None
        
        # Update fields
        if user_data.email:
            existing_user["email"] = user_data.email
        if user_data.full_name:
            existing_user["full_name"] = user_data.full_name
        if user_data.is_active is not None:
            existing_user["is_active"] = user_data.is_active
        
        existing_user["updated_at"] = "2024-08-01T18:00:00"
        
        return existing_user
    
    def delete_user(self, user_id: int) -> bool:
        """Delete user by ID"""
        # Mock user deletion - replace with actual database operations
        existing_user = self.get_user_by_id(user_id)
        return existing_user is not None
    
    def list_users(self, skip: int = 0, limit: int = 100) -> List[dict]:
        """List users with pagination"""
        # Mock user listing - replace with actual database query
        mock_users = [
            {
                "id": 1,
                "email": "demo@decision.is",
                "full_name": "Demo User",
                "is_active": True,
                "created_at": "2024-08-01T18:00:00",
                "updated_at": "2024-08-01T18:00:00"
            }
        ]
        
        return mock_users[skip:skip + limit]
