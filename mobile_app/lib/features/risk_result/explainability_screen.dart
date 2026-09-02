import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/disclaimer_banner.dart';
import '../../shared/providers/screening_provider.dart';

class ExplainabilityScreen extends ConsumerWidget {
  const ExplainabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screeningState = ref.watch(screeningProvider);
    final riskResult = screeningState.riskResult;
    final factors = riskResult?.contributingFactors ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explainability & Factors'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisclaimerBanner(),
              const SizedBox(height: 12),

              const Text(
                'Factors Contributing to this Screening Estimate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Weighted contribution derived from IMU sensors, clinical symptoms, and occupational history. These factors do not imply clinical causality.',
                style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              if (factors.isEmpty)
                const CustomCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No factor breakdown available for incomplete test data.'),
                    ),
                  ),
                )
              else
                ...factors.map((f) => CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  f.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              Text(
                                '${(f.contribution * 100).round()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: f.contribution,
                              minHeight: 8,
                              backgroundColor: AppColors.divider,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            f.explanation,
                            style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
