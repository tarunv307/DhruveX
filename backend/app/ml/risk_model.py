from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional
from pydantic import BaseModel

class RiskAssessmentInput(BaseModel):
    # Biomechanics / Gait
    cadence: Optional[float] = None
    step_time: Optional[float] = None
    stance_time: Optional[float] = None
    swing_time: Optional[float] = None
    gait_asymmetry: Optional[float] = None
    step_variability: Optional[float] = None
    thigh_angular_range: Optional[float] = None
    shin_angular_range: Optional[float] = None
    estimated_knee_motion: Optional[float] = None
    sit_to_stand_duration: Optional[float] = None
    quality_score: float = 1.0

    # Clinical
    pain_score: int = 0
    morning_stiffness: bool = False
    walking_difficulty: bool = False
    previous_knee_injury: bool = False
    family_history: bool = False
    swelling: bool = False
    joint_locking: bool = False
    fever_or_acute_injury: bool = False

    # Lifestyle & Demographics
    age: int = 45
    gender: str = "FEMALE"
    bmi: float = 24.0
    squatting_level: str = "SOMETIMES" # NEVER, SOMETIMES, OFTEN
    load_carrying_level: str = "LOW" # LOW, MEDIUM, HIGH
    manual_work: bool = False
    hill_walking_level: str = "LOW" # LOW, MEDIUM, HIGH
    daily_walking_minutes: int = 30

class ContributingFactorOutput(BaseModel):
    name: str
    label: str
    contribution: float
    explanation: str

class RiskAssessmentResult(BaseModel):
    risk_score: Optional[int]
    risk_category: str # LOW, MODERATE, HIGH, INCOMPLETE
    confidence: float
    data_completeness: float
    contributing_factors: List[ContributingFactorOutput]
    recommendation: str
    clinician_review_required: bool
    is_diagnostic: bool = False
    disclaimer: str = (
        "This is an AI-assisted screening result, not a final diagnosis. "
        "Consult a qualified clinician for evaluation."
    )
    model_version: str

class RiskModel(ABC):
    @abstractmethod
    def evaluate(self, inputs: RiskAssessmentInput) -> RiskAssessmentResult:
        pass
