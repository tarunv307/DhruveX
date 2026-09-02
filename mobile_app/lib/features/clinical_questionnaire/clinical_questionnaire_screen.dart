import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/disclaimer_banner.dart';
import '../../shared/models/clinical_assessment.dart';
import '../../shared/providers/screening_provider.dart';

class ClinicalQuestionnaireScreen extends ConsumerStatefulWidget {
  const ClinicalQuestionnaireScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClinicalQuestionnaireScreen> createState() => _ClinicalQuestionnaireScreenState();
}

class _ClinicalQuestionnaireScreenState extends ConsumerState<ClinicalQuestionnaireScreen> {
  double _painScore = 4.0;
  bool _morningStiffness = true;
  bool _walkingDifficulty = true;
  bool _previousKneeInjury = false;
  bool _familyHistory = false;
  bool _swelling = false;
  bool _jointLocking = false;
  bool _feverOrAcuteInjury = false;

  bool get _hasRedFlags =>
      _painScore >= 8 || _feverOrAcuteInjury || _jointLocking || _swelling;

  void _onContinue() {
    final screeningState = ref.read(screeningProvider);
    final patientId = screeningState.patient?.id ?? 'DEMO-PATIENT-ID';

    final assessment = ClinicalAssessmentModel(
      id: const Uuid().v4(),
      patientId: patientId,
      painScore: _painScore.round(),
      morningStiffness: _morningStiffness,
      walkingDifficulty: _walkingDifficulty,
      previousKneeInjury: _previousKneeInjury,
      familyHistory: _familyHistory,
      swelling: _swelling,
      jointLocking: _jointLocking,
      feverOrAcuteInjury: _feverOrAcuteInjury,
    );

    ref.read(screeningProvider.notifier).saveClinicalAssessment(assessment);
    context.push('/lifestyle-assessment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Questionnaire'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 2 of 4: Clinical History',
                style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Knee Pain & Symptom Evaluation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // Red Flag Alert Banner (dynamically triggered)
              if (_hasRedFlags)
                const DisclaimerBanner(
                  isRedFlag: true,
                  customText:
                      'Red-flag symptom selected (high pain, swelling, or acute injury). Clinical review by a qualified doctor is recommended regardless of sensor test score.',
                ),

              // 1. Pain Score Slider
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Knee Pain Level (0 - 10 VAS)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _painScore >= 8
                                ? AppColors.criticalRedBg
                                : (_painScore >= 4 ? AppColors.warningYellowBg : AppColors.successGreenBg),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_painScore.round()} / 10',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _painScore >= 8
                                  ? AppColors.criticalRed
                                  : (_painScore >= 4 ? const Color(0xFFB7791F) : AppColors.successGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _painScore,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: _painScore >= 8 ? AppColors.criticalRed : AppColors.primary,
                      onChanged: (v) => setState(() => _painScore = v),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0 - No Pain', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('5 - Moderate', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('10 - Severe Pain', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Symptom Checklist
              const Text('Joint Symptoms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              _YesNoTile(
                title: 'Morning Stiffness (> 30 minutes)',
                subtitle: 'Difficulty bending or stretching knee upon waking up',
                value: _morningStiffness,
                onChanged: (v) => setState(() => _morningStiffness = v),
              ),

              _YesNoTile(
                title: 'Difficulty Walking or Climbing Stairs',
                subtitle: 'Functional movement limitation in daily activities',
                value: _walkingDifficulty,
                onChanged: (v) => setState(() => _walkingDifficulty = v),
              ),

              _YesNoTile(
                title: 'Previous Knee Injury / Surgery',
                subtitle: 'Prior trauma, meniscus tear, or ligament injury',
                value: _previousKneeInjury,
                onChanged: (v) => setState(() => _previousKneeInjury = v),
              ),

              _YesNoTile(
                title: 'Family History of Joint Pain / OA',
                subtitle: 'Parents or siblings affected by osteoarthritis',
                value: _familyHistory,
                onChanged: (v) => setState(() => _familyHistory = v),
              ),

              const SizedBox(height: 14),
              const Text('Acute / Red-Flag Symptoms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.criticalRed)),
              const SizedBox(height: 8),

              _YesNoTile(
                title: 'Knee Swelling or Warmth',
                subtitle: 'Visible puffiness or heat around the joint',
                value: _swelling,
                isRedFlag: true,
                onChanged: (v) => setState(() => _swelling = v),
              ),

              _YesNoTile(
                title: 'Joint Catching or "Locking"',
                subtitle: 'Knee suddenly catches or refuses to bend',
                value: _jointLocking,
                isRedFlag: true,
                onChanged: (v) => setState(() => _jointLocking = v),
              ),

              _YesNoTile(
                title: 'Fever or Recent Acute Injury',
                subtitle: 'High body temperature or sudden fall / sprain',
                value: _feverOrAcuteInjury,
                isRedFlag: true,
                onChanged: (v) => setState(() => _feverOrAcuteInjury = v),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Save & Continue to Lifestyle Assessment',
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YesNoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isRedFlag;

  const _YesNoTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isRedFlag = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isRedFlag && value ? AppColors.criticalRed : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: isRedFlag ? AppColors.criticalRed : AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
