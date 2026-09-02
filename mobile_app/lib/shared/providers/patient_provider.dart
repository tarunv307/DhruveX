import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/storage/local_db.dart';
import '../../core/utils/bmi_calculator.dart';
import '../models/patient.dart';
import 'sync_provider.dart';

class PatientState {
  final List<PatientModel> patients;
  final PatientModel? selectedPatient;
  final bool isLoading;
  final String? error;

  PatientState({
    this.patients = const [],
    this.selectedPatient,
    this.isLoading = false,
    this.error,
  });

  PatientState copyWith({
    List<PatientModel>? patients,
    PatientModel? selectedPatient,
    bool? isLoading,
    String? error,
  }) {
    return PatientState(
      patients: patients ?? this.patients,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PatientNotifier extends StateNotifier<PatientState> {
  final LocalDatabase _localDb = LocalDatabase.instance;
  final Ref _ref;
  final _uuid = const Uuid();

  PatientNotifier(this._ref) : super(PatientState()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = await _localDb.database;
      final rows = await db.query('patients', orderBy: 'created_at DESC');
      final list = rows.map((r) => PatientModel.fromJson(r)).toList();

      // Seed a default demo patient if empty
      if (list.isEmpty) {
        final demoPatient = PatientModel(
          id: 'DEMO-OANER-001',
          patientCode: 'P-9842',
          initials: 'S.D.',
          age: 56,
          gender: 'FEMALE',
          heightCm: 156.0,
          weightKg: 71.5,
          bmi: 29.4,
          village: 'Khed Shivapur',
          district: 'Pune',
          state: 'Maharashtra',
          syncStatus: 'SYNCED',
        );
        await db.insert('patients', demoPatient.toJson());
        list.add(demoPatient);
      }

      state = state.copyWith(patients: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectPatient(PatientModel patient) {
    state = state.copyWith(selectedPatient: patient);
  }

  Future<PatientModel> registerPatient({
    String? initials,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    String? phoneOptional,
    required String village,
    required String district,
    required String stateName,
    String? emergencyContact,
  }) async {
    final bmi = BmiCalculator.calculate(weightKg, heightCm);
    final randomCode = 'P-${1000 + Random().nextInt(8999)}';
    final patientId = _uuid.v4();

    final newPatient = PatientModel(
      id: patientId,
      patientCode: randomCode,
      initials: initials,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: bmi,
      phoneOptional: phoneOptional,
      village: village,
      district: district,
      state: stateName,
      emergencyContact: emergencyContact,
      syncStatus: 'PENDING',
    );

    final db = await _localDb.database;
    await db.insert('patients', newPatient.toJson());

    // Enqueue for offline sync
    await _ref.read(syncProvider.notifier).enqueueItem(
      entityType: 'PATIENT',
      entityId: newPatient.id,
      operation: 'CREATE',
      payload: newPatient.toJson(),
    );

    await loadPatients();
    selectPatient(newPatient);
    return newPatient;
  }
}

final patientProvider = StateNotifierProvider<PatientNotifier, PatientState>((ref) {
  return PatientNotifier(ref);
});
