class SyncQueueItem {
  final String id;
  final String entityType; // PATIENT, CLINICAL_ASSESSMENT, LIFESTYLE_ASSESSMENT, SCREENING, GAIT_FEATURES, RISK_RESULT, REFERRAL, FOLLOW_UP
  final String entityId;
  final String operation; // CREATE, UPDATE, DELETE
  final String payloadJson;
  final int retryCount;
  final String? lastError;
  final String status; // PENDING, SYNCING, FAILED, COMPLETED
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.operation = 'CREATE',
    required this.payloadJson,
    this.retryCount = 0,
    this.lastError,
    this.status = 'PENDING',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'],
      entityType: map['entity_type'],
      entityId: map['entity_id'],
      operation: map['operation'] ?? 'CREATE',
      payloadJson: map['payload_json'],
      retryCount: map['retry_count'] ?? 0,
      lastError: map['last_error'],
      status: map['status'] ?? 'PENDING',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload_json': payloadJson,
      'retry_count': retryCount,
      'last_error': lastError,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
