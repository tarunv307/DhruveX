import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/providers/patient_provider.dart';
import '../../shared/providers/screening_provider.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends ConsumerState<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _initialsController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController(text: 'Wadgaon');
  final _districtController = TextEditingController(text: 'Pune');
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _emergencyController = TextEditingController();

  String _selectedGender = 'FEMALE';
  double _calculatedBmi = 0.0;

  @override
  void dispose() {
    _initialsController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _recalculateBmi() {
    final h = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final w = double.tryParse(_weightController.text.trim()) ?? 0.0;
    if (h > 0 && w > 0) {
      setState(() {
        _calculatedBmi = BmiCalculator.calculate(w, h);
      });
    }
  }

  Future<void> _submitPatient() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final weight = double.parse(_weightController.text.trim());

    final patient = await ref.read(patientProvider.notifier).registerPatient(
      initials: _initialsController.text.trim().isNotEmpty ? _initialsController.text.trim() : null,
      age: age,
      gender: _selectedGender,
      heightCm: height,
      weightKg: weight,
      phoneOptional: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      village: _villageController.text.trim(),
      district: _districtController.text.trim(),
      stateName: _stateController.text.trim(),
      emergencyContact: _emergencyController.text.trim().isNotEmpty ? _emergencyController.text.trim() : null,
    );

    // Initialize screening session for this patient
    ref.read(screeningProvider.notifier).initScreeningForPatient(patient);

    if (mounted) {
      context.push('/clinical-questionnaire');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Patient Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Step 1 of 4: Patient Profile',
                  style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Basic Demographics & Body Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Minimal data collection: Name is optional. An anonymous code will be generated automatically.',
                          style: TextStyle(fontSize: 11, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _initialsController,
                        decoration: const InputDecoration(
                          labelText: 'Initials (Optional)',
                          hintText: 'e.g. S.K.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age (Years) *',
                          hintText: 'e.g. 55',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 18 || n > 110) return 'Valid 18-110';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Text('Gender *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _GenderChip(
                      label: 'Female',
                      selected: _selectedGender == 'FEMALE',
                      onTap: () => setState(() => _selectedGender = 'FEMALE'),
                    ),
                    const SizedBox(width: 10),
                    _GenderChip(
                      label: 'Male',
                      selected: _selectedGender == 'MALE',
                      onTap: () => setState(() => _selectedGender = 'MALE'),
                    ),
                    const SizedBox(width: 10),
                    _GenderChip(
                      label: 'Other',
                      selected: _selectedGender == 'OTHER',
                      onTap: () => setState(() => _selectedGender = 'OTHER'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Height (cm) *',
                          hintText: '160',
                        ),
                        onChanged: (_) => _recalculateBmi(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg) *',
                          hintText: '65',
                        ),
                        onChanged: (_) => _recalculateBmi(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // BMI Display Box
                if (_calculatedBmi > 0)
                  CustomCard(
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calculated BMI: $_calculatedBmi kg/m²',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(BmiCalculator.getCategory(_calculatedBmi),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _calculatedBmi >= 25 ? AppColors.warningYellow : AppColors.successGreen,
                            )),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _villageController,
                        decoration: const InputDecoration(labelText: 'Village / Town *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(labelText: 'District *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State *'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Continue to Clinical Questionnaire',
                  onPressed: _submitPatient,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({required this.label, required this.selected, required this.onTap});

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
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
