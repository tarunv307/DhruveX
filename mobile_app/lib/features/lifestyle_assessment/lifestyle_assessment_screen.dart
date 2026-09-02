import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/models/lifestyle_assessment.dart';
import '../../shared/providers/screening_provider.dart';

class LifestyleAssessmentScreen extends ConsumerStatefulWidget {
  const LifestyleAssessmentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LifestyleAssessmentScreen> createState() => _LifestyleAssessmentScreenState();
}

class _LifestyleAssessmentScreenState extends ConsumerState<LifestyleAssessmentScreen> {
  String _squattingLevel = 'OFTEN'; // NEVER, SOMETIMES, OFTEN
  String _loadCarryingLevel = 'MEDIUM'; // LOW, MEDIUM, HIGH
  bool _manualWork = true;
  String _hillWalkingLevel = 'LOW'; // LOW, MEDIUM, HIGH
  String _physicalActivity = 'MEDIUM'; // LOW, MEDIUM, HIGH
  int _dailyWalkingMinutes = 45;

  void _onContinue() {
    final screeningState = ref.read(screeningProvider);
    final patientId = screeningState.patient?.id ?? 'DEMO-PATIENT-ID';

    final assessment = LifestyleAssessmentModel(
      id: const Uuid().v4(),
      patientId: patientId,
      squattingLevel: _squattingLevel,
      loadCarryingLevel: _loadCarryingLevel,
      manualWork: _manualWork,
      hillWalkingLevel: _hillWalkingLevel,
      physicalActivityLevel: _physicalActivity,
      dailyWalkingMinutes: _dailyWalkingMinutes,
    );

    ref.read(screeningProvider.notifier).saveLifestyleAssessment(assessment);
    context.push('/device-connection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifestyle & Activity'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 3 of 4: Occupational & Lifestyle Factors',
                style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daily Joint Loading Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // 1. Frequent Squatting / Floor Sitting
              const Text('Frequent Deep Squatting / Sitting on Floor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _OptionChip(
                    label: 'Rarely / Never',
                    selected: _squattingLevel == 'NEVER',
                    onTap: () => setState(() => _squattingLevel = 'NEVER'),
                  ),
                  const SizedBox(width: 8),
                  _OptionChip(
                    label: 'Sometimes',
                    selected: _squattingLevel == 'SOMETIMES',
                    onTap: () => setState(() => _squattingLevel = 'SOMETIMES'),
                  ),
                  const SizedBox(width: 8),
                  _OptionChip(
                    label: 'Often / Daily',
                    selected: _squattingLevel == 'OFTEN',
                    onTap: () => setState(() => _squattingLevel = 'OFTEN'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Load Carrying
              const Text('Heavy Load Carrying (Pots, Crops, Construction)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _OptionChip(
                    label: 'Light (< 5kg)',
                    selected: _loadCarryingLevel == 'LOW',
                    onTap: () => setState(() => _loadCarryingLevel = 'LOW'),
                  ),
                  const SizedBox(width: 8),
                  _OptionChip(
                    label: 'Medium (5-15kg)',
                    selected: _loadCarryingLevel == 'MEDIUM',
                    onTap: () => setState(() => _loadCarryingLevel = 'MEDIUM'),
                  ),
                  const SizedBox(width: 8),
                  _OptionChip(
                    label: 'Heavy (> 15kg)',
                    selected: _loadCarryingLevel == 'HIGH',
                    onTap: () => setState(() => _loadCarryingLevel = 'HIGH'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3. Agricultural or Manual Labor
              CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agricultural / Manual Field Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Involves prolonged bending, kneeling or farming labor', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _manualWork,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _manualWork = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Daily Walking Minutes
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Average Daily Walking Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('$_dailyWalkingMinutes mins/day', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: _dailyWalkingMinutes.toDouble(),
                      min: 5,
                      max: 180,
                      divisions: 35,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _dailyWalkingMinutes = v.round()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Save & Pair Wearable Sensors',
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
