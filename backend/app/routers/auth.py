from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import User, UserRole
from app.schemas.schemas import (
    UserCreate, UserLogin, UserOut, TokenResponse, ApiResponse, ApiError
)
from app.security.passwords import get_password_hash, verify_password
from app.security.jwt import create_access_token, create_refresh_token, decode_token
from app.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=ApiResponse[UserOut], status_code=status.HTTP_201_CREATED)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone == user_in.phone).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this phone number is already registered"
        )
    if user_in.health_worker_id:
        hw_existing = db.query(User).filter(User.health_worker_id == user_in.health_worker_id).first()
        if hw_existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Health worker ID already registered"
            )

    new_user = User(
        phone=user_in.phone,
        email=user_in.email,
        display_name=user_in.display_name,
        role=user_in.role or UserRole.HEALTH_WORKER,
        health_worker_id=user_in.health_worker_id,
        clinic_id=user_in.clinic_id,
        hashed_password=get_password_hash(user_in.password),
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return ApiResponse(data=UserOut.model_validate(new_user), message="User registered successfully")

@router.post("/login", response_model=ApiResponse[TokenResponse])
def login(login_in: UserLogin, db: Session = Depends(get_db)):
    # Support phone or health_worker_id login
    user = db.query(User).filter(
        (User.phone == login_in.phone_or_id) | (User.health_worker_id == login_in.phone_or_id)
    ).first()

    if not user or not verify_password(login_in.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials. Check your phone/ID and password."
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled. Contact clinic admin."
        )

    token_data = {"sub": user.id, "role": user.role}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    return ApiResponse(
        data=TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user=UserOut.model_validate(user)
        ),
        message="Login successful"
    )

@router.post("/refresh", response_model=ApiResponse[TokenResponse])
def refresh_token(refresh_token_str: str, db: Session = Depends(get_db)):
    payload = decode_token(refresh_token_str)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id, User.is_active == True).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    token_data = {"sub": user.id, "role": user.role}
    new_access = create_access_token(token_data)
    new_refresh = create_refresh_token(token_data)

    return ApiResponse(
        data=TokenResponse(
            access_token=new_access,
            refresh_token=new_refresh,
            token_type="bearer",
            user=UserOut.model_validate(user)
        ),
        message="Token refreshed"
    )

@router.post("/logout", response_model=ApiResponse[bool])
def logout(current_user: User = Depends(get_current_user)):
    return ApiResponse(data=True, message="Logged out successfully")

@router.get("/me", response_model=ApiResponse[UserOut])
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return ApiResponse(data=UserOut.model_validate(current_user), message="Profile fetched")
