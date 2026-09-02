import 'dart:convert';

class ContributingFactorModel {
  final String name;
  final String label;
  final double contribution;
  final String explanation;

  ContributingFactorModel({
    required this.name,
    required this.label,
    required this.contribution,
    required this.explanation,
  });

  factory ContributingFactorModel.fromJson(Map<String, dynamic> json) {
    return ContributingFactorModel(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'contribution': contribution,
      'explanation': explanation,
    };
  }
}

class RiskResultModel {
  final String id;
  final String screeningId;
  final String patientId;
  final int? riskScore; // 0-100 or null if incomplete
  final String riskCategory; // LOW, MODERATE, HIGH, INCOMPLETE
  final double confidence;
  final double dataCompleteness;
  final String recommendation;
  final bool clinicianReviewRequired;
  final bool isDiagnostic;
  final String disclaimer;
  final String modelVersion;
  final List<ContributingFactorModel> contributingFactors;
  final DateTime createdAt;
  final String syncStatus;

  RiskResultModel({
    required this.id,
    required this.screeningId,
    required this.patientId,
    this.riskScore,
    required this.riskCategory,
    this.confidence = 0.8,
    this.dataCompleteness = 1.0,
    required this.recommendation,
    this.clinicianReviewRequired = false,
    this.isDiagnostic = false,
    this.disclaimer = 'This is an AI-assisted screening result, not a final diagnosis. Consult a qualified clinician for evaluation.',
    this.modelVersion = 'prototype-rule-v1',
    this.contributingFactors = const [],
    DateTime? createdAt,
    this.syncStatus = 'PENDING',
  }) : createdAt = createdAt ?? DateTime.now();

  factory RiskResultModel.fromJson(Map<String, dynamic> json) {
    List<ContributingFactorModel> factors = [];
    if (json['contributing_factors'] != null) {
      if (json['contributing_factors'] is List) {
        factors = (json['contributing_factors'] as List)
            .map((f) => ContributingFactorModel.fromJson(f))
            .toList();
      }
    } else if (json['contributing_factors_json'] != null) {
      try {
        final decoded = jsonDecode(json['contributing_factors_json']);
        if (decoded is List) {
          factors = decoded.map((f) => ContributingFactorModel.fromJson(f)).toList();
        }
      } catch (_) {}
    }

    return RiskResultModel(
      id: json['id'] ?? '',
      screeningId: json['screening_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      riskScore: json['risk_score'],
      riskCategory: json['risk_category'] ?? 'LOW',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      dataCompleteness: (json['data_completeness'] as num?)?.toDouble() ?? 1.0,
      recommendation: json['recommendation'] ?? '',
      clinicianReviewRequired: json['clinician_review_required'] == 1 || json['clinician_review_required'] == true,
      isDiagnostic: json['is_diagnostic'] == 1 || json['is_diagnostic'] == true,
      disclaimer: json['disclaimer'] ?? 'Screening estimate only.',
      modelVersion: json['model_version'] ?? 'prototype-rule-v1',
      contributingFactors: factors,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screening_id': screeningId,
      'patient_id': patientId,
      'risk_score': riskScore,
      'risk_category': riskCategory,
      'confidence': confidence,
      'data_completeness': dataCompleteness,
      'recommendation': recommendation,
      'clinician_review_required': clinicianReviewRequired,
      'is_diagnostic': isDiagnostic,
      'disclaimer': disclaimer,
      'model_version': modelVersion,
      'contributing_factors': contributingFactors.map((f) => f.toJson()).toList(),
      'contributing_factors_json': jsonEncode(contributingFactors.map((f) => f.toJson()).toList()),
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
