class FollowUpModel {
  final String id;
  final String patientId;
  final String? screeningId;
  final DateTime dueDate;
  final String type; // PERIODIC_SCREENING, PHYSIOTHERAPY_CHECK
  final String status; // SCHEDULED, COMPLETED, MISSED, CANCELLED
  final bool reminderSent;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  FollowUpModel({
    required this.id,
    required this.patientId,
    this.screeningId,
    required this.dueDate,
    this.type = 'PERIODIC_SCREENING',
    this.status = 'SCHEDULED',
    this.reminderSent = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'PENDING',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      screeningId: json['screening_id'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now().add(const Duration(days: 30)),
      type: json['type'] ?? 'PERIODIC_SCREENING',
      status: json['status'] ?? 'SCHEDULED',
      reminderSent: json['reminder_sent'] == 1 || json['reminder_sent'] == true,
      notes: json['notes'],
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
      'due_date': dueDate.toIso8601String(),
      'type': type,
      'status': status,
      'reminder_sent': reminderSent,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
