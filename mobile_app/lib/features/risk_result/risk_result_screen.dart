import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/risk_badge.dart';
import '../../shared/widgets/disclaimer_banner.dart';
import '../../shared/providers/screening_provider.dart';

class RiskResultScreen extends ConsumerWidget {
  const RiskResultScreen({Key? key}) : super(key: key);

  Future<void> _exportPdfReport(BuildContext context, dynamic patient, dynamic riskResult, dynamic gait) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('OSTEOGUARD-NER | Clinical Screening Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.Text('Team DhruveX (SIH26004) - AI Decision Support', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 10),

              // Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(color: PdfColors.yellow100, border: pw.Border.all(color: PdfColors.orange)),
                child: pw.Text(AppStrings.mandatoryDisclaimer, style: const pw.TextStyle(fontSize: 9, color: PdfColors.red900)),
              ),
              pw.SizedBox(height: 14),

              // Patient Info
              pw.Text('Patient Information', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Patient Code: ${patient?.patientCode ?? "N/A"}'),
              pw.Text('Age / Gender: ${patient?.age ?? "-"} yrs / ${patient?.gender ?? "-"}'),
              pw.Text('BMI: ${patient?.bmi ?? "-"} kg/m² • Village: ${patient?.village ?? "-"}'),
              pw.SizedBox(height: 14),

              // Screening Result
              pw.Text('Screening Risk Estimate', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Risk Category: ${riskResult?.riskCategory ?? "-"}'),
              pw.Text('Risk Score: ${riskResult?.riskScore ?? "Incomplete"} / 100'),
              pw.Text('Confidence: ${(riskResult?.confidence ?? 0.8) * 100}%'),
              pw.SizedBox(height: 14),

              // Recommendation
              pw.Text('Clinical Recommendation:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text(riskResult?.recommendation ?? "Consult a clinician for review."),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'OsteoGuard_${patient?.patientCode ?? "Screening"}.pdf',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screeningState = ref.watch(screeningProvider);
    final patient = screeningState.patient;
    final riskResult = screeningState.riskResult;
    final gait = screeningState.gaitFeatures;

    final score = riskResult?.riskScore;
    final category = riskResult?.riskCategory ?? 'LOW';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Risk Result'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mandatory Disclaimer Banner
              const DisclaimerBanner(),
              const SizedBox(height: 10),

              // Patient Header Card
              CustomCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        patient?.initials ?? 'PT',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient?.patientCode ?? "P-DEMO"} • ${patient?.age ?? 56} yrs (${patient?.gender ?? "F"})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'BMI: ${patient?.bmi ?? 29.4} • ${DateFormatter.formatDateTime(DateTime.now())}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    RiskBadge(category: category, score: score),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Score Card with Circular Gauge
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'AI SCREENING RISK ESTIMATE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 14),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: score != null ? (score / 100.0) : 0.0,
                            strokeWidth: 10,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              category == 'HIGH'
                                  ? AppColors.criticalRed
                                  : (category == 'MODERATE' ? AppColors.warningYellow : AppColors.successGreen),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              score != null ? '$score' : 'N/A',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Out of 100',
                              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category == 'HIGH'
                          ? AppStrings.highRisk
                          : (category == 'MODERATE' ? AppStrings.moderateRisk : AppStrings.lowRisk),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: category == 'HIGH'
                            ? AppColors.criticalRed
                            : (category == 'MODERATE' ? const Color(0xFFB7791F) : AppColors.successGreen),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      riskResult?.recommendation ?? 'Consult a healthcare professional for guidance.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Biomechanics Summary
              if (gait != null)
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Extracted Sensor Biomechanics',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetricPill(label: 'Gait Asymmetry', value: '${(gait.gaitAsymmetry * 100).round()}%'),
                          _MetricPill(label: 'Knee ROM', value: '${gait.estimatedKneeMotion.round()}°'),
                          _MetricPill(label: 'Cadence', value: '${gait.cadence.round()} spm'),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Action Buttons
              CustomButton(
                text: 'View Explainability Breakdown',
                icon: Icons.bar_chart_rounded,
                type: ButtonType.secondary,
                onPressed: () => context.push('/explainability'),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'PHC Referral',
                      icon: Icons.send_rounded,
                      onPressed: () => context.push('/referral-create'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Follow-up',
                      icon: Icons.event_available,
                      type: ButtonType.outline,
                      onPressed: () => context.push('/follow-up-create'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF Screening Summary'),
                onPressed: () => _exportPdfReport(context, patient, riskResult, gait),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
