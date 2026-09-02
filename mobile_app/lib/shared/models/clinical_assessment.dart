class ClinicalAssessmentModel {
  final String id;
  final String patientId;
  final int painScore; // 0-10
  final bool morningStiffness;
  final bool walkingDifficulty;
  final bool previousKneeInjury;
  final bool familyHistory;
  final bool swelling;
  final bool jointLocking;
  final bool feverOrAcuteInjury;
  final bool hasRedFlags;
  final DateTime createdAt;
  final String syncStatus;

  ClinicalAssessmentModel({
    required this.id,
    required this.patientId,
    required this.painScore,
    this.morningStiffness = false,
    this.walkingDifficulty = false,
    this.previousKneeInjury = false,
    this.familyHistory = false,
    this.swelling = false,
    this.jointLocking = false,
    this.feverOrAcuteInjury = false,
    bool? hasRedFlags,
    DateTime? createdAt,
    this.syncStatus = 'PENDING',
  })  : hasRedFlags = hasRedFlags ?? (painScore >= 8 || feverOrAcuteInjury || swelling || jointLocking),
        createdAt = createdAt ?? DateTime.now();

  factory ClinicalAssessmentModel.fromJson(Map<String, dynamic> json) {
    return ClinicalAssessmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      painScore: json['pain_score'] ?? 0,
      morningStiffness: json['morning_stiffness'] == 1 || json['morning_stiffness'] == true,
      walkingDifficulty: json['walking_difficulty'] == 1 || json['walking_difficulty'] == true,
      previousKneeInjury: json['previous_knee_injury'] == 1 || json['previous_knee_injury'] == true,
      familyHistory: json['family_history'] == 1 || json['family_history'] == true,
      swelling: json['swelling'] == 1 || json['swelling'] == true,
      jointLocking: json['joint_locking'] == 1 || json['joint_locking'] == true,
      feverOrAcuteInjury: json['fever_or_acute_injury'] == 1 || json['fever_or_acute_injury'] == true,
      hasRedFlags: json['has_red_flags'] == 1 || json['has_red_flags'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'pain_score': painScore,
      'morning_stiffness': morningStiffness,
      'walking_difficulty': walkingDifficulty,
      'previous_knee_injury': previousKneeInjury,
      'family_history': familyHistory,
      'swelling': swelling,
      'joint_locking': jointLocking,
      'fever_or_acute_injury': feverOrAcuteInjury,
      'has_red_flags': hasRedFlags,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
