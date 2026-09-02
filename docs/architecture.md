# OSTEOGUARD-NER System Architecture

**DhruveX** | Problem Statement ID: **SIH26004**  
*Move Early. Detect Early. Protect Every Step.*

---

## 1. High-Level Architecture Overview

OSTEOGUARD-NER is an AI-assisted osteoarthritis risk screening and referral-support ecosystem. It bridges low-power wearable biomedical sensors (ESP32-S3 with dual 6-axis IMUs) with frontline healthcare workers and primary health centers (PHCs).

```mermaid
graph TD
    subgraph Wearable ["Wearable Hardware (ESP32-S3)"]
        IMU1["Thigh 6-DOF IMU"]
        IMU2["Shin 6-DOF IMU"]
        BLE_Chip["BLE 5.0 Radio"]
        IMU1 --> BLE_Chip
        IMU2 --> BLE_Chip
    end

    subgraph MobileApp ["Mobile Patient / Health-Worker App (Flutter 3.x)"]
        BLE_Subsystem["BLE Subsystem (flutter_blue_plus)"]
        Local_DB["SQLite Local DB (Offline Cache)"]
        Sync_Engine["Sync Engine & Queue"]
        UI_Layer["Material 3 UI (Riverpod + GoRouter)"]
        Risk_View["Risk & Explainability Visualizer"]
        
        BLE_Chip -.->|BLE Packets| BLE_Subsystem
        BLE_Subsystem --> Local_DB
        UI_Layer --> Local_DB
        Local_DB --> Sync_Engine
        UI_Layer --> Risk_View
    end

    subgraph Backend ["Cloud / On-Premise Backend (FastAPI + PostgreSQL)"]
        API_GW["FastAPI REST Gateway (/api/v1)"]
        Auth_Service["JWT & RBAC Security"]
        Risk_Engine["Risk Assessment Engine (Rule-based / Edge ML)"]
        Sync_Service["Idempotent Batch Sync"]
        Analytics_Service["PHC Dashboard & Trend Engine"]
        Postgres_DB[("PostgreSQL 16 + PostGIS")]

        Sync_Engine ==>|HTTPS / REST| API_GW
        API_GW --> Auth_Service
        API_GW --> Risk_Engine
        API_GW --> Sync_Service
        API_GW --> Analytics_Service
        Sync_Service --> Postgres_DB
        Analytics_Service --> Postgres_DB
    end

    subgraph HospitalDashboard ["Hospital / Clinic Dashboard"]
        Doctor_Portal["Doctor / Physiotherapist Portal"]
        Admin_Portal["PHC Clinic Admin Analytics"]
        Doctor_Portal --> API_GW
        Admin_Portal --> API_GW
    end
```

---

## 2. Core Operational Modes

1. **Offline Mode**: Complete screening, questionnaire capture, BLE test conduction, local heuristic risk score calculation, and local PDF export without cellular network or Wi-Fi.
2. **Online Sync Mode**: Automatic detection of active connectivity via `connectivity_plus`, batch syncing queued items with UUID idempotency and conflict preservation.
3. **BLE Connected Mode**: Real-time sensor stream reception at 50Hz, live signal-quality indication, and battery monitoring.
4. **BLE Disconnected/Retry Mode**: Graceful degradation, packet timeout recovery, and retry prompts.
5. **Server Unavailable Mode**: Automatic exponential backoff without interrupting frontline screening workflows.
6. **Incomplete Sensor-Data Mode**: Safety guard preventing fabricated risk scores when IMU sensors are disconnected or drop below 80% data completeness threshold.
7. **Demo Mode**: Full UI and end-to-end workflow demonstration with realistic synthesized biomechanics data without requiring physical hardware.

---

## 3. Data Flow & Screening Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor HW as Health Worker / Patient
    participant App as Mobile App
    participant BLE as ESP32-S3 Wearable
    participant DB as SQLite Local Storage
    participant API as FastAPI Backend

    HW->>App: Register Patient (Age, Gender, BMI, Village)
    App->>DB: Save Patient Record (sync_status=PENDING)
    HW->>App: Complete Clinical & Lifestyle Questionnaires
    App->>DB: Save Assessment Data
    HW->>App: Pair ESP32-S3 Wearable (Thigh + Shin IMU)
    App->>BLE: Connect & Perform 5-sec Calibration
    BLE-->>App: Calibration OK & Battery Level (95%)
    HW->>App: Start Walking Test & Sit-to-Stand
    BLE-->>App: Stream 6-DOF IMU Packets (Thigh & Shin)
    App->>App: Signal Processing & Feature Extraction
    App->>App: Run Local Risk & Explainability Engine
    App->>DB: Save Screening, GaitFeatures & RiskResult
    App->>HW: Display Risk Category (Low/Mod/High) + Factors + Disclaimer
    
    alt Internet is Available
        App->>API: POST /api/v1/sync/batch (Encrypted Payload)
        API->>API: Validate & Persist to PostgreSQL
        API-->>App: Sync Confirmation (200 OK)
        App->>DB: Update sync_status=SYNCED
    else Offline
        App->>DB: Retain in SyncQueue for future upload
    end
```

---

## 4. Key Subsystem Responsibilities

| Subsystem | Technology | Responsibility |
|---|---|---|
| **Mobile Client** | Flutter 3.x, Dart 3.x, Riverpod | User interface, state management, BLE communication, local database, offline queue. |
| **BLE Communication** | `flutter_blue_plus` | Dual IMU discovery, MTU negotiation, continuous streaming, CRC16 validation. |
| **Local Storage** | `sqflite`, `flutter_secure_storage` | Offline-first persistence of patients, assessments, sessions, and encrypted tokens. |
| **Backend API** | FastAPI, Pydantic v2, Python 3.12 | RESTful endpoints, JWT authentication, RBAC, input validation, audit logging. |
| **Database** | PostgreSQL 16, SQLAlchemy 2.x | Relational storage, PostGIS spatial support for PHC geolocation, JSONB feature storage. |
| **Risk Engine** | Python / Dart Heuristic Engine | Multi-factor risk calculation incorporating biomechanics (asymmetry, knee ROM) and clinical factors (pain, BMI). |
| **Reporting** | Python ReportLab / Dart `pdf` | Clinically formatted PDF screening summaries with disclaimers and trend charts. |
