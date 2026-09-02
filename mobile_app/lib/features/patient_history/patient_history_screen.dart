import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/risk_badge.dart';
import '../../shared/providers/patient_provider.dart';

class PatientHistoryScreen extends ConsumerWidget {
  const PatientHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientProvider);
    final patients = patientState.patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Screening History'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registered Patients & Sessions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Historical records stored offline in SQLite with sync tracking.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              if (patients.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No patient records found.'),
                  ),
                )
              else
                ...patients.map((p) => CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                p.patientCode,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                              ),
                              RiskBadge(category: p.bmi >= 28 ? 'MODERATE' : 'LOW', score: p.bmi >= 28 ? 52 : 22),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Demographics: ${p.age} yrs • ${p.gender} • BMI: ${p.bmi} kg/m²'),
                          const SizedBox(height: 2),
                          Text('Location: ${p.village}, ${p.district} (${p.state})',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Registered: ${DateFormatter.formatDate(p.createdAt)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.syncStatus == 'SYNCED' ? AppColors.successGreenBg : AppColors.warningYellowBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.syncStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: p.syncStatus == 'SYNCED' ? AppColors.successGreen : const Color(0xFFB7791F),
                                  ),
                                ),
                              ),
                            ],
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
