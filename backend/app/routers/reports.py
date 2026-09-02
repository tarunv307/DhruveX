from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import Response
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Screening, Patient, RiskResult, GaitFeatures, User
from app.utils.pdf_generator import generate_screening_pdf
from app.dependencies import get_current_user

router = APIRouter(prefix="/reports", tags=["Screening Reports"])

@router.get("/screenings/{screening_id}/pdf")
def export_screening_pdf(
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

    risk_result = db.query(RiskResult).filter(RiskResult.screening_id == screening_id).first()
    if not risk_result:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Risk calculation required before generating report")

    gait_features = db.query(GaitFeatures).filter(GaitFeatures.screening_id == screening_id).first()

    pdf_bytes = generate_screening_pdf(screening, patient, risk_result, gait_features)

    filename = f"OsteoGuard_Screening_{patient.patient_code}_{screening_id[:8]}.pdf"

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename={filename}"
        }
    )
