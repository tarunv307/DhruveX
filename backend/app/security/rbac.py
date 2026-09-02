from typing import List
from fastapi import HTTPException, status, Depends
from app.models.entities import User, UserRole

def require_roles(allowed_roles: List[str]):
    def role_checker(current_user: User):
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required roles: {allowed_roles}"
            )
        return current_user
    return role_checker
