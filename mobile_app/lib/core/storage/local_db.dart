import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('osteoguard_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Patients Table
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        patient_code TEXT UNIQUE NOT NULL,
        initials TEXT,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        bmi REAL NOT NULL,
        phone_optional TEXT,
        village TEXT NOT NULL,
        district TEXT NOT NULL,
        state TEXT NOT NULL,
        emergency_contact TEXT,
        consent_version TEXT NOT NULL,
        consented_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');

    // 2. Clinical Assessments Table
    await db.execute('''
      CREATE TABLE clinical_assessments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        pain_score INTEGER NOT NULL,
        morning_stiffness INTEGER NOT NULL,
        walking_difficulty INTEGER NOT NULL,
        previous_knee_injury INTEGER NOT NULL,
        family_history INTEGER NOT NULL,
        swelling INTEGER NOT NULL,
        joint_locking INTEGER NOT NULL,
        fever_or_acute_injury INTEGER NOT NULL,
        has_red_flags INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 3. Lifestyle Assessments Table
    await db.execute('''
      CREATE TABLE lifestyle_assessments (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        squatting_level TEXT NOT NULL,
        load_carrying_level TEXT NOT NULL,
        manual_work INTEGER NOT NULL,
        hill_walking_level TEXT NOT NULL,
        physical_activity_level TEXT NOT NULL,
        daily_walking_minutes INTEGER NOT NULL,
        footwear_type TEXT,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 4. Screenings Table
    await db.execute('''
      CREATE TABLE screenings (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        conducted_by TEXT,
        status TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        is_demo INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 5. Gait Features Table
    await db.execute('''
      CREATE TABLE gait_features (
        id TEXT PRIMARY KEY,
        screening_id TEXT UNIQUE NOT NULL,
        cadence REAL NOT NULL,
        step_time REAL NOT NULL,
        stance_time REAL NOT NULL,
        swing_time REAL NOT NULL,
        gait_asymmetry REAL NOT NULL,
        step_variability REAL NOT NULL,
        thigh_angular_range REAL NOT NULL,
        shin_angular_range REAL NOT NULL,
        estimated_knee_motion REAL NOT NULL,
        sit_to_stand_duration REAL,
        quality_score REAL NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (screening_id) REFERENCES screenings (id)
      )
    ''');

    // 6. Risk Results Table
    await db.execute('''
      CREATE TABLE risk_results (
        id TEXT PRIMARY KEY,
        screening_id TEXT UNIQUE NOT NULL,
        patient_id TEXT NOT NULL,
        risk_score INTEGER,
        risk_category TEXT NOT NULL,
        confidence REAL NOT NULL,
        data_completeness REAL NOT NULL,
        recommendation TEXT NOT NULL,
        clinician_review_required INTEGER NOT NULL,
        disclaimer TEXT NOT NULL,
        model_version TEXT NOT NULL,
        contributing_factors_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (screening_id) REFERENCES screenings (id),
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 7. Referrals Table
    await db.execute('''
      CREATE TABLE referrals (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        screening_id TEXT,
        clinic_id TEXT,
        reason TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        preferred_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 8. Follow-ups Table
    await db.execute('''
      CREATE TABLE follow_ups (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        screening_id TEXT,
        due_date TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        reminder_sent INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // 9. Sync Queue Table (Idempotent offline transaction ledger)
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
