from app.ml.risk_model import (
    RiskModel, RiskAssessmentInput, RiskAssessmentResult, ContributingFactorOutput
)

class RuleBasedRiskModel(RiskModel):
    VERSION = "prototype-rule-v1.2"

    def evaluate(self, inputs: RiskAssessmentInput) -> RiskAssessmentResult:
        # 1. Check Red Flags
        has_red_flags = (
            inputs.pain_score >= 8 or
            inputs.fever_or_acute_injury or
            inputs.joint_locking or
            inputs.swelling
        )

        # 2. Check Data Completeness & Sensor Availability
        completeness_checks = [
            inputs.cadence is not None,
            inputs.gait_asymmetry is not None,
            inputs.estimated_knee_motion is not None,
            inputs.thigh_angular_range is not None,
            inputs.shin_angular_range is not None,
        ]
        available_count = sum(1 for c in completeness_checks if c)
        completeness_score = round(available_count / len(completeness_checks), 2)
        
        # Multiply by sensor transmission quality
        effective_quality = completeness_score * (inputs.quality_score or 1.0)

        if effective_quality < 0.80 or inputs.gait_asymmetry is None:
            return RiskAssessmentResult(
                risk_score=None,
                risk_category="INCOMPLETE",
                confidence=round(effective_quality, 2),
                data_completeness=round(completeness_score, 2),
                contributing_factors=[],
                recommendation=(
                    "Knee motion sensor data was incomplete or degraded. "
                    "Ensure both thigh and shin IMU straps are securely fastened and repeat the walking test."
                ),
                clinician_review_required=True if has_red_flags else False,
                is_diagnostic=False,
                model_version=self.VERSION
            )

        # 3. Calculate Biomechanical Risk Components (Max 50 points)
        # Asymmetry component (0 to 25 pts)
        asymmetry = max(0.0, min(1.0, inputs.gait_asymmetry))
        asym_pts = asymmetry * 25.0
        
        # Knee Range of Motion component (Normal walking ROM ~ 45-60 deg; lower ROM = higher stiffness/risk) (0 to 15 pts)
        knee_rom = inputs.estimated_knee_motion or 50.0
        if knee_rom < 30.0:
            rom_pts = 15.0
        elif knee_rom < 42.0:
            rom_pts = 10.0
        elif knee_rom < 50.0:
            rom_pts = 5.0
        else:
            rom_pts = 0.0

        # Sit to Stand / Cadence component (0 to 10 pts)
        cadence = inputs.cadence or 100.0
        cadence_pts = 0.0
        if cadence < 80:
            cadence_pts += 5.0
        if inputs.sit_to_stand_duration and inputs.sit_to_stand_duration > 3.0:
            cadence_pts += 5.0

        # 4. Calculate Clinical Components (Max 30 points)
        # Pain score (0-10 -> 0 to 15 pts)
        pain_pts = (inputs.pain_score / 10.0) * 15.0
        
        # Morning stiffness & walking difficulty (0 to 10 pts)
        clinical_pts = 0.0
        if inputs.morning_stiffness:
            clinical_pts += 5.0
        if inputs.walking_difficulty:
            clinical_pts += 5.0
        if inputs.previous_knee_injury:
            clinical_pts += 5.0 # bonus factor (capped below)

        # 5. Calculate Lifestyle & Demographics Components (Max 20 points)
        # BMI component (0 to 10 pts)
        bmi = inputs.bmi
        if bmi >= 30.0: # Obese
            bmi_pts = 10.0
        elif bmi >= 25.0: # Overweight
            bmi_pts = 6.0
        elif bmi >= 23.0: # Asian cut-off for overweight
            bmi_pts = 3.0
        else:
            bmi_pts = 0.0

        # Occupational / Lifestyle load (0 to 10 pts)
        lifestyle_pts = 0.0
        if inputs.squatting_level == "OFTEN":
            lifestyle_pts += 4.0
        elif inputs.squatting_level == "SOMETIMES":
            lifestyle_pts += 2.0
            
        if inputs.load_carrying_level in ["HIGH", "MEDIUM"]:
            lifestyle_pts += 3.0
        if inputs.manual_work:
            lifestyle_pts += 2.0
        if inputs.age >= 50:
            lifestyle_pts += 3.0

        # Sum total raw score (0-100)
        total_pts = asym_pts + rom_pts + cadence_pts + pain_pts + clinical_pts + bmi_pts + lifestyle_pts
        raw_score = int(min(100, max(0, round(total_pts))))

        # Determine Risk Category
        if raw_score <= 30:
            category = "LOW"
            recommendation = (
                "Low screening risk observed. Continue regular low-impact physical activity, "
                "maintain healthy body weight, and schedule routine annual health-worker follow-up."
            )
            clinician_review = False
        elif raw_score <= 60:
            category = "MODERATE"
            recommendation = (
                "Moderate screening risk observed. Discuss joint symptoms and movement patterns with a "
                "primary care clinician or physiotherapist for preventive muscle-strengthening exercises."
            )
            clinician_review = True
        else:
            category = "HIGH"
            recommendation = (
                "High screening risk estimate detected. Clinical evaluation by a qualified doctor or "
                "orthopedic specialist is strongly recommended for comprehensive physical and imaging assessment."
            )
            clinician_review = True

        if has_red_flags:
            clinician_review = True
            recommendation = (
                "Red-flag clinical symptoms reported (severe pain, swelling, or acute injury). "
                "Prompt clinical review is recommended regardless of AI screening score."
            )

        # Build Explainability Contributing Factors
        factors: List[ContributingFactorOutput] = []
        total_non_zero = max(1.0, total_pts)

        # 1. Gait Asymmetry
        if asym_pts > 0:
            factors.append(ContributingFactorOutput(
                name="gait_asymmetry",
                label="Gait Asymmetry & Weight Distribution",
                contribution=round(asym_pts / total_non_zero, 2),
                explanation=f"Measured gait asymmetry of {round(asymmetry * 100, 1)}% indicates uneven load bearing between limbs."
            ))

        # 2. Knee Range of Motion
        if rom_pts > 0:
            factors.append(ContributingFactorOutput(
                name="knee_motion",
                label="Reduced Knee Motion (ROM)",
                contribution=round(rom_pts / total_non_zero, 2),
                explanation=f"Estimated dynamic knee flexion-extension range was {round(knee_rom, 1)}°, below normal walking reference."
            ))

        # 3. Reported Joint Pain
        if pain_pts > 0:
            factors.append(ContributingFactorOutput(
                name="pain_score",
                label="Reported Knee Pain (VAS)",
                contribution=round(pain_pts / total_non_zero, 2),
                explanation=f"Reported pain level of {inputs.pain_score}/10 significantly elevates functional joint risk."
            ))

        # 4. Body Mass Index (BMI)
        if bmi_pts > 0:
            factors.append(ContributingFactorOutput(
                name="bmi",
                label="Body Mass Index (BMI)",
                contribution=round(bmi_pts / total_non_zero, 2),
                explanation=f"Current BMI of {round(bmi, 1)} kg/m² contributes elevated mechanical joint loading."
            ))

        # 5. Occupational & Lifestyle Load
        if (lifestyle_pts + cadence_pts) > 0:
            factors.append(ContributingFactorOutput(
                name="lifestyle_and_cadence",
                label="Occupational Load & Movement Speed",
                contribution=round((lifestyle_pts + cadence_pts) / total_non_zero, 2),
                explanation=f"Frequent squatting, manual labor, or lower cadence ({round(cadence, 1)} spm) contribute to joint wear."
            ))

        # Sort factors by highest contribution
        factors.sort(key=lambda x: x.contribution, reverse=True)

        confidence = round(min(0.95, 0.70 + (effective_quality * 0.25)), 2)

        return RiskAssessmentResult(
            risk_score=raw_score,
            risk_category=category,
            confidence=confidence,
            data_completeness=completeness_score,
            contributing_factors=factors,
            recommendation=recommendation,
            clinician_review_required=clinician_review,
            is_diagnostic=False,
            model_version=self.VERSION
        )
