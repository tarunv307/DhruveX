import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({Key? key}) : super(key: key);

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _dataConsentChecked = false;
  bool _bleConsentChecked = false;
  bool _medicalScopeChecked = false;

  bool get _canProceed => _dataConsentChecked && _bleConsentChecked && _medicalScopeChecked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informed Consent & Privacy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to OSTEOGUARD-NER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please review and accept the screening terms and safety protocols before proceeding.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // 1. Medical Scope Notice
              CustomCard(
                color: AppColors.warningYellowBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFFB7791F), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Non-Diagnostic Screening Scope',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.mandatoryDisclaimer,
                      style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Required Agreements',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text(
                  'I understand this app provides an AI screening risk estimate, NOT a confirmed medical diagnosis.',
                  style: TextStyle(fontSize: 13),
                ),
                value: _medicalScopeChecked,
                onChanged: (val) => setState(() => _medicalScopeChecked = val ?? false),
              ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text(
                  'I consent to temporary Bluetooth connection with the wearable sensor to capture knee movement metrics.',
                  style: TextStyle(fontSize: 13),
                ),
                value: _bleConsentChecked,
                onChanged: (val) => setState(() => _bleConsentChecked = val ?? false),
              ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text(
                  'I consent to offline storage of demographic and questionnaire data for referral & follow-up purposes.',
                  style: TextStyle(fontSize: 13),
                ),
                value: _dataConsentChecked,
                onChanged: (val) => setState(() => _dataConsentChecked = val ?? false),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Accept & Continue',
                onPressed: _canProceed ? () => context.go('/login') : null,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Consent Version: v1.0 (Hash: SHA256-NER2026)',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
