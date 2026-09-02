from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Referral, Patient, User
from app.schemas.schemas import (
    ReferralCreate, ReferralUpdate, ReferralOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/referrals", tags=["Referrals"])

@router.post("", response_model=ApiResponse[ReferralOut], status_code=status.HTTP_201_CREATED)
def create_referral(
    referral_in: ReferralCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == referral_in.patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    referral = Referral(
        patient_id=referral_in.patient_id,
        screening_id=referral_in.screening_id,
        clinic_id=referral_in.clinic_id,
        reason=referral_in.reason,
        priority=referral_in.priority.upper(),
        status="PENDING",
        preferred_date=referral_in.preferred_date,
        notes=referral_in.notes
    )
    db.add(referral)
    db.commit()
    db.refresh(referral)

    return ApiResponse(data=ReferralOut.model_validate(referral), message="Referral submitted")

@router.get("", response_model=ApiResponse[List[ReferralOut]])
def list_referrals(
    patient_id: Optional[str] = None,
    status_filter: Optional[str] = None,
    priority: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Referral)
    if patient_id:
        query = query.filter(Referral.patient_id == patient_id)
    if status_filter:
        query = query.filter(Referral.status == status_filter.upper())
    if priority:
        query = query.filter(Referral.priority == priority.upper())

    referrals = query.order_by(Referral.created_at.desc()).all()
    return ApiResponse(
        data=[ReferralOut.model_validate(r) for r in referrals],
        message="Referrals retrieved"
    )

@router.get("/{referral_id}", response_model=ApiResponse[ReferralOut])
def get_referral(
    referral_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    referral = db.query(Referral).filter(Referral.id == referral_id).first()
    if not referral:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Referral not found")
    return ApiResponse(data=ReferralOut.model_validate(referral), message="Referral retrieved")

@router.patch("/{referral_id}", response_model=ApiResponse[ReferralOut])
def update_referral(
    referral_id: str,
    referral_update: ReferralUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    referral = db.query(Referral).filter(Referral.id == referral_id).first()
    if not referral:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Referral not found")

    update_data = referral_update.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(referral, field, val.upper() if isinstance(val, str) and field in ["status", "priority"] else val)

    db.commit()
    db.refresh(referral)
    return ApiResponse(data=ReferralOut.model_validate(referral), message="Referral updated")
