class GaitFeaturesModel {
  final String id;
  final String screeningId;
  final double cadence;
  final double stepTime;
  final double stanceTime;
  final double swingTime;
  final double gaitAsymmetry;
  final double stepVariability;
  final double thighAngularRange;
  final double shinAngularRange;
  final double estimatedKneeMotion;
  final double? sitToStandDuration;
  final double qualityScore;
  final DateTime createdAt;
  final String syncStatus;

  GaitFeaturesModel({
    required this.id,
    required this.screeningId,
    required this.cadence,
    required this.stepTime,
    required this.stanceTime,
    required this.swingTime,
    required this.gaitAsymmetry,
    required this.stepVariability,
    required this.thighAngularRange,
    required this.shinAngularRange,
    required this.estimatedKneeMotion,
    this.sitToStandDuration,
    this.qualityScore = 1.0,
    DateTime? createdAt,
    this.syncStatus = 'PENDING',
  }) : createdAt = createdAt ?? DateTime.now();

  factory GaitFeaturesModel.fromJson(Map<String, dynamic> json) {
    return GaitFeaturesModel(
      id: json['id'] ?? '',
      screeningId: json['screening_id'] ?? '',
      cadence: (json['cadence'] as num?)?.toDouble() ?? 0.0,
      stepTime: (json['step_time'] as num?)?.toDouble() ?? 0.0,
      stanceTime: (json['stance_time'] as num?)?.toDouble() ?? 0.0,
      swingTime: (json['swing_time'] as num?)?.toDouble() ?? 0.0,
      gaitAsymmetry: (json['gait_asymmetry'] as num?)?.toDouble() ?? 0.0,
      stepVariability: (json['step_variability'] as num?)?.toDouble() ?? 0.0,
      thighAngularRange: (json['thigh_angular_range'] as num?)?.toDouble() ?? 0.0,
      shinAngularRange: (json['shin_angular_range'] as num?)?.toDouble() ?? 0.0,
      estimatedKneeMotion: (json['estimated_knee_motion'] as num?)?.toDouble() ?? 0.0,
      sitToStandDuration: (json['sit_to_stand_duration'] as num?)?.toDouble(),
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 1.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screening_id': screeningId,
      'cadence': cadence,
      'step_time': stepTime,
      'stance_time': stanceTime,
      'swing_time': swingTime,
      'gait_asymmetry': gaitAsymmetry,
      'step_variability': stepVariability,
      'thigh_angular_range': thighAngularRange,
      'shin_angular_range': shinAngularRange,
      'estimated_knee_motion': estimatedKneeMotion,
      'sit_to_stand_duration': sitToStandDuration,
      'quality_score': qualityScore,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
