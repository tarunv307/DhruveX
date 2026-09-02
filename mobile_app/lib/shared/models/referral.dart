class ReferralModel {
  final String id;
  final String patientId;
  final String? screeningId;
  final String? clinicId;
  final String reason;
  final String priority; // ROUTINE, URGENT, EMERGENCY
  final String status; // DRAFT, PENDING, ACCEPTED, COMPLETED, CANCELLED
  final String? notes;
  final DateTime? preferredDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  ReferralModel({
    required this.id,
    required this.patientId,
    this.screeningId,
    this.clinicId,
    required this.reason,
    this.priority = 'ROUTINE',
    this.status = 'PENDING',
    this.notes,
    this.preferredDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'PENDING',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      screeningId: json['screening_id'],
      clinicId: json['clinic_id'],
      reason: json['reason'] ?? '',
      priority: json['priority'] ?? 'ROUTINE',
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      preferredDate: json['preferred_date'] != null ? DateTime.parse(json['preferred_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'screening_id': screeningId,
      'clinic_id': clinicId,
      'reason': reason,
      'priority': priority,
      'status': status,
      'notes': notes,
      'preferred_date': preferredDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
