# OSTEOGUARD-NER PATIENT APP & HEALTHCARE ECOSYSTEM

**Team Name:** DhruveX  
**Written By:** TARUN V  
**Problem Statement ID:** SIH26004  
**Theme:** Healthcare & MedTech | **Category:** Hardware  

> **Tagline:** *"Move Early. Detect Early. Protect Every Step."*

---

## ⚠️ MANDATORY CLINICAL SAFETY POSITIONING

> [!CAUTION]
> **IMPORTANT MEDICAL DISCLAIMER:**  
> OSTEOGUARD-NER is strictly an **AI-assisted osteoarthritis risk screening and referral-support application**. It does **NOT** diagnose osteoarthritis or replace certified clinicians. Definitive diagnosis requires clinical physical evaluation, patient history, imaging (X-ray, MRI), or laboratory investigation by a qualified clinician.

---

## 1. Project Folder Tree

```text
.
├── .github/
│   └── workflows/
│       ├── backend.yml                 # Backend CI (pytest, lint, docker build)
│       └── flutter.yml                 # Flutter CI (analyze, test, apk build)
├── backend/
│   ├── alembic/
│   │   ├── versions/
│   │   │   └── 001_initial_schema.py   # PostgreSQL migrations
│   │   ├── env.py
│   │   └── script.py.mako
│   ├── app/
│   │   ├── ml/
│   │   │   ├── risk_engine.py          # Risk Engine dispatcher
│   │   │   ├── risk_model.py           # Abstract RiskModel interface
│   │   │   ├── rule_based_model.py     # Multi-factor transparent scoring
│   │   │   └── tinyml_model.py         # ESP32 Edge AI model placeholder
│   │   ├── middleware/
│   │   │   ├── audit_middleware.py     # Request audit logging
│   │   │   └── error_middleware.py     # Standardized JSON error envelope
│   │   ├── models/
│   │   │   └── entities.py             # SQLAlchemy 2.x relational models
│   │   ├── routers/
│   │   │   ├── auth.py                 # JWT Auth & RBAC
│   │   │   ├── clinical.py             # Pain score & red flags
│   │   │   ├── dashboard.py            # Clinic analytics & alerts
│   │   │   ├── devices.py              # ESP32 device registry
│   │   │   ├── follow_ups.py           # Scheduled reminders
│   │   │   ├── gait.py                 # IMU biomechanics
│   │   │   ├── lifestyle.py            # Occupational factors
│   │   │   ├── patients.py             # Patient CRUD (minimal PII)
│   │   │   ├── referrals.py            # PHC referral management
│   │   │   ├── reports.py              # Clinical PDF generator
│   │   │   ├── risk.py                 # Risk assessment endpoint
│   │   │   └── sync.py                 # Idempotent offline batch sync
│   │   ├── schemas/
│   │   │   └── schemas.py              # Pydantic v2 schemas
│   │   ├── security/
│   │   │   ├── jwt.py                  # JWT token handling
│   │   │   ├── passwords.py            # Direct bcrypt hashing
│   │   │   └── rbac.py                 # Role guards
│   │   ├── utils/
│   │   │   ├── helpers.py              # BMI & Code generator
│   │   │   └── pdf_generator.py        # ReportLab PDF engine
│   │   ├── config.py                   # Pydantic BaseSettings
│   │   ├── database.py                 # Engine & Session factory
│   │   ├── dependencies.py             # FastAPI dependencies
│   │   └── main.py                     # App factory & OpenAPI spec
│   ├── tests/                          # Complete pytest test suite
│   ├── .env.example
│   ├── alembic.ini
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── README.md
│   └── requirements.txt
├── docs/
│   ├── api-specification.md            # OpenAPI schema & REST guide
│   ├── architecture.md                 # System diagrams & state machines
│   ├── ble-protocol.md                 # ESP32 24-byte packet layout & CRC
│   ├── deployment.md                   # Docker & production hardening
│   ├── offline-sync.md                 # Idempotency & queue resolution
│   └── privacy-and-safety.md           # Ethics & red-flag protocols
├── mobile_app/
│   ├── android/
│   │   └── app/
│   │       ├── src/main/AndroidManifest.xml # BLE & location permissions
│   │       └── build.gradle
│   ├── lib/
│   │   ├── core/
│   │   │   ├── bluetooth/              # BLE service & packet parser
│   │   │   ├── constants/              # Colors, strings, UUIDs, endpoints
│   │   │   ├── errors/                 # Domain failures & exceptions
│   │   │   ├── networking/             # Dio client & interceptors
│   │   │   ├── permissions/            # BLE & location handlers
│   │   │   ├── router/                 # GoRouter navigation
│   │   │   ├── storage/                # SQLite local DB & Keystore
│   │   │   ├── theme/                  # Material 3 medical theme
│   │   │   └── utils/                  # BMI & Date formatters
│   │   ├── features/
│   │   │   ├── authentication/         # Login & Offline field mode
│   │   │   ├── clinical_questionnaire/ # 0-10 VAS & Red Flags
│   │   │   ├── device_connection/      # BLE pairing & calibration
│   │   │   ├── follow_up/              # Follow-up scheduling
│   │   │   ├── guidance/               # Safe joint health advice
│   │   │   ├── home/                   # Dashboard & sync stats
│   │   │   ├── lifestyle_assessment/   # Squatting & manual labor
│   │   │   ├── onboarding/             # Splash, Onboarding & Consent
│   │   │   ├── patient_history/        # Session timeline & charts
│   │   │   ├── patient_registration/   # Patient demographics & BMI
│   │   │   ├── referrals/              # PHC referral portal
│   │   │   ├── risk_result/            # 0-100 Gauge & Explainability
│   │   │   ├── screening_test/         # Walking & Sit-to-Stand test
│   │   │   └── settings/               # Settings, sync & demo toggle
│   │   ├── shared/
│   │   │   ├── models/                 # Strongly-typed immutable models
│   │   │   ├── providers/              # Riverpod state notifiers
│   │   │   └── widgets/                # UI design system components
│   │   ├── app.dart
│   │   └── main.dart
│   ├── test/                           # Unit & widget test suites
│   ├── .env.example
│   ├── pubspec.yaml
│   └── README.md
└── README.md
```

---

## 2. Quick Setup & Run Commands

### A. FastAPI Backend
```bash
# Navigate to backend
cd backend

# Option 1: Docker Stack (FastAPI + PostgreSQL + Redis)
docker-compose up -d --build

# Option 2: Local Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Swagger UI: `http://localhost:8000/docs`

### B. Flutter Mobile Application
```bash
# Navigate to mobile app
cd mobile_app

# Install dependencies
flutter pub get

# Configure environment
cp .env.example .env

# Run on Android Phone or Emulator
flutter run
```

---

## 3. Demo Mode Instructions (Hardware-Free Testing)

The application includes an active **DEMO BLE MODE**:
1. Open the app on your phone or emulator.
2. The Demo Mode badge is visible on the Home screen.
3. Tap **"Start New Patient Screening"** $\to$ complete questionnaire $\to$ navigate to **"Connect Wearable Device"**.
4. The simulated ESP32-S3 wearable will appear automatically. Tap **"Connect"**.
5. During the **Walking Test (30s)**, realistic dual-IMU gyroscope waveforms and gait parameters (asymmetry, cadence, knee motion) will stream in real-time.
6. The app computes the 0–100 risk score and displays the full explainability breakdown and PDF export without needing hardware.

---

## 4. BLE Hardware Protocol (ESP32-S3 Dual-IMU)

- **Service UUID:** `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- **Thigh IMU Characteristic:** `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` (Notify)
- **Shin IMU Characteristic:** `6E400004-B5A3-F393-E0A9-E50E24DCCA9E` (Notify)
- **Sampling Rate:** 50 Hz, 24-byte binary packet with CRC-16-CCITT checksum validation.

---

## 5. Offline Sync Engine

- Frontline health workers can register patients, record symptoms, and run movement tests completely offline.
- Every transaction is written to an atomic SQLite `sync_queue` table.
- When internet is restored, the `SyncService` sends an idempotent batch payload (`POST /api/v1/sync/batch`) using UUID keys, preventing duplicate records on network retries.

---

## 6. Automated Testing

### Backend Unit & Integration Tests (100% Pass)
```bash
cd backend
pytest -v
```

### Flutter Unit & Widget Tests
```bash
cd mobile_app
flutter test
```

---

## 7. Android APK Generation

```bash
cd mobile_app

# Debug APK:
flutter build apk --debug

# Production Release APK:
flutter build apk --release

# Split APKs (Optimized per ABI):
flutter build apk --split-per-abi --release
```

---

## 8. Clinical Safety Checklist & Red-Flag Protocol

- [x] **Mandatory Disclaimer:** Displayed on splash, onboarding, consent, screening results, and PDF exports.
- [x] **Red-Flag Escalation:** Triggered automatically on severe pain ($\ge 8/10$), sudden joint swelling, fever, or joint locking.
- [x] **Incomplete Data Guard:** Disables synthetic score generation if sensor packet completeness drops below 80%.
- [x] **Data Minimization:** No government IDs or raw high-frequency IMU files stored permanently.
- [x] **No Drug Prescriptions:** Strictly limited to general lifestyle and safe movement recommendations.
