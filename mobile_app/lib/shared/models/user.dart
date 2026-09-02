class UserModel {
  final String id;
  final String phone;
  final String displayName;
  final String role;
  final String? healthWorkerId;
  final String? clinicId;

  UserModel({
    required this.id,
    required this.phone,
    required this.displayName,
    required this.role,
    this.healthWorkerId,
    this.clinicId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      displayName: json['display_name'] ?? '',
      role: json['role'] ?? 'HEALTH_WORKER',
      healthWorkerId: json['health_worker_id'],
      clinicId: json['clinic_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'display_name': displayName,
      'role': role,
      'health_worker_id': healthWorkerId,
      'clinic_id': clinicId,
    };
  }
}
