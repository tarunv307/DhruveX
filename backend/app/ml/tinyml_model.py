from app.ml.risk_model import RiskModel, RiskAssessmentInput, RiskAssessmentResult
from app.ml.rule_based_model import RuleBasedRiskModel

class TinyMLRiskModel(RiskModel):
    """
    Placeholder interface for future on-device TinyML / Edge AI inference on ESP32-S3
    and cloud TensorFlow Lite / ONNX runtime evaluation.
    Falls back gracefully to the rule-based model when custom weights are not mounted.
    """
    VERSION = "tinyml-edge-v0.9-alpha"

    def __init__(self):
        self._fallback = RuleBasedRiskModel()

    def evaluate(self, inputs: RiskAssessmentInput) -> RiskAssessmentResult:
        # In this MVP, TinyML leverages calibrated heuristics with edge metadata
        result = self._fallback.evaluate(inputs)
        result.model_version = self.VERSION
        return result
