# OSTEOGUARD-NER Mobile Application

**Team:** DhruveX | **Written By:** TARUN V | **Problem Statement ID:** SIH26004  
*Move Early. Detect Early. Protect Every Step.*

---

## 📱 Tech Stack & Architecture

- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** Riverpod 2.x
- **Routing:** GoRouter
- **Bluetooth:** `flutter_blue_plus` with Demo BLE Simulation fallback
- **Offline Storage:** SQLite (`sqflite`) + Hardware Keystore (`flutter_secure_storage`)
- **Visuals & Charts:** `fl_chart` for real-time dual-IMU biomechanics streaming
- **Reporting:** `printing` & `pdf` for offline clinical summary PDF generation

---

## 🚀 Setup & Execution Instructions

### 1. Prerequisites
- Flutter SDK (>= 3.2.0)
- Android Studio / Android SDK (Target SDK 34)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment
```bash
cp .env.example .env
```

### 4. Run Application
```bash
flutter run
```

---

## 🛠️ Build APK Commands

### Debug APK (For Testing & Sideloading):
```bash
flutter build apk --debug
```
*Generated Output Path:* `build/app/outputs/flutter-apk/app-debug.apk`

### Universal Release APK:
```bash
flutter build apk --release
```
*Generated Output Path:* `build/app/outputs/flutter-apk/app-release.apk`

### Architecture Split APKs (Smaller download sizes for ARM64 / ARMv7):
```bash
flutter build apk --split-per-abi --release
```

### Google Play App Bundle (AAB):
```bash
flutter build appbundle --release
```

---

## 🧪 Run Automated Flutter Tests

```bash
flutter test
```
