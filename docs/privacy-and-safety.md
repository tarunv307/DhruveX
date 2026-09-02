# OSTEOGUARD-NER Privacy, Ethics & Medical Safety

**DhruveX** | Compliance & Clinical Ethics

---

## 1. Medical Safety Positioning & Non-Diagnostic Scope

> [!CAUTION]
> **MANDATORY CLINICAL DISCLAIMER**  
> *OSTEOGUARD-NER is an AI-assisted screening and clinical decision-support tool. It does NOT diagnose osteoarthritis or replace certified healthcare professionals. Definitive diagnosis requires physical examination, imaging (X-ray, MRI), and laboratory tests by a qualified clinician.*

### Safety Guardrails
1. **Red-Flag Escalation**: Any reported symptoms of severe acute pain ($\ge 8/10$), sudden joint swelling, fever, joint locking, or inability to bear weight trigger immediate red-flag banners instructing the health worker to refer the patient immediately, bypassing or superseding AI score interpretations.
2. **Never Overstate Certainty**: The system generates "Screening Risk" (Low, Moderate, High) with confidence metrics rather than definitive labels like "You have OA".
3. **Incomplete Data Protection**: If the wearable sensor stream is incomplete or drops below the 80% validity threshold, the system displays an `INCOMPLETE_DATA` state and refuses to calculate a synthetic risk score.
4. **No Direct Medication Prescriptions**: The app only provides conservative lifestyle guidance (gentle movement as tolerated, weight management, avoiding acute pain triggers, seeking clinical consultation).

---

## 2. Privacy & Data Protection Framework

1. **Data Minimization**: Only necessary screening demographics (Age, Gender, Height, Weight for BMI, Village/District) are collected. No Aadhaar, government ID, or full home address is required.
2. **On-Device BLE Anonymization**: Over-the-air BLE packets use pseudo-anonymized Patient Codes (e.g. `P-9842`) and never broadcast patient initials or phone numbers.
3. **Consent Versioning**: Digital informed consent is recorded with explicit timestamp and consent version hash before any data is captured.
4. **Encrypted Token Storage**: Tokens are stored using AES-256 encrypted hardware keystores via `flutter_secure_storage` on mobile.
5. **No Permanent Raw IMU Storage by Default**: Raw high-frequency 50Hz sensor arrays are processed into aggregated gait features (asymmetry, cadence, angular range) locally; raw streams are discarded unless research opt-in is enabled.
