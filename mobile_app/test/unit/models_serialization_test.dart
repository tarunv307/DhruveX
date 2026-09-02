import 'package:flutter_test/flutter_test.dart';
import 'package:osteoguard_ner/shared/models/patient.dart';
import 'package:osteoguard_ner/shared/models/clinical_assessment.dart';
import 'package:osteoguard_ner/shared/models/risk_result.dart';

void main() {
  group('Models Serialization Tests', () {
    test('PatientModel JSON serialization and deserialization', () {
      final patient = PatientModel(
        id: 'P-TEST-01',
        patientCode: 'P-1234',
        initials: 'T.V.',
        age: 55,
        gender: 'MALE',
        heightCm: 172.0,
        weightKg: 74.0,
        bmi: 25.0,
        village: 'Khed',
        district: 'Pune',
        state: 'Maharashtra',
      );

      final json = patient.toJson();
      final decoded = PatientModel.fromJson(json);

      expect(decoded.id, 'P-TEST-01');
      expect(decoded.patientCode, 'P-1234');
      expect(decoded.bmi, 25.0);
    });

    test('ClinicalAssessmentModel red-flag auto-detection', () {
      final normalAssessment = ClinicalAssessmentModel(
        id: 'C-01',
        patientId: 'P-01',
        painScore: 3,
        morningStiffness: false,
      );
      expect(normalAssessment.hasRedFlags, isFalse);

      final redFlagAssessment = ClinicalAssessmentModel(
        id: 'C-02',
        patientId: 'P-01',
        painScore: 9, // Severe pain triggers red flag
        feverOrAcuteInjury: true,
      );
      expect(redFlagAssessment.hasRedFlags, isTrue);
    });

    test('RiskResultModel factor serialization', () {
      final factors = [
        ContributingFactorModel(
          name: 'gait_asymmetry',
          label: 'Gait Asymmetry',
          contribution: 0.35,
          explanation: 'Asymmetric load detected',
        ),
      ];

      final risk = RiskResultModel(
        id: 'R-01',
        screeningId: 'S-01',
        patientId: 'P-01',
        riskScore: 54,
        riskCategory: 'MODERATE',
        recommendation: 'Clinical review recommended',
        contributingFactors: factors,
      );

      final json = risk.toJson();
      final decoded = RiskResultModel.fromJson(json);

      expect(decoded.riskScore, 54);
      expect(decoded.riskCategory, 'MODERATE');
      expect(decoded.contributingFactors.length, 1);
      expect(decoded.contributingFactors.first.name, 'gait_asymmetry');
    });
  });
}
