class PatientModel {
  final String id;
  final String patientCode;
  final String? initials;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String? phoneOptional;
  final String village;
  final String district;
  final String state;
  final String? emergencyContact;
  final String consentVersion;
  final DateTime consentedAt;
  final DateTime createdAt;
  final String syncStatus; // PENDING, SYNCED, FAILED

  PatientModel({
    required this.id,
    required this.patientCode,
    this.initials,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    this.phoneOptional,
    required this.village,
    required this.district,
    required this.state,
    this.emergencyContact,
    this.consentVersion = 'v1.0',
    DateTime? consentedAt,
    DateTime? createdAt,
    this.syncStatus = 'PENDING',
  })  : consentedAt = consentedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      patientCode: json['patient_code'] ?? '',
      initials: json['initials'],
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'FEMALE',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      phoneOptional: json['phone_optional'],
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      emergencyContact: json['emergency_contact'],
      consentVersion: json['consent_version'] ?? 'v1.0',
      consentedAt: json['consented_at'] != null ? DateTime.parse(json['consented_at']) : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      syncStatus: json['sync_status'] ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_code': patientCode,
      'initials': initials,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'phone_optional': phoneOptional,
      'village': village,
      'district': district,
      'state': state,
      'emergency_contact': emergencyContact,
      'consent_version': consentVersion,
      'consented_at': consentedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }
}
