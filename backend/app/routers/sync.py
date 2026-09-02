from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import (
    SyncEvent, Patient, ClinicalAssessment, LifestyleAssessment,
    Screening, GaitFeatures, RiskResult, ContributingFactor,
    Referral, FollowUp, Consent, User
)
from app.schemas.schemas import (
    SyncBatchPayload, SyncBatchResponse, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/sync", tags=["Offline Synchronization"])

@router.post("/batch", response_model=ApiResponse[SyncBatchResponse])
def process_sync_batch(
    payload: SyncBatchPayload,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 1. Check Idempotency Key
    existing_event = db.query(SyncEvent).filter(
        SyncEvent.idempotency_key == payload.idempotency_key
    ).first()

    if existing_event:
        return ApiResponse(
            data=SyncBatchResponse(
                idempotency_key=payload.idempotency_key,
                total_received=existing_event.records_received,
                total_synced=existing_event.records_synced,
                conflicts=existing_event.conflicts_detected,
                errors=[]
            ),
            message="Batch already processed (Idempotent response)"
        )

    synced_count = 0
    conflicts_count = 0
    errors: List[Dict[str, str]] = []

    for item in payload.items:
        try:
            etype = item.entity_type.upper()
            data = item.data

            if etype == "PATIENT":
                pid = item.entity_id
                patient = db.query(Patient).filter(Patient.id == pid).first()
                if not patient:
                    patient = Patient(
                        id=pid,
                        patient_code=data.get("patient_code", "P-UNKNOWN"),
                        initials=data.get("initials"),
                        age=data.get("age", 40),
                        gender=data.get("gender", "FEMALE"),
                        height_cm=data.get("height_cm", 160.0),
                        weight_kg=data.get("weight_kg", 60.0),
                        bmi=data.get("bmi", 23.4),
                        phone_optional=data.get("phone_optional"),
                        village=data.get("village", "Default Village"),
                        district=data.get("district", "Default District"),
                        state=data.get("state", "State"),
                        emergency_contact=data.get("emergency_contact")
                    )
                    db.add(patient)
                    db.flush()
                synced_count += 1

            elif etype == "CLINICAL_ASSESSMENT":
                cid = item.entity_id
                assessment = db.query(ClinicalAssessment).filter(ClinicalAssessment.id == cid).first()
                if not assessment:
                    assessment = ClinicalAssessment(
                        id=cid,
                        patient_id=data.get("patient_id"),
                        pain_score=data.get("pain_score", 0),
                        morning_stiffness=data.get("morning_stiffness", False),
                        walking_difficulty=data.get("walking_difficulty", False),
                        previous_knee_injury=data.get("previous_knee_injury", False),
                        family_history=data.get("family_history", False),
                        swelling=data.get("swelling", False),
                        joint_locking=data.get("joint_locking", False),
                        fever_or_acute_injury=data.get("fever_or_acute_injury", False),
                        has_red_flags=data.get("has_red_flags", False)
                    )
                    db.add(assessment)
                    db.flush()
                synced_count += 1

            elif etype == "LIFESTYLE_ASSESSMENT":
                lid = item.entity_id
                lifestyle = db.query(LifestyleAssessment).filter(LifestyleAssessment.id == lid).first()
                if not lifestyle:
                    lifestyle = LifestyleAssessment(
                        id=lid,
                        patient_id=data.get("patient_id"),
                        squatting_level=data.get("squatting_level", "SOMETIMES"),
                        load_carrying_level=data.get("load_carrying_level", "LOW"),
                        manual_work=data.get("manual_work", False),
                        hill_walking_level=data.get("hill_walking_level", "LOW"),
                        physical_activity_level=data.get("physical_activity_level", "MEDIUM"),
                        daily_walking_minutes=data.get("daily_walking_minutes", 30),
                        footwear_type=data.get("footwear_type")
                    )
                    db.add(lifestyle)
                    db.flush()
                synced_count += 1

            elif etype == "SCREENING":
                sid = item.entity_id
                screening = db.query(Screening).filter(Screening.id == sid).first()
                if not screening:
                    screening = Screening(
                        id=sid,
                        patient_id=data.get("patient_id"),
                        conducted_by=current_user.id,
                        status=data.get("status", "COMPLETED"),
                        is_demo=data.get("is_demo", False)
                    )
                    db.add(screening)
                    db.flush()
                synced_count += 1

            elif etype == "GAIT_FEATURES":
                gid = item.entity_id
                gait = db.query(GaitFeatures).filter(GaitFeatures.id == gid).first()
                if not gait:
                    gait = GaitFeatures(
                        id=gid,
                        screening_id=data.get("screening_id"),
                        cadence=data.get("cadence", 100.0),
                        step_time=data.get("step_time", 0.6),
                        stance_time=data.get("stance_time", 0.6),
                        swing_time=data.get("swing_time", 0.4),
                        gait_asymmetry=data.get("gait_asymmetry", 0.0),
                        step_variability=data.get("step_variability", 0.05),
                        thigh_angular_range=data.get("thigh_angular_range", 35.0),
                        shin_angular_range=data.get("shin_angular_range", 45.0),
                        estimated_knee_motion=data.get("estimated_knee_motion", 50.0),
                        sit_to_stand_duration=data.get("sit_to_stand_duration"),
                        quality_score=data.get("quality_score", 1.0)
                    )
                    db.add(gait)
                    db.flush()
                synced_count += 1

            elif etype == "RISK_RESULT":
                rid = item.entity_id
                risk = db.query(RiskResult).filter(RiskResult.id == rid).first()
                if not risk:
                    risk = RiskResult(
                        id=rid,
                        screening_id=data.get("screening_id"),
                        patient_id=data.get("patient_id"),
                        risk_score=data.get("risk_score"),
                        risk_category=data.get("risk_category", "LOW"),
                        confidence=data.get("confidence", 0.8),
                        data_completeness=data.get("data_completeness", 1.0),
                        recommendation=data.get("recommendation", "Standard screening guidance"),
                        clinician_review_required=data.get("clinician_review_required", False),
                        is_diagnostic=False,
                        disclaimer=data.get("disclaimer", "Screening result, not a diagnosis."),
                        model_version=data.get("model_version", "prototype-rule-v1")
                    )
                    db.add(risk)
                    db.flush()

                    for cf_data in data.get("contributing_factors", []):
                        cf = ContributingFactor(
                            risk_result_id=risk.id,
                            name=cf_data.get("name", "unknown"),
                            label=cf_data.get("label", "Factor"),
                            contribution=cf_data.get("contribution", 0.0),
                            explanation=cf_data.get("explanation", "")
                        )
                        db.add(cf)
                synced_count += 1

            elif etype == "REFERRAL":
                ref_id = item.entity_id
                referral = db.query(Referral).filter(Referral.id == ref_id).first()
                if not referral:
                    referral = Referral(
                        id=ref_id,
                        patient_id=data.get("patient_id"),
                        screening_id=data.get("screening_id"),
                        clinic_id=data.get("clinic_id"),
                        reason=data.get("reason", "Osteoarthritis risk review"),
                        priority=data.get("priority", "ROUTINE"),
                        status=data.get("status", "PENDING"),
                        notes=data.get("notes")
                    )
                    db.add(referral)
                    db.flush()
                synced_count += 1

            elif etype == "FOLLOW_UP":
                f_id = item.entity_id
                fu = db.query(FollowUp).filter(FollowUp.id == f_id).first()
                if not fu:
                    fu = FollowUp(
                        id=f_id,
                        patient_id=data.get("patient_id"),
                        screening_id=data.get("screening_id"),
                        due_date=data.get("due_date"),
                        type=data.get("type", "PERIODIC_SCREENING"),
                        status=data.get("status", "SCHEDULED"),
                        notes=data.get("notes")
                    )
                    db.add(fu)
                    db.flush()
                synced_count += 1

        except Exception as e:
            conflicts_count += 1
            errors.append({"entity_id": item.entity_id, "error": str(e)})

    # Log Sync Event
    sync_event = SyncEvent(
        idempotency_key=payload.idempotency_key,
        client_device_id=payload.client_device_id,
        records_received=len(payload.items),
        records_synced=synced_count,
        conflicts_detected=conflicts_count,
        status="COMPLETED" if conflicts_count == 0 else "PARTIAL"
    )
    db.add(sync_event)
    db.commit()

    return ApiResponse(
        data=SyncBatchResponse(
            idempotency_key=payload.idempotency_key,
            total_received=len(payload.items),
            total_synced=synced_count,
            conflicts=conflicts_count,
            errors=errors
        ),
        message=f"Sync batch processed: {synced_count} records synced, {conflicts_count} conflicts."
    )
