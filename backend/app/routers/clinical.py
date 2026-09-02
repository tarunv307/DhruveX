from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import ClinicalAssessment, Patient, User
from app.schemas.schemas import (
    ClinicalAssessmentCreate, ClinicalAssessmentOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(tags=["Clinical Assessments"])

@router.post("/patients/{patient_id}/clinical-assessments", response_model=ApiResponse[ClinicalAssessmentOut], status_code=status.HTTP_201_CREATED)
def create_clinical_assessment(
    patient_id: str,
    assessment_in: ClinicalAssessmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    has_red_flags = (
        assessment_in.pain_score >= 8 or
        assessment_in.fever_or_acute_injury or
        assessment_in.joint_locking or
        assessment_in.swelling
    )

    assessment = ClinicalAssessment(
        patient_id=patient_id,
        pain_score=assessment_in.pain_score,
        morning_stiffness=assessment_in.morning_stiffness,
        walking_difficulty=assessment_in.walking_difficulty,
        previous_knee_injury=assessment_in.previous_knee_injury,
        family_history=assessment_in.family_history,
        swelling=assessment_in.swelling,
        joint_locking=assessment_in.joint_locking,
        fever_or_acute_injury=assessment_in.fever_or_acute_injury,
        has_red_flags=has_red_flags
    )
    db.add(assessment)
    db.commit()
    db.refresh(assessment)

    msg = "Clinical assessment saved."
    if has_red_flags:
        msg = "Clinical assessment saved. Red-flag symptoms detected: Prompt clinical review recommended."

    return ApiResponse(
        data=ClinicalAssessmentOut.model_validate(assessment),
        message=msg
    )

@router.get("/patients/{patient_id}/clinical-assessments", response_model=ApiResponse[List[ClinicalAssessmentOut]])
def get_patient_clinical_assessments(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    assessments = db.query(ClinicalAssessment).filter(
        ClinicalAssessment.patient_id == patient_id
    ).order_by(ClinicalAssessment.created_at.desc()).all()

    return ApiResponse(
        data=[ClinicalAssessmentOut.model_validate(a) for a in assessments],
        message="Clinical assessments retrieved"
    )
