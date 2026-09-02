import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, Enum as SQLEnum, JSON, Index
)
from sqlalchemy.orm import relationship
from app.database import Base

def utc_now():
    return datetime.now(timezone.utc)

def generate_uuid():
    return str(uuid.uuid4())

class UserRole:
    PATIENT = "PATIENT"
    HEALTH_WORKER = "HEALTH_WORKER"
    DOCTOR = "DOCTOR"
    CLINIC_ADMIN = "CLINIC_ADMIN"

class Clinic(Base):
    __tablename__ = "clinics"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    name = Column(String(255), nullable=False)
    code = Column(String(50), unique=True, index=True, nullable=False)
    district = Column(String(100), index=True, nullable=False)
    state = Column(String(100), nullable=False)
    latitude = Column(Float, nullable=True) # PostGIS ready
    longitude = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    users = relationship("User", back_populates="clinic")
    referrals = relationship("Referral", back_populates="clinic")

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    display_name = Column(String(150), nullable=False)
    role = Column(String(50), default=UserRole.HEALTH_WORKER, index=True, nullable=False)
    health_worker_id = Column(String(50), unique=True, index=True, nullable=True)
    hashed_password = Column(String(255), nullable=False)
    clinic_id = Column(String(36), ForeignKey("clinics.id"), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    clinic = relationship("Clinic", back_populates="users")
    screenings = relationship("Screening", back_populates="conducted_by_user")

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_code = Column(String(50), unique=True, index=True, nullable=False)
    initials = Column(String(10), nullable=True)
    age = Column(Integer, nullable=False)
    gender = Column(String(20), nullable=False) # MALE, FEMALE, OTHER
    height_cm = Column(Float, nullable=False)
    weight_kg = Column(Float, nullable=False)
    bmi = Column(Float, nullable=False)
    phone_optional = Column(String(20), nullable=True)
    village = Column(String(100), index=True, nullable=False)
    district = Column(String(100), index=True, nullable=False)
    state = Column(String(100), nullable=False)
    emergency_contact = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    consents = relationship("Consent", back_populates="patient", cascade="all, delete-orphan")
    clinical_assessments = relationship("ClinicalAssessment", back_populates="patient", cascade="all, delete-orphan")
    lifestyle_assessments = relationship("LifestyleAssessment", back_populates="patient", cascade="all, delete-orphan")
    screenings = relationship("Screening", back_populates="patient", cascade="all, delete-orphan")
    referrals = relationship("Referral", back_populates="patient", cascade="all, delete-orphan")
    follow_ups = relationship("FollowUp", back_populates="patient", cascade="all, delete-orphan")

class Consent(Base):
    __tablename__ = "consents"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    consent_version = Column(String(20), nullable=False)
    has_consented = Column(Boolean, default=True, nullable=False)
    consented_at = Column(DateTime(timezone=True), default=utc_now)

    patient = relationship("Patient", back_populates="consents")

class ClinicalAssessment(Base):
    __tablename__ = "clinical_assessments"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    pain_score = Column(Integer, nullable=False) # 0 to 10
    morning_stiffness = Column(Boolean, default=False, nullable=False)
    walking_difficulty = Column(Boolean, default=False, nullable=False)
    previous_knee_injury = Column(Boolean, default=False, nullable=False)
    family_history = Column(Boolean, default=False, nullable=False)
    swelling = Column(Boolean, default=False, nullable=False)
    joint_locking = Column(Boolean, default=False, nullable=False)
    fever_or_acute_injury = Column(Boolean, default=False, nullable=False) # Red flag
    has_red_flags = Column(Boolean, default=False, index=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    patient = relationship("Patient", back_populates="clinical_assessments")

class LifestyleAssessment(Base):
    __tablename__ = "lifestyle_assessments"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    squatting_level = Column(String(20), default="SOMETIMES", nullable=False) # NEVER, SOMETIMES, OFTEN
    load_carrying_level = Column(String(20), default="LOW", nullable=False) # LOW, MEDIUM, HIGH
    manual_work = Column(Boolean, default=False, nullable=False)
    hill_walking_level = Column(String(20), default="LOW", nullable=False) # LOW, MEDIUM, HIGH
    physical_activity_level = Column(String(20), default="MEDIUM", nullable=False) # LOW, MEDIUM, HIGH
    daily_walking_minutes = Column(Integer, default=30, nullable=False)
    footwear_type = Column(String(50), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    patient = relationship("Patient", back_populates="lifestyle_assessments")

class Device(Base):
    __tablename__ = "devices"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    device_mac = Column(String(50), unique=True, index=True, nullable=False)
    device_name = Column(String(100), nullable=False)
    firmware_version = Column(String(50), nullable=False)
    battery_level = Column(Integer, default=100)
    last_heartbeat = Column(DateTime(timezone=True), default=utc_now)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    sensor_sessions = relationship("SensorSession", back_populates="device")

class Screening(Base):
    __tablename__ = "screenings"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    conducted_by = Column(String(36), ForeignKey("users.id"), nullable=True)
    status = Column(String(30), default="IN_PROGRESS", index=True) # IN_PROGRESS, COMPLETED, INCOMPLETE, FAILED
    started_at = Column(DateTime(timezone=True), default=utc_now)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    is_demo = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=utc_now)

    patient = relationship("Patient", back_populates="screenings")
    conducted_by_user = relationship("User", back_populates="screenings")
    sensor_sessions = relationship("SensorSession", back_populates="screening", cascade="all, delete-orphan")
    gait_features = relationship("GaitFeatures", back_populates="screening", uselist=False, cascade="all, delete-orphan")
    risk_result = relationship("RiskResult", back_populates="screening", uselist=False, cascade="all, delete-orphan")

class SensorSession(Base):
    __tablename__ = "sensor_sessions"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    screening_id = Column(String(36), ForeignKey("screenings.id"), nullable=False, index=True)
    device_id = Column(String(36), ForeignKey("devices.id"), nullable=True)
    test_type = Column(String(50), nullable=False) # NORMAL_WALKING, SIT_TO_STAND, STEP_TEST
    duration_seconds = Column(Integer, default=30)
    signal_quality = Column(Integer, default=100) # 0-100
    battery_level = Column(Integer, default=100)
    raw_packet_count = Column(Integer, default=0)
    status = Column(String(30), default="COMPLETED")
    started_at = Column(DateTime(timezone=True), default=utc_now)
    completed_at = Column(DateTime(timezone=True), default=utc_now)

    screening = relationship("Screening", back_populates="sensor_sessions")
    device = relationship("Device", back_populates="sensor_sessions")

class GaitFeatures(Base):
    __tablename__ = "gait_features"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    screening_id = Column(String(36), ForeignKey("screenings.id"), unique=True, nullable=False)
    cadence = Column(Float, nullable=False) # steps/min
    step_time = Column(Float, nullable=False) # seconds
    stance_time = Column(Float, nullable=False) # seconds
    swing_time = Column(Float, nullable=False) # seconds
    gait_asymmetry = Column(Float, nullable=False) # 0.0 to 1.0
    step_variability = Column(Float, nullable=False) # standard deviation
    thigh_angular_range = Column(Float, nullable=False) # degrees
    shin_angular_range = Column(Float, nullable=False) # degrees
    estimated_knee_motion = Column(Float, nullable=False) # degrees ROM
    sit_to_stand_duration = Column(Float, nullable=True) # seconds
    quality_score = Column(Float, default=1.0) # 0.0 to 1.0 data validity
    created_at = Column(DateTime(timezone=True), default=utc_now)

    screening = relationship("Screening", back_populates="gait_features")

class RiskResult(Base):
    __tablename__ = "risk_results"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    screening_id = Column(String(36), ForeignKey("screenings.id"), unique=True, nullable=False)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    risk_score = Column(Integer, nullable=True) # 0 to 100
    risk_category = Column(String(30), nullable=False, index=True) # LOW, MODERATE, HIGH, INCOMPLETE
    confidence = Column(Float, default=0.0) # 0.0 to 1.0
    data_completeness = Column(Float, default=1.0)
    recommendation = Column(Text, nullable=False)
    clinician_review_required = Column(Boolean, default=False)
    is_diagnostic = Column(Boolean, default=False)
    disclaimer = Column(Text, nullable=False)
    model_version = Column(String(50), nullable=False)
    created_at = Column(DateTime(timezone=True), default=utc_now, index=True)

    screening = relationship("Screening", back_populates="risk_result")
    contributing_factors = relationship("ContributingFactor", back_populates="risk_result", cascade="all, delete-orphan")

class ContributingFactor(Base):
    __tablename__ = "contributing_factors"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    risk_result_id = Column(String(36), ForeignKey("risk_results.id"), nullable=False, index=True)
    name = Column(String(100), nullable=False)
    label = Column(String(150), nullable=False)
    contribution = Column(Float, nullable=False) # 0.0 to 1.0
    explanation = Column(Text, nullable=False)

    risk_result = relationship("RiskResult", back_populates="contributing_factors")

class Referral(Base):
    __tablename__ = "referrals"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    screening_id = Column(String(36), ForeignKey("screenings.id"), nullable=True)
    clinic_id = Column(String(36), ForeignKey("clinics.id"), nullable=True)
    reason = Column(Text, nullable=False)
    priority = Column(String(20), default="ROUTINE", nullable=False) # ROUTINE, URGENT, EMERGENCY
    status = Column(String(30), default="PENDING", index=True, nullable=False) # DRAFT, PENDING, ACCEPTED, COMPLETED, CANCELLED
    notes = Column(Text, nullable=True)
    preferred_date = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    patient = relationship("Patient", back_populates="referrals")
    clinic = relationship("Clinic", back_populates="referrals")

class FollowUp(Base):
    __tablename__ = "follow_ups"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    screening_id = Column(String(36), ForeignKey("screenings.id"), nullable=True)
    due_date = Column(DateTime(timezone=True), nullable=False)
    type = Column(String(50), default="PERIODIC_SCREENING") # PERIODIC_SCREENING, PHYSIOTHERAPY_CHECK
    status = Column(String(30), default="SCHEDULED", index=True) # SCHEDULED, COMPLETED, MISSED, CANCELLED
    reminder_sent = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now)
    updated_at = Column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    patient = relationship("Patient", back_populates="follow_ups")

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), nullable=True, index=True)
    action = Column(String(100), nullable=False)
    entity_type = Column(String(100), nullable=False)
    entity_id = Column(String(36), nullable=True)
    details = Column(JSON, nullable=True)
    ip_address = Column(String(50), nullable=True)
    created_at = Column(DateTime(timezone=True), default=utc_now, index=True)

class SyncEvent(Base):
    __tablename__ = "sync_events"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    idempotency_key = Column(String(100), unique=True, index=True, nullable=False)
    client_device_id = Column(String(100), nullable=True)
    records_received = Column(Integer, default=0)
    records_synced = Column(Integer, default=0)
    conflicts_detected = Column(Integer, default=0)
    status = Column(String(30), default="PROCESSED")
    created_at = Column(DateTime(timezone=True), default=utc_now)
