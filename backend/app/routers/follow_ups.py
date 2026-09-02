from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import FollowUp, Patient, User
from app.schemas.schemas import (
    FollowUpCreate, FollowUpUpdate, FollowUpOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/follow-ups", tags=["Follow-ups"])

@router.post("", response_model=ApiResponse[FollowUpOut], status_code=status.HTTP_201_CREATED)
def create_follow_up(
    follow_up_in: FollowUpCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == follow_up_in.patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    follow_up = FollowUp(
        patient_id=follow_up_in.patient_id,
        screening_id=follow_up_in.screening_id,
        due_date=follow_up_in.due_date,
        type=follow_up_in.type,
        status="SCHEDULED",
        notes=follow_up_in.notes
    )
    db.add(follow_up)
    db.commit()
    db.refresh(follow_up)

    return ApiResponse(data=FollowUpOut.model_validate(follow_up), message="Follow-up scheduled")

@router.get("/patient/{patient_id}", response_model=ApiResponse[List[FollowUpOut]])
def list_patient_follow_ups(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    follow_ups = db.query(FollowUp).filter(
        FollowUp.patient_id == patient_id
    ).order_by(FollowUp.due_date.asc()).all()

    return ApiResponse(
        data=[FollowUpOut.model_validate(f) for f in follow_ups],
        message="Follow-ups retrieved"
    )

@router.patch("/{follow_up_id}", response_model=ApiResponse[FollowUpOut])
def update_follow_up(
    follow_up_id: str,
    update_in: FollowUpUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    follow_up = db.query(FollowUp).filter(FollowUp.id == follow_up_id).first()
    if not follow_up:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Follow-up not found")

    for field, val in update_in.model_dump(exclude_unset=True).items():
        if val is not None:
            setattr(follow_up, field, val)

    db.commit()
    db.refresh(follow_up)
    return ApiResponse(data=FollowUpOut.model_validate(follow_up), message="Follow-up updated")
