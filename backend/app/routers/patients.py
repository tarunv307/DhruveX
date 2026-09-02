from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Patient, Consent, User
from app.schemas.schemas import (
    PatientCreate, PatientUpdate, PatientOut, ApiResponse
)
from app.utils.helpers import generate_patient_code, calculate_bmi
from app.dependencies import get_current_user

router = APIRouter(prefix="/patients", tags=["Patients"])

@router.post("", response_model=ApiResponse[PatientOut], status_code=status.HTTP_201_CREATED)
def register_patient(
    patient_in: PatientCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Auto-generate patient code if not provided
    patient_code = patient_in.patient_code or generate_patient_code("P")

    existing = db.query(Patient).filter(Patient.patient_code == patient_code).first()
    if existing:
        patient_code = generate_patient_code("P")

    bmi = calculate_bmi(patient_in.weight_kg, patient_in.height_cm)

    new_patient = Patient(
        patient_code=patient_code,
        initials=patient_in.initials,
        age=patient_in.age,
        gender=patient_in.gender.upper(),
        height_cm=patient_in.height_cm,
        weight_kg=patient_in.weight_kg,
        bmi=bmi,
        phone_optional=patient_in.phone_optional,
        village=patient_in.village,
        district=patient_in.district,
        state=patient_in.state,
        emergency_contact=patient_in.emergency_contact
    )
    db.add(new_patient)
    db.flush()

    # Record consent
    consent_data = patient_in.consent
    consent = Consent(
        patient_id=new_patient.id,
        consent_version=consent_data.consent_version if consent_data else "v1.0",
        has_consented=consent_data.has_consented if consent_data else True
    )
    db.add(consent)
    db.commit()
    db.refresh(new_patient)

    return ApiResponse(
        data=PatientOut.model_validate(new_patient),
        message="Patient registered successfully"
    )

@router.get("", response_model=ApiResponse[List[PatientOut]])
def list_patients(
    search: Optional[str] = None,
    village: Optional[str] = None,
    district: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Patient).filter(Patient.is_active == True)
    if search:
        query = query.filter(
            (Patient.patient_code.ilike(f"%{search}%")) |
            (Patient.village.ilike(f"%{search}%")) |
            (Patient.district.ilike(f"%{search}%"))
        )
    if village:
        query = query.filter(Patient.village == village)
    if district:
        query = query.filter(Patient.district == district)

    patients = query.order_by(Patient.created_at.desc()).offset(skip).limit(limit).all()
    return ApiResponse(
        data=[PatientOut.model_validate(p) for p in patients],
        message="Patients list retrieved"
    )

@router.get("/{patient_id}", response_model=ApiResponse[PatientOut])
def get_patient(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == patient_id, Patient.is_active == True).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")
    return ApiResponse(data=PatientOut.model_validate(patient), message="Patient retrieved")

@router.patch("/{patient_id}", response_model=ApiResponse[PatientOut])
def update_patient(
    patient_id: str,
    patient_update: PatientUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == patient_id, Patient.is_active == True).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    update_data = patient_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(patient, field, value)

    # Recalculate BMI if height or weight modified
    if "height_cm" in update_data or "weight_kg" in update_data:
        patient.bmi = calculate_bmi(patient.weight_kg, patient.height_cm)

    db.commit()
    db.refresh(patient)
    return ApiResponse(data=PatientOut.model_validate(patient), message="Patient updated")

@router.delete("/{patient_id}", response_model=ApiResponse[bool])
def delete_patient(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    patient.is_active = False
    db.commit()
    return ApiResponse(data=True, message="Patient archived successfully")
