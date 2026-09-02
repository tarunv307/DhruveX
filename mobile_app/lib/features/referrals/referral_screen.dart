import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/providers/screening_provider.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _reasonController = TextEditingController(text: 'High knee pain and elevated gait asymmetry during screening test');
  final _notesController = TextEditingController();
  String _selectedPriority = 'URGENT'; // ROUTINE, URGENT, EMERGENCY
  String _selectedClinic = 'PHC Wadgaon Central';

  final List<String> _clinics = [
    'PHC Wadgaon Central',
    'District Civil Hospital Orthopedics',
    'Rural Community Health Center Khed',
    'Physiotherapy Rehabilitation Unit',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    await ref.read(screeningProvider.notifier).createReferral(
      reason: _reasonController.text.trim(),
      priority: _selectedPriority,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      preferredDate: DateTime.now().add(const Duration(days: 3)),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral submitted and queued for PHC doctor review!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screeningState = ref.watch(screeningProvider);
    final patient = screeningState.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PHC Referral'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                color: AppColors.primaryLight,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Patient: ${patient?.patientCode ?? "P-DEMO"} (${patient?.age ?? 56} yrs, ${patient?.village ?? "Village"})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Target Health Facility *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedClinic,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                items: _clinics.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _selectedClinic = v ?? _selectedClinic),
              ),
              const SizedBox(height: 16),

              const Text('Referral Priority *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _PriorityChip(
                    label: 'Routine',
                    color: AppColors.successGreen,
                    selected: _selectedPriority == 'ROUTINE',
                    onTap: () => setState(() => _selectedPriority = 'ROUTINE'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Urgent',
                    color: AppColors.warningYellow,
                    selected: _selectedPriority == 'URGENT',
                    onTap: () => setState(() => _selectedPriority = 'URGENT'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Emergency',
                    color: AppColors.criticalRed,
                    selected: _selectedPriority == 'EMERGENCY',
                    onTap: () => setState(() => _selectedPriority = 'EMERGENCY'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Primary Reason for Referral *'),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Clinical Notes / Observations (Optional)'),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Submit Referral to PHC Portal',
                onPressed: _submitReferral,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? color : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
