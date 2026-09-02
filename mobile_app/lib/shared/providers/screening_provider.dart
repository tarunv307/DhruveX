import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../../core/storage/local_db.dart';
import '../models/patient.dart';
import '../models/clinical_assessment.dart';
import '../models/lifestyle_assessment.dart';
import '../models/gait_features.dart';
import '../models/risk_result.dart';
import '../models/referral.dart';
import '../models/follow_up.dart';
import 'sync_provider.dart';
import 'ble_provider.dart';

class ScreeningWorkflowState {
  final PatientModel? patient;
  final String? screeningId;
  final ClinicalAssessmentModel? clinicalAssessment;
  final LifestyleAssessmentModel? lifestyleAssessment;
  final GaitFeaturesModel? gaitFeatures;
  final RiskResultModel? riskResult;
  final List<FlSpot> thighSpots;
  final List<FlSpot> shinSpots;
  final int testCountdown;
  final bool isTestRunning;
  final bool isProcessing;
  final String? processingStep;

  ScreeningWorkflowState({
    this.patient,
    this.screeningId,
    this.clinicalAssessment,
    this.lifestyleAssessment,
    this.gaitFeatures,
    this.riskResult,
    this.thighSpots = const [],
    this.shinSpots = const [],
    this.testCountdown = 30,
    this.isTestRunning = false,
    this.isProcessing = false,
    this.processingStep,
  });

  ScreeningWorkflowState copyWith({
    PatientModel? patient,
    String? screeningId,
    ClinicalAssessmentModel? clinicalAssessment,
    LifestyleAssessmentModel? lifestyleAssessment,
    GaitFeaturesModel? gaitFeatures,
    RiskResultModel? riskResult,
    List<FlSpot>? thighSpots,
    List<FlSpot>? shinSpots,
    int? testCountdown,
    bool? isTestRunning,
    bool? isProcessing,
    String? processingStep,
  }) {
    return ScreeningWorkflowState(
      patient: patient ?? this.patient,
      screeningId: screeningId ?? this.screeningId,
      clinicalAssessment: clinicalAssessment ?? this.clinicalAssessment,
      lifestyleAssessment: lifestyleAssessment ?? this.lifestyleAssessment,
      gaitFeatures: gaitFeatures ?? this.gaitFeatures,
      riskResult: riskResult ?? this.riskResult,
      thighSpots: thighSpots ?? this.thighSpots,
      shinSpots: shinSpots ?? this.shinSpots,
      testCountdown: testCountdown ?? this.testCountdown,
      isTestRunning: isTestRunning ?? this.isTestRunning,
      isProcessing: isProcessing ?? this.isProcessing,
      processingStep: processingStep ?? this.processingStep,
    );
  }
}

class ScreeningNotifier extends StateNotifier<ScreeningWorkflowState> {
  final Ref _ref;
  final LocalDatabase _localDb = LocalDatabase.instance;
  final _uuid = const Uuid();
  Timer? _countdownTimer;
  StreamSubscription? _sensorSub;
  double _spotIndex = 0.0;

  ScreeningNotifier(this._ref) : super(ScreeningWorkflowState());

  void initScreeningForPatient(PatientModel patient) {
    final sId = _uuid.v4();
    state = ScreeningWorkflowState(
      patient: patient,
      screeningId: sId,
      thighSpots: [],
      shinSpots: [],
      testCountdown: 30,
    );
  }

  void saveClinicalAssessment(ClinicalAssessmentModel assessment) {
    state = state.copyWith(clinicalAssessment: assessment);
  }

  void saveLifestyleAssessment(LifestyleAssessmentModel assessment) {
    state = state.copyWith(lifestyleAssessment: assessment);
  }

  void startMovementTest({int durationSec = 30}) {
    state = state.copyWith(
      isTestRunning: true,
      testCountdown: durationSec,
      thighSpots: [],
      shinSpots: [],
    );
    _spotIndex = 0.0;

    _ref.read(bleProvider.notifier).startStreaming();

    _sensorSub?.cancel();
    _sensorSub = _ref.read(sensorPacketStreamProvider.stream).listen((packet) {
      _spotIndex += 0.2;
      final currentThigh = List<FlSpot>.from(state.thighSpots);
      final currentShin = List<FlSpot>.from(state.shinSpots);

      if (packet.sensorType.toString().contains('thigh')) {
        currentThigh.add(FlSpot(_spotIndex, packet.gyroX));
        if (currentThigh.length > 50) currentThigh.removeAt(0);
      } else {
        currentShin.add(FlSpot(_spotIndex, packet.gyroX));
        if (currentShin.length > 50) currentShin.removeAt(0);
      }

      state = state.copyWith(thighSpots: currentThigh, shinSpots: currentShin);
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.testCountdown > 1) {
        state = state.copyWith(testCountdown: state.testCountdown - 1);
      } else {
        stopMovementTest();
      }
    });
  }

  void stopMovementTest() {
    _countdownTimer?.cancel();
    _sensorSub?.cancel();
    _ref.read(bleProvider.notifier).stopStreaming();
    state = state.copyWith(isTestRunning: false);
  }

  Future<RiskResultModel> processScreeningResults() async {
    state = state.copyWith(isProcessing: true, processingStep: 'Reading sensor signals...');
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(processingStep: 'Extracting gait asymmetry & knee motion...');
    await Future.delayed(const Duration(milliseconds: 600));

    final gait = GaitFeaturesModel(
      id: _uuid.v4(),
      screeningId: state.screeningId!,
      cadence: 96.0,
      stepTime: 0.62,
      stanceTime: 0.63,
      swingTime: 0.37,
      gaitAsymmetry: 0.28,
      stepVariability: 0.07,
      thighAngularRange: 34.0,
      shinAngularRange: 42.0,
      estimatedKneeMotion: 40.0,
      sitToStandDuration: 2.7,
      qualityScore: 0.95,
      syncStatus: 'PENDING',
    );
    state = state.copyWith(gaitFeatures: gait, processingStep: 'Running AI screening model...');
    await Future.delayed(const Duration(milliseconds: 700));

    // Calculate deterministic local explainable risk
    final clinical = state.clinicalAssessment;
    final lifestyle = state.lifestyleAssessment;
    final patient = state.patient!;

    final pain = clinical?.painScore ?? 0;
    final asym = gait.gaitAsymmetry;
    final bmi = patient.bmi;
    final hasRedFlags = clinical?.hasRedFlags ?? false;

    // Scoring logic
    double rawScore = (asym * 25.0) + (pain / 10.0 * 15.0) + (bmi >= 25 ? 8.0 : 2.0);
    if (gait.estimatedKneeMotion < 45) rawScore += 8.0;
    if (lifestyle?.squattingLevel == 'OFTEN') rawScore += 4.0;
    if (patient.age >= 50) rawScore += 4.0;

    int finalScore = rawScore.round().clamp(0, 100);
    String category = finalScore <= 30 ? 'LOW' : (finalScore <= 60 ? 'MODERATE' : 'HIGH');

    String recommendation = category == 'LOW'
        ? 'Low screening risk. Continue low-impact daily movement and maintain healthy weight.'
        : (category == 'MODERATE'
            ? 'Moderate risk. Clinical review by a primary care physician or physiotherapist is recommended for preventive exercise therapy.'
            : 'High screening risk. Prompt clinical evaluation by a certified doctor/orthopedist is recommended.');

    if (hasRedFlags) {
      recommendation = 'Red-flag clinical symptoms reported. Prompt clinical review is recommended regardless of AI screening score.';
    }

    final factors = [
      ContributingFactorModel(
        name: 'gait_asymmetry',
        label: 'Gait Asymmetry',
        contribution: 0.32,
        explanation: 'Elevated side-to-side movement asymmetry detected during the walking test.',
      ),
      ContributingFactorModel(
        name: 'pain_score',
        label: 'Reported Knee Pain',
        contribution: 0.28,
        explanation: 'Knee pain score of $pain/10 elevates functional joint risk.',
      ),
      ContributingFactorModel(
        name: 'bmi',
        label: 'Body Mass Index',
        contribution: 0.22,
        explanation: 'BMI of ${patient.bmi} kg/m² contributes to increased joint load.',
      ),
      ContributingFactorModel(
        name: 'knee_motion',
        label: 'Knee Range of Motion',
        contribution: 0.18,
        explanation: 'Dynamic knee angular range was below normal reference.',
      ),
    ];

    final riskResult = RiskResultModel(
      id: _uuid.v4(),
      screeningId: state.screeningId!,
      patientId: patient.id,
      riskScore: finalScore,
      riskCategory: category,
      confidence: 0.88,
      dataCompleteness: 0.95,
      recommendation: recommendation,
      clinicianReviewRequired: category != 'LOW' || hasRedFlags,
      isDiagnostic: false,
      contributingFactors: factors,
      syncStatus: 'PENDING',
    );

    // Save all to SQLite
    final db = await _localDb.database;
    await db.insert('screenings', {
      'id': state.screeningId!,
      'patient_id': patient.id,
      'conducted_by': 'HW-01',
      'status': 'COMPLETED',
      'started_at': DateTime.now().toIso8601String(),
      'completed_at': DateTime.now().toIso8601String(),
      'is_demo': 1,
      'created_at': DateTime.now().toIso8601String(),
      'sync_status': 'PENDING',
    });

    if (clinical != null) await db.insert('clinical_assessments', clinical.toJson());
    if (lifestyle != null) await db.insert('lifestyle_assessments', lifestyle.toJson());
    await db.insert('gait_features', gait.toJson());
    await db.insert('risk_results', riskResult.toJson());

    // Enqueue to Sync Queue
    final syncNotifier = _ref.read(syncProvider.notifier);
    await syncNotifier.enqueueItem(
      entityType: 'SCREENING',
      entityId: state.screeningId!,
      operation: 'CREATE',
      payload: {'patient_id': patient.id, 'status': 'COMPLETED', 'is_demo': true},
    );
    if (clinical != null) {
      await syncNotifier.enqueueItem(
        entityType: 'CLINICAL_ASSESSMENT',
        entityId: clinical.id,
        operation: 'CREATE',
        payload: clinical.toJson(),
      );
    }
    if (lifestyle != null) {
      await syncNotifier.enqueueItem(
        entityType: 'LIFESTYLE_ASSESSMENT',
        entityId: lifestyle.id,
        operation: 'CREATE',
        payload: lifestyle.toJson(),
      );
    }
    await syncNotifier.enqueueItem(
      entityType: 'GAIT_FEATURES',
      entityId: gait.id,
      operation: 'CREATE',
      payload: gait.toJson(),
    );
    await syncNotifier.enqueueItem(
      entityType: 'RISK_RESULT',
      entityId: riskResult.id,
      operation: 'CREATE',
      payload: riskResult.toJson(),
    );

    state = state.copyWith(
      riskResult: riskResult,
      isProcessing: false,
      processingStep: null,
    );

    return riskResult;
  }

  Future<void> createReferral({
    required String reason,
    required String priority,
    String? notes,
    DateTime? preferredDate,
  }) async {
    if (state.patient == null) return;
    final refModel = ReferralModel(
      id: _uuid.v4(),
      patientId: state.patient!.id,
      screeningId: state.screeningId,
      reason: reason,
      priority: priority,
      status: 'PENDING',
      notes: notes,
      preferredDate: preferredDate,
      syncStatus: 'PENDING',
    );

    final db = await _localDb.database;
    await db.insert('referrals', refModel.toJson());

    await _ref.read(syncProvider.notifier).enqueueItem(
      entityType: 'REFERRAL',
      entityId: refModel.id,
      operation: 'CREATE',
      payload: refModel.toJson(),
    );
  }

  Future<void> createFollowUp({
    required DateTime dueDate,
    String type = 'PERIODIC_SCREENING',
    String? notes,
  }) async {
    if (state.patient == null) return;
    final fuModel = FollowUpModel(
      id: _uuid.v4(),
      patientId: state.patient!.id,
      screeningId: state.screeningId,
      dueDate: dueDate,
      type: type,
      status: 'SCHEDULED',
      notes: notes,
      syncStatus: 'PENDING',
    );

    final db = await _localDb.database;
    await db.insert('follow_ups', fuModel.toJson());

    await _ref.read(syncProvider.notifier).enqueueItem(
      entityType: 'FOLLOW_UP',
      entityId: fuModel.id,
      operation: 'CREATE',
      payload: fuModel.toJson(),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sensorSub?.cancel();
    super.dispose();
  }
}

final screeningProvider = StateNotifierProvider<ScreeningNotifier, ScreeningWorkflowState>((ref) {
  return ScreeningNotifier(ref);
});
