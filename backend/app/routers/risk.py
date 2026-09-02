from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import (
    Screening, Patient, ClinicalAssessment, LifestyleAssessment,
    GaitFeatures, RiskResult, ContributingFactor, User
)
from app.schemas.schemas import (
    RiskResultOut, ContributingFactorOut, ApiResponse
)
from app.ml.risk_engine import risk_engine
from app.ml.risk_model import RiskAssessmentInput
from app.dependencies import get_current_user

router = APIRouter(tags=["Risk Assessment Engine"])

@router.post("/screenings/{screening_id}/calculate-risk", response_model=ApiResponse[RiskResultOut])
def calculate_screening_risk(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    screening = db.query(Screening).filter(Screening.id == screening_id).first()
    if not screening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screening session not found")

    patient = db.query(Patient).filter(Patient.id == screening.patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    # Fetch latest clinical assessment
    clinical = db.query(ClinicalAssessment).filter(
        ClinicalAssessment.patient_id == patient.id
    ).order_by(ClinicalAssessment.created_at.desc()).first()

    # Fetch latest lifestyle assessment
    lifestyle = db.query(LifestyleAssessment).filter(
        LifestyleAssessment.patient_id == patient.id
    ).order_by(LifestyleAssessment.created_at.desc()).first()

    # Fetch gait features for this screening
    gait = db.query(GaitFeatures).filter(GaitFeatures.screening_id == screening_id).first()

    # Assemble inputs for Risk Engine
    risk_input = RiskAssessmentInput(
        # Demographics
        age=patient.age,
        gender=patient.gender,
        bmi=patient.bmi,
        
        # Clinical
        pain_score=clinical.pain_score if clinical else 0,
        morning_stiffness=clinical.morning_stiffness if clinical else False,
        walking_difficulty=clinical.walking_difficulty if clinical else False,
        previous_knee_injury=clinical.previous_knee_injury if clinical else False,
        family_history=clinical.family_history if clinical else False,
        swelling=clinical.swelling if clinical else False,
        joint_locking=clinical.joint_locking if clinical else False,
        fever_or_acute_injury=clinical.fever_or_acute_injury if clinical else False,
        
        # Lifestyle
        squatting_level=lifestyle.squatting_level if lifestyle else "SOMETIMES",
        load_carrying_level=lifestyle.load_carrying_level if lifestyle else "LOW",
        manual_work=lifestyle.manual_work if lifestyle else False,
        hill_walking_level=lifestyle.hill_walking_level if lifestyle else "LOW",
        daily_walking_minutes=lifestyle.daily_walking_minutes if lifestyle else 30,
        
        # Biomechanics (if wearable test conducted)
        cadence=gait.cadence if gait else None,
        step_time=gait.step_time if gait else None,
        stance_time=gait.stance_time if gait else None,
        swing_time=gait.swing_time if gait else None,
        gait_asymmetry=gait.gait_asymmetry if gait else None,
        step_variability=gait.step_variability if gait else None,
        thigh_angular_range=gait.thigh_angular_range if gait else None,
        shin_angular_range=gait.shin_angular_range if gait else None,
        estimated_knee_motion=gait.estimated_knee_motion if gait else None,
        sit_to_stand_duration=gait.sit_to_stand_duration if gait else None,
        quality_score=gait.quality_score if gait else 0.0
    )

    result = risk_engine.evaluate_risk(risk_input)

    # Clean up existing risk result if recalculating
    existing_risk = db.query(RiskResult).filter(RiskResult.screening_id == screening_id).first()
    if existing_risk:
        db.delete(existing_risk)
        db.flush()

    risk_result_record = RiskResult(
        screening_id=screening_id,
        patient_id=patient.id,
        risk_score=result.risk_score,
        risk_category=result.risk_category,
        confidence=result.confidence,
        data_completeness=result.data_completeness,
        recommendation=result.recommendation,
        clinician_review_required=result.clinician_review_required,
        is_diagnostic=result.is_diagnostic,
        disclaimer=result.disclaimer,
        model_version=result.model_version
    )
    db.add(risk_result_record)
    db.flush()

    for factor in result.contributing_factors:
        cf = ContributingFactor(
            risk_result_id=risk_result_record.id,
            name=factor.name,
            label=factor.label,
            contribution=factor.contribution,
            explanation=factor.explanation
        )
        db.add(cf)

    db.commit()
    db.refresh(risk_result_record)

    return ApiResponse(
        data=RiskResultOut.model_validate(risk_result_record),
        message="Risk assessment calculated successfully"
    )

@router.get("/screenings/{screening_id}/risk-result", response_model=ApiResponse[RiskResultOut])
def get_screening_risk_result(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    risk_result = db.query(RiskResult).filter(RiskResult.screening_id == screening_id).first()
    if not risk_result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Risk result not calculated yet")

    return ApiResponse(data=RiskResultOut.model_validate(risk_result), message="Risk result retrieved")

@router.get("/patients/{patient_id}/risk-trend", response_model=ApiResponse[List[RiskResultOut]])
def get_patient_risk_trend(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    risk_results = db.query(RiskResult).filter(
        RiskResult.patient_id == patient_id
    ).order_by(RiskResult.created_at.asc()).all()

    return ApiResponse(
        data=[RiskResultOut.model_validate(r) for r in risk_results],
        message="Patient risk history timeline retrieved"
    )
