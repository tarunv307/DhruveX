from typing import List, Optional
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import (
    Screening, Patient, User, SensorSession, GaitFeatures, RiskResult
)
from app.schemas.schemas import (
    ScreeningCreate, ScreeningOut, SensorSessionCreate, SensorSessionOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/screenings", tags=["Screenings"])

@router.post("", response_model=ApiResponse[ScreeningOut], status_code=status.HTTP_201_CREATED)
def create_screening(
    screening_in: ScreeningCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == screening_in.patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    screening = Screening(
        patient_id=screening_in.patient_id,
        conducted_by=current_user.id,
        status="IN_PROGRESS",
        is_demo=screening_in.is_demo
    )
    db.add(screening)
    db.commit()
    db.refresh(screening)

    return ApiResponse(
        data=ScreeningOut.model_validate(screening),
        message="Screening session initialized"
    )

@router.get("/{screening_id}", response_model=ApiResponse[ScreeningOut])
def get_screening(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    screening = db.query(Screening).filter(Screening.id == screening_id).first()
    if not screening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screening session not found")

    return ApiResponse(data=ScreeningOut.model_validate(screening), message="Screening session retrieved")

@router.post("/{screening_id}/sensor-sessions", response_model=ApiResponse[SensorSessionOut])
def add_sensor_session(
    screening_id: str,
    session_in: SensorSessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    screening = db.query(Screening).filter(Screening.id == screening_id).first()
    if not screening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screening not found")

    sensor_session = SensorSession(
        screening_id=screening_id,
        device_id=session_in.device_id,
        test_type=session_in.test_type,
        duration_seconds=session_in.duration_seconds,
        signal_quality=session_in.signal_quality,
        battery_level=session_in.battery_level,
        raw_packet_count=session_in.raw_packet_count,
        status=session_in.status
    )
    db.add(sensor_session)
    db.commit()
    db.refresh(sensor_session)

    return ApiResponse(data=SensorSessionOut.model_validate(sensor_session), message="Sensor session recorded")

@router.post("/{screening_id}/complete", response_model=ApiResponse[ScreeningOut])
def complete_screening(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    screening = db.query(Screening).filter(Screening.id == screening_id).first()
    if not screening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screening not found")

    screening.status = "COMPLETED"
    screening.completed_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(screening)

    return ApiResponse(data=ScreeningOut.model_validate(screening), message="Screening completed")
