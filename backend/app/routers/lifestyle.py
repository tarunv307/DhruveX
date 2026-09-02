from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import LifestyleAssessment, Patient, User
from app.schemas.schemas import (
    LifestyleAssessmentCreate, LifestyleAssessmentOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(tags=["Lifestyle Assessments"])

@router.post("/patients/{patient_id}/lifestyle-assessments", response_model=ApiResponse[LifestyleAssessmentOut], status_code=status.HTTP_201_CREATED)
def create_lifestyle_assessment(
    patient_id: str,
    assessment_in: LifestyleAssessmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    assessment = LifestyleAssessment(
        patient_id=patient_id,
        squatting_level=assessment_in.squatting_level.upper(),
        load_carrying_level=assessment_in.load_carrying_level.upper(),
        manual_work=assessment_in.manual_work,
        hill_walking_level=assessment_in.hill_walking_level.upper(),
        physical_activity_level=assessment_in.physical_activity_level.upper(),
        daily_walking_minutes=assessment_in.daily_walking_minutes,
        footwear_type=assessment_in.footwear_type
    )
    db.add(assessment)
    db.commit()
    db.refresh(assessment)

    return ApiResponse(
        data=LifestyleAssessmentOut.model_validate(assessment),
        message="Lifestyle assessment saved"
    )

@router.get("/patients/{patient_id}/lifestyle-assessments", response_model=ApiResponse[List[LifestyleAssessmentOut]])
def get_patient_lifestyle_assessments(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    assessments = db.query(LifestyleAssessment).filter(
        LifestyleAssessment.patient_id == patient_id
    ).order_by(LifestyleAssessment.created_at.desc()).all()

    return ApiResponse(
        data=[LifestyleAssessmentOut.model_validate(a) for a in assessments],
        message="Lifestyle assessments retrieved"
    )
