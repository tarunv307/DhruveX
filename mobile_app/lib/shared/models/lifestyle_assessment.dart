class LifestyleAssessmentModel {
  final String id;
  final String patientId;
  final String squattingLevel; // NEVER, SOMETIMES, OFTEN
  final String loadCarryingLevel; // LOW, MEDIUM, HIGH
  final bool manualWork;
  final String hillWalkingLevel; // LOW, MEDIUM, HIGH
  final String physicalActivityLevel; // LOW, MEDIUM, HIGH
  final int dailyWalkingMinutes;
  final String? footwearType;
  final DateTime createdAt;
  final String syncStatus;

  LifestyleAssessmentModel({
    required this.id,
    required this.patientId,
    this.squattingLevel = 'SOMETIMES',
    this.loadCarryingLevel = 'LOW',
    this.manualWork = false,
    this.hillWalkingLevel = 'LOW',
    this.physicalActivityLevel = 'MEDIUM',
    this.dailyWalkingMinutes = 30,
    this.footwearType,
    DateTime? createdAt,
    this.syncStatus = 'PENDING',
  }) : createdAt = createdAt ?? DateTime.now();

  factory LifestyleAssessmentModel.fromJson(Map<String, dynamic> json) {
    return LifestyleAssessmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      squattingLevel: json['squatting_level'] ?? 'SOMETIMES',
      loadCarryingLevel: json['load_carrying_level'] ?? 'LOW',
      manualWork: json['manual_work'] == 1 || json['manual_work'] == true,
      hillWalkingLevel: json['hill_walking_level'] ?? 'LOW',
      physicalActivityLevel: json['physical_activity_level'] ?? 'MEDIUM',
      dailyWalkingMinutes: json['daily_walking_minutes'] ?? 30,
      footwearType: json['footwear_type'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'squatting_level': squattingLevel,
      'load_carrying_level': loadCarryingLevel,
      'manual_work': manualWork,
      'hill_walking_level': hillWalkingLevel,
      'physical_activity_level': physicalActivityLevel,
      'daily_walking_minutes': dailyWalkingMinutes,
      'footwear_type': footwearType,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
