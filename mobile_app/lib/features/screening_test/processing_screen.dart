import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/providers/screening_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  Future<void> _startPipeline() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final result = await ref.read(screeningProvider.notifier).processScreeningResults();
    if (mounted) {
      context.go('/risk-result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screeningState = ref.watch(screeningProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analyzing Biomechanics & Symptoms',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  screeningState.processingStep ?? 'Processing sensor data...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 36),

                // Pipeline Steps
                _PipelineStep(
                  label: 'Dual-IMU Signal Validation & Quality Check',
                  isDone: true,
                ),
                _PipelineStep(
                  label: 'Gait Asymmetry & Knee Range of Motion',
                  isDone: true,
                ),
                _PipelineStep(
                  label: 'Rule-Based / TinyML Model Evaluation',
                  isDone: screeningState.riskResult != null,
                ),
                _PipelineStep(
                  label: 'Explainable Factor Breakdown Generation',
                  isDone: screeningState.riskResult != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String label;
  final bool isDone;

  const _PipelineStep({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: isDone ? AppColors.successGreen : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
