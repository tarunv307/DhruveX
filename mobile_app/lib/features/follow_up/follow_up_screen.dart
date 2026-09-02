import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/providers/screening_provider.dart';

class FollowUpScreen extends ConsumerStatefulWidget {
  const FollowUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends ConsumerState<FollowUpScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String _followUpType = 'PERIODIC_SCREENING';
  final _notesController = TextEditingController(text: 'Check joint pain response and follow up on prescribed exercise');

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _scheduleFollowUp() async {
    await ref.read(screeningProvider.notifier).createFollowUp(
      dueDate: _selectedDate,
      type: _followUpType,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow-up screening scheduled successfully!'),
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
        title: const Text('Schedule Follow-Up'),
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
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Patient: ${patient?.patientCode ?? "P-DEMO"} (${patient?.village ?? "Village"})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Follow-up Review Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormatter.formatDate(_selectedDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const Icon(Icons.edit_calendar, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Follow-up Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _followUpType,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                items: const [
                  DropdownMenuItem(value: 'PERIODIC_SCREENING', child: Text('Periodic Screening Review (30 Days)')),
                  DropdownMenuItem(value: 'PHYSIOTHERAPY_CHECK', child: Text('Physiotherapy Exercise Check (14 Days)')),
                  DropdownMenuItem(value: 'POST_MEDICATION_REVIEW', child: Text('Post-Consultation Review')),
                ],
                onChanged: (v) => setState(() => _followUpType = v ?? _followUpType),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes / Reminder Instructions'),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Confirm & Schedule Reminder',
                onPressed: _scheduleFollowUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
