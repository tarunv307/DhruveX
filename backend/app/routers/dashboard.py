from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models.entities import (
    Patient, Screening, RiskResult, Referral, FollowUp, Device, ClinicalAssessment, User
)
from app.schemas.schemas import (
    DashboardSummaryOut, RiskDistributionItem, RecentAlertItem, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/dashboard", tags=["Clinic Dashboard Analytics"])

@router.get("/summary", response_model=ApiResponse[DashboardSummaryOut])
def get_dashboard_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    total_patients = db.query(func.count(Patient.id)).filter(Patient.is_active == True).scalar() or 0
    total_screenings = db.query(func.count(Screening.id)).scalar() or 0
    
    low_risk = db.query(func.count(RiskResult.id)).filter(RiskResult.risk_category == "LOW").scalar() or 0
    mod_risk = db.query(func.count(RiskResult.id)).filter(RiskResult.risk_category == "MODERATE").scalar() or 0
    high_risk = db.query(func.count(RiskResult.id)).filter(RiskResult.risk_category == "HIGH").scalar() or 0
    incomplete = db.query(func.count(RiskResult.id)).filter(RiskResult.risk_category == "INCOMPLETE").scalar() or 0
    
    pending_ref = db.query(func.count(Referral.id)).filter(Referral.status == "PENDING").scalar() or 0
    completed_fu = db.query(func.count(FollowUp.id)).filter(FollowUp.status == "COMPLETED").scalar() or 0
    active_dev = db.query(func.count(Device.id)).scalar() or 0

    return ApiResponse(
        data=DashboardSummaryOut(
            total_patients=total_patients,
            total_screenings=total_screenings,
            low_risk_count=low_risk,
            moderate_risk_count=mod_risk,
            high_risk_count=high_risk,
            incomplete_count=incomplete,
            pending_referrals=pending_ref,
            completed_followups=completed_fu,
            active_devices=active_dev
        ),
        message="Clinic analytics summary calculated"
    )

@router.get("/risk-distribution", response_model=ApiResponse[List[RiskDistributionItem]])
def get_risk_distribution(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    total = db.query(func.count(RiskResult.id)).scalar() or 0
    categories = ["LOW", "MODERATE", "HIGH", "INCOMPLETE"]
    
    distribution: List[RiskDistributionItem] = []
    for cat in categories:
        count = db.query(func.count(RiskResult.id)).filter(RiskResult.risk_category == cat).scalar() or 0
        pct = round((count / total * 100.0), 1) if total > 0 else 0.0
        distribution.append(RiskDistributionItem(
            risk_category=cat,
            count=count,
            percentage=pct
        ))

    return ApiResponse(data=distribution, message="Risk distribution calculated")

@router.get("/recent-alerts", response_model=ApiResponse[List[RecentAlertItem]])
def get_recent_alerts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Fetch High Risk results or cases with red flags
    high_risks = db.query(RiskResult).filter(
        RiskResult.risk_category == "HIGH"
    ).order_by(RiskResult.created_at.desc()).limit(20).all()

    alerts: List[RecentAlertItem] = []
    for hr in high_risks:
        patient = db.query(Patient).filter(Patient.id == hr.patient_id).first()
        if patient:
            clinical = db.query(ClinicalAssessment).filter(
                ClinicalAssessment.patient_id == patient.id
            ).order_by(ClinicalAssessment.created_at.desc()).first()
            
            alerts.append(RecentAlertItem(
                patient_id=patient.id,
                patient_code=patient.patient_code,
                village=patient.village,
                risk_category=hr.risk_category,
                risk_score=hr.risk_score,
                has_red_flags=clinical.has_red_flags if clinical else False,
                created_at=hr.created_at
            ))

    return ApiResponse(data=alerts, message="Recent clinical alerts retrieved")
