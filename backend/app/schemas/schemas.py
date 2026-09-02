from pydantic import BaseModel, Field, ConfigDict, field_validator
from typing import Optional, List, Generic, TypeVar, Any, Dict
from datetime import datetime
import uuid

T = TypeVar("T")

# ================= Standard API Response Wrappers =================

class ApiErrorDetail(BaseModel):
    field: Optional[str] = None
    issue: str

class ApiError(BaseModel):
    code: str
    message: str
    details: Optional[List[ApiErrorDetail]] = None

class ApiResponse(BaseModel, Generic[T]):
    success: bool = True
    data: Optional[T] = None
    message: str = "Operation completed successfully"
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()))

class ErrorResponse(BaseModel):
    success: bool = False
    error: ApiError
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()))

# ================= User & Auth Schemas =================

class UserCreate(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=6)
    display_name: str = Field(..., min_length=2, max_length=150)
    role: str = "HEALTH_WORKER"
    health_worker_id: Optional[str] = None
    clinic_id: Optional[str] = None
    email: Optional[str] = None

class UserLogin(BaseModel):
    phone_or_id: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: "UserOut"

class TokenPayload(BaseModel):
    sub: str
    role: str
    exp: int

class UserOut(BaseModel):
    id: str
    phone: str
    display_name: str
    role: str
    health_worker_id: Optional[str] = None
    clinic_id: Optional[str] = None
    email: Optional[str] = None
    is_active: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Patient Schemas =================

class ConsentCreate(BaseModel):
    consent_version: str = "v1.0"
    has_consented: bool = True

class ConsentOut(BaseModel):
    id: str
    consent_version: str
    has_consented: bool
    consented_at: datetime

    model_config = ConfigDict(from_attributes=True)

class PatientCreate(BaseModel):
    patient_code: Optional[str] = None # If None, will auto-generate
    initials: Optional[str] = None
    age: int = Field(..., ge=18, le=120)
    gender: str # MALE, FEMALE, OTHER
    height_cm: float = Field(..., ge=80.0, le=250.0)
    weight_kg: float = Field(..., ge=20.0, le=250.0)
    phone_optional: Optional[str] = None
    village: str
    district: str
    state: str
    emergency_contact: Optional[str] = None
    consent: Optional[ConsentCreate] = None

class PatientUpdate(BaseModel):
    initials: Optional[str] = None
    age: Optional[int] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    phone_optional: Optional[str] = None
    village: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    emergency_contact: Optional[str] = None

class PatientOut(BaseModel):
    id: str
    patient_code: str
    initials: Optional[str] = None
    age: int
    gender: str
    height_cm: float
    weight_kg: float
    bmi: float
    phone_optional: Optional[str] = None
    village: str
    district: str
    state: str
    emergency_contact: Optional[str] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Clinical & Lifestyle Schemas =================

class ClinicalAssessmentCreate(BaseModel):
    pain_score: int = Field(..., ge=0, le=10)
    morning_stiffness: bool = False
    walking_difficulty: bool = False
    previous_knee_injury: bool = False
    family_history: bool = False
    swelling: bool = False
    joint_locking: bool = False
    fever_or_acute_injury: bool = False

class ClinicalAssessmentOut(BaseModel):
    id: str
    patient_id: str
    pain_score: int
    morning_stiffness: bool
    walking_difficulty: bool
    previous_knee_injury: bool
    family_history: bool
    swelling: bool
    joint_locking: bool
    fever_or_acute_injury: bool
    has_red_flags: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class LifestyleAssessmentCreate(BaseModel):
    squatting_level: str = "SOMETIMES" # NEVER, SOMETIMES, OFTEN
    load_carrying_level: str = "LOW" # LOW, MEDIUM, HIGH
    manual_work: bool = False
    hill_walking_level: str = "LOW" # LOW, MEDIUM, HIGH
    physical_activity_level: str = "MEDIUM" # LOW, MEDIUM, HIGH
    daily_walking_minutes: int = 30
    footwear_type: Optional[str] = None

class LifestyleAssessmentOut(BaseModel):
    id: str
    patient_id: str
    squatting_level: str
    load_carrying_level: str
    manual_work: bool
    hill_walking_level: str
    physical_activity_level: str
    daily_walking_minutes: int
    footwear_type: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Biomechanics & Gait Schemas =================

class GaitFeaturesCreate(BaseModel):
    cadence: float = Field(..., ge=10.0, le=200.0)
    step_time: float = Field(..., ge=0.1, le=5.0)
    stance_time: float = Field(..., ge=0.1, le=5.0)
    swing_time: float = Field(..., ge=0.1, le=5.0)
    gait_asymmetry: float = Field(..., ge=0.0, le=1.0)
    step_variability: float = Field(..., ge=0.0, le=2.0)
    thigh_angular_range: float = Field(..., ge=5.0, le=120.0)
    shin_angular_range: float = Field(..., ge=5.0, le=120.0)
    estimated_knee_motion: float = Field(..., ge=5.0, le=160.0)
    sit_to_stand_duration: Optional[float] = None
    quality_score: float = Field(default=1.0, ge=0.0, le=1.0)

class GaitFeaturesOut(BaseModel):
    id: str
    screening_id: str
    cadence: float
    step_time: float
    stance_time: float
    swing_time: float
    gait_asymmetry: float
    step_variability: float
    thigh_angular_range: float
    shin_angular_range: float
    estimated_knee_motion: float
    sit_to_stand_duration: Optional[float] = None
    quality_score: float
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Screening & Risk Schemas =================

class ScreeningCreate(BaseModel):
    patient_id: str
    is_demo: bool = False

class SensorSessionCreate(BaseModel):
    device_id: Optional[str] = None
    test_type: str = "NORMAL_WALKING" # NORMAL_WALKING, SIT_TO_STAND, STEP_TEST
    duration_seconds: int = 30
    signal_quality: int = 100
    battery_level: int = 100
    raw_packet_count: int = 0
    status: str = "COMPLETED"

class SensorSessionOut(BaseModel):
    id: str
    screening_id: str
    device_id: Optional[str] = None
    test_type: str
    duration_seconds: int
    signal_quality: int
    battery_level: int
    status: str
    started_at: datetime
    completed_at: datetime

    model_config = ConfigDict(from_attributes=True)

class ContributingFactorOut(BaseModel):
    name: str
    label: str
    contribution: float
    explanation: str

    model_config = ConfigDict(from_attributes=True)

class RiskResultOut(BaseModel):
    id: str
    screening_id: str
    patient_id: str
    risk_score: Optional[int] = None
    risk_category: str # LOW, MODERATE, HIGH, INCOMPLETE
    confidence: float
    data_completeness: float
    recommendation: str
    clinician_review_required: bool
    is_diagnostic: bool = False
    disclaimer: str
    model_version: str
    contributing_factors: List[ContributingFactorOut] = []
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class ScreeningOut(BaseModel):
    id: str
    patient_id: str
    conducted_by: Optional[str] = None
    status: str
    started_at: datetime
    completed_at: Optional[datetime] = None
    is_demo: bool
    gait_features: Optional[GaitFeaturesOut] = None
    risk_result: Optional[RiskResultOut] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Referrals & Follow-ups =================

class ReferralCreate(BaseModel):
    patient_id: str
    screening_id: Optional[str] = None
    clinic_id: Optional[str] = None
    reason: str
    priority: str = "ROUTINE" # ROUTINE, URGENT, EMERGENCY
    preferred_date: Optional[datetime] = None
    notes: Optional[str] = None

class ReferralUpdate(BaseModel):
    status: Optional[str] = None # DRAFT, PENDING, ACCEPTED, COMPLETED, CANCELLED
    priority: Optional[str] = None
    notes: Optional[str] = None
    clinic_id: Optional[str] = None

class ReferralOut(BaseModel):
    id: str
    patient_id: str
    screening_id: Optional[str] = None
    clinic_id: Optional[str] = None
    reason: str
    priority: str
    status: str
    notes: Optional[str] = None
    preferred_date: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class FollowUpCreate(BaseModel):
    patient_id: str
    screening_id: Optional[str] = None
    due_date: datetime
    type: str = "PERIODIC_SCREENING"
    notes: Optional[str] = None

class FollowUpUpdate(BaseModel):
    status: Optional[str] = None # SCHEDULED, COMPLETED, MISSED, CANCELLED
    reminder_sent: Optional[bool] = None
    notes: Optional[str] = None

class FollowUpOut(BaseModel):
    id: str
    patient_id: str
    screening_id: Optional[str] = None
    due_date: datetime
    type: str
    status: str
    reminder_sent: bool
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Devices =================

class DeviceRegister(BaseModel):
    device_mac: str
    device_name: str
    firmware_version: str

class DeviceHeartbeat(BaseModel):
    battery_level: int
    firmware_version: Optional[str] = None

class DeviceOut(BaseModel):
    id: str
    device_mac: str
    device_name: str
    firmware_version: str
    battery_level: int
    last_heartbeat: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ================= Offline Sync Batch Schemas =================

class SyncItemPayload(BaseModel):
    entity_type: str # PATIENT, CLINICAL_ASSESSMENT, LIFESTYLE_ASSESSMENT, SCREENING, GAIT_FEATURES, RISK_RESULT, REFERRAL, FOLLOW_UP
    entity_id: str
    operation: str = "CREATE" # CREATE, UPDATE, DELETE
    data: Dict[str, Any]

class SyncBatchPayload(BaseModel):
    idempotency_key: str
    client_device_id: Optional[str] = None
    items: List[SyncItemPayload]

class SyncBatchResponse(BaseModel):
    idempotency_key: str
    total_received: int
    total_synced: int
    conflicts: int
    errors: List[Dict[str, str]] = []

# ================= Dashboard Analytics =================

class DashboardSummaryOut(BaseModel):
    total_patients: int
    total_screenings: int
    low_risk_count: int
    moderate_risk_count: int
    high_risk_count: int
    incomplete_count: int
    pending_referrals: int
    completed_followups: int
    active_devices: int

class RiskDistributionItem(BaseModel):
    risk_category: str
    count: int
    percentage: float

class RecentAlertItem(BaseModel):
    patient_id: str
    patient_code: str
    village: str
    risk_category: str
    risk_score: Optional[int] = None
    has_red_flags: bool
    created_at: datetime
