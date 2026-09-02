from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Screening, GaitFeatures, User
from app.schemas.schemas import (
    GaitFeaturesCreate, GaitFeaturesOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(tags=["Gait Features"])

@router.post("/screenings/{screening_id}/gait-features", response_model=ApiResponse[GaitFeaturesOut], status_code=status.HTTP_201_CREATED)
def submit_gait_features(
    screening_id: str,
    gait_in: GaitFeaturesCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    screening = db.query(Screening).filter(Screening.id == screening_id).first()
    if not screening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Screening session not found")

    existing = db.query(GaitFeatures).filter(GaitFeatures.screening_id == screening_id).first()
    if existing:
        # Update existing
        for field, value in gait_in.model_dump().items():
            setattr(existing, field, value)
        db.commit()
        db.refresh(existing)
        return ApiResponse(data=GaitFeaturesOut.model_validate(existing), message="Gait features updated")

    gait = GaitFeatures(
        screening_id=screening_id,
        cadence=gait_in.cadence,
        step_time=gait_in.step_time,
        stance_time=gait_in.stance_time,
        swing_time=gait_in.swing_time,
        gait_asymmetry=gait_in.gait_asymmetry,
        step_variability=gait_in.step_variability,
        thigh_angular_range=gait_in.thigh_angular_range,
        shin_angular_range=gait_in.shin_angular_range,
        estimated_knee_motion=gait_in.estimated_knee_motion,
        sit_to_stand_duration=gait_in.sit_to_stand_duration,
        quality_score=gait_in.quality_score
    )
    db.add(gait)
    db.commit()
    db.refresh(gait)

    return ApiResponse(
        data=GaitFeaturesOut.model_validate(gait),
        message="Gait features recorded successfully"
    )

@router.get("/screenings/{screening_id}/gait-features", response_model=ApiResponse[GaitFeaturesOut])
def get_gait_features(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    gait = db.query(GaitFeatures).filter(GaitFeatures.screening_id == screening_id).first()
    if not gait:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gait features not found for screening")

    return ApiResponse(data=GaitFeaturesOut.model_validate(gait), message="Gait features retrieved")
