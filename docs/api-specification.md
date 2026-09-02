# OSTEOGUARD-NER API Specification

**DhruveX** | Version: **1.0.0** | Prefix: `/api/v1`

---

## 1. Global Standard Response Format

All endpoints follow a uniform JSON structure:

### Success Response (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully",
  "request_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
}
```

### Error Response (`400`, `401`, `403`, `404`, `422`, `500`)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable error description",
    "details": [
      {
        "field": "bmi",
        "issue": "Value must be between 10.0 and 60.0"
      }
    ]
  },
  "request_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
}
```

---

## 2. API Endpoints Catalog

### Authentication (`/api/v1/auth`)
| Method | Path | Auth Required | Description |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | No | Register health-worker or doctor |
| `POST` | `/api/v1/auth/login` | No | Authenticate and obtain JWT access/refresh token |
| `POST` | `/api/v1/auth/refresh` | No | Exchange refresh token for new access token |
| `POST` | `/api/v1/auth/logout` | Yes | Revoke active session |
| `GET` | `/api/v1/auth/me` | Yes | Retrieve current authenticated user profile |

### Patient Management (`/api/v1/patients`)
| Method | Path | Roles | Description |
|---|---|---|---|
| `POST` | `/api/v1/patients` | HealthWorker, Doctor, Admin | Register patient (minimal PII, auto-generated code) |
| `GET` | `/api/v1/patients` | HealthWorker, Doctor, Admin | Search/filter patients by code, village, risk |
| `GET` | `/api/v1/patients/{id}` | All Authenticated | Get patient details and assessment history |
| `PATCH` | `/api/v1/patients/{id}` | HealthWorker, Doctor, Admin | Update patient demographic details |
| `DELETE` | `/api/v1/patients/{id}` | Admin | Soft delete patient record |

### Clinical & Lifestyle Assessments (`/api/v1/clinical-assessments`, `/api/v1/lifestyle-assessments`)
| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/patients/{id}/clinical-assessments` | Submit 0-10 pain score, stiffness, red flags |
| `GET` | `/api/v1/patients/{id}/clinical-assessments` | Fetch clinical assessment timeline |
| `POST` | `/api/v1/patients/{id}/lifestyle-assessments` | Submit squatting, load carrying, daily walking metrics |
| `GET` | `/api/v1/patients/{id}/lifestyle-assessments` | Fetch lifestyle history |

### Screening & Gait Biomechanics (`/api/v1/screenings`)
| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/screenings` | Initiate a new screening session |
| `GET` | `/api/v1/screenings/{id}` | Get screening session status and details |
| `POST` | `/api/v1/screenings/{id}/gait-features` | Upload derived IMU gait features (cadence, asymmetry, etc.) |
| `POST` | `/api/v1/screenings/{id}/calculate-risk` | Trigger rule-based/TinyML risk evaluation |
| `GET` | `/api/v1/screenings/{id}/risk-result` | Retrieve explainable screening risk output |
| `POST` | `/api/v1/screenings/{id}/complete` | Mark screening session finalized |

### Referrals & Follow-ups (`/api/v1/referrals`, `/api/v1/follow-ups`)
| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/referrals` | Create referral to PHC / Physiotherapy |
| `GET` | `/api/v1/referrals` | List referrals with status filter |
| `PATCH` | `/api/v1/referrals/{id}` | Update status (`PENDING`, `ACCEPTED`, `COMPLETED`, `CANCELLED`) |
| `POST` | `/api/v1/follow-ups` | Schedule screening review reminder |
| `GET` | `/api/v1/patients/{id}/follow-ups` | Get patient follow-up schedule |

### Offline Batch Sync (`/api/v1/sync`)
| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/sync/batch` | Idempotent bulk sync payload from offline mobile queue |
| `GET` | `/api/v1/sync/status` | Check server processing status of synced batch |

### Clinic Analytics Dashboard (`/api/v1/dashboard`)
| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/dashboard/summary` | Aggregate counts of screened patients, risk tiers, sync alerts |
| `GET` | `/api/v1/dashboard/risk-distribution` | Breakdown of Low / Moderate / High risk across clinics |
| `GET` | `/api/v1/dashboard/recent-alerts` | High risk and red-flag cases needing triage |

### Reports (`/api/v1/reports`)
| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/reports/screenings/{id}/pdf` | Generate printable PDF report with clinical disclaimer |
