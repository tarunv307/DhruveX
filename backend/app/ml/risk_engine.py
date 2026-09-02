from typing import Optional
from app.config import settings
from app.ml.risk_model import RiskModel, RiskAssessmentInput, RiskAssessmentResult
from app.ml.rule_based_model import RuleBasedRiskModel
from app.ml.tinyml_model import TinyMLRiskModel

class RiskEngine:
    def __init__(self, provider: Optional[str] = None):
        self.provider = provider or settings.MODEL_PROVIDER
        if self.provider == "tinyml":
            self.model: RiskModel = TinyMLRiskModel()
        else:
            self.model: RiskModel = RuleBasedRiskModel()

    def evaluate_risk(self, inputs: RiskAssessmentInput) -> RiskAssessmentResult:
        return self.model.evaluate(inputs)

risk_engine = RiskEngine()
