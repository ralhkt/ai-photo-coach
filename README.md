# AI Photo Coach

On-device AI photography coach for iOS and Android, built with Flutter.

## Phase 1 — Project Setup + Camera + Basic Overlays

This phase delivers a runnable foundation:

- Flutter project scaffold (v3.0 structure: `core/`, `features/`, `models/`)
- Riverpod state management
- Real-time rear camera preview (`camera` plugin)
- Non-intrusive composition overlays:
  - Rule of Thirds
  - Golden Ratio
  - Center
  - Diagonal
- English + Traditional Chinese UI strings
- Camera permission handling (Android + iOS)

## Reference Photo Analysis + Guided Frame (New)

Upload a reference image (e.g. portrait post) and get on-device analysis:

1. **Upload** — gallery or camera reference photo
2. **Analyze** — brightness, subject region, scene type, composition
3. **Recommend** — camera framing / exposure / distance / angle hints
4. **Generate frame** — social post crop guides (4:5, 9:16, 1:1, 16:9, 3:4)
5. **Guided shoot** — live camera with frame mask + subject zone + composition overlay

## Requirements

- Flutter **3.24+**
- Dart **3.5+**
- Xcode 15+ (iOS, macOS only)
- Android Studio / SDK 24+ (Android)

> **Note:** Camera preview requires a physical iOS or Android device. Desktop/web targets are not supported for this phase.

## Project Structure

```
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/
│   ├── l10n/
│   └── theme/
├── features/
│   ├── camera/
│   │   ├── presentation/
│   │   ├── providers/
│   │   └── services/
│   └── overlays/
│       ├── presentation/
│       └── providers/
└── models/
```

## Getting Started

### 1. Install Flutter

Follow the official guide: https://docs.flutter.dev/get-started/install

Verify:

```bash
flutter --version
flutter doctor
```

### 2. Install dependencies

```bash
cd ai-photo-coach
flutter pub get
```

If you modify ARB files, regenerate localizations:

```bash
flutter gen-l10n
```

### 3. Run on device

**Android**

```bash
flutter devices
flutter run -d <android-device-id>
```

**iOS** (macOS + Xcode)

```bash
cd ios && pod install && cd ..
flutter run -d <ios-device-id>
```

## Usage

### Reference-guided shooting (recommended)

1. Open app → **分析參考相片**
2. Pick a portrait post / reference image
3. Review analysis result and choose frame template (e.g. Portrait Post 4:5)
4. Tap **開始引導拍攝**
5. Align subject inside dashed zone; follow on-screen hints

### Free camera mode (iOS-style UI)

1. Open app → **開啟相機**
2. **Shutter** — large white capture button (bottom center)
3. **Gallery** — bottom-left thumbnail; tap last shot, long-press to open gallery
4. **Flip camera** — bottom-right switch front/back
5. **Flash** — top bar cycle: OFF → AUTO → ON → TORCH
6. **Pinch** — zoom in/out on preview
7. Toggle grid overlay and cycle composition modes
8. **HDR** — toggle in options strip; badge shown at top when on
9. **Timer** — cycle off / 3s / 10s; countdown overlay before capture
10. **Burst** — hold shutter for rapid capture; swipe through results
11. **AE/AF Lock** — tap to focus, long-press preview to lock, or use lock chip
12. **Pinch zoom** — two-finger zoom on preview

## Tests

```bash
flutter test
```

## Permissions

| Platform | Config |
|----------|--------|
| Android | `CAMERA` in `AndroidManifest.xml` |
| iOS | `NSCameraUsageDescription` in `Info.plist` |

## Phase 2 — AR + Scene Stabilization

Delivered in this phase:

- **pHash scene monitor** — samples camera frames (~800ms) and detects stable vs changed scenes
- **AR plane hints** — native MethodChannel + EventChannel (`com.aiphotocoach.app/ar`)
  - Android: ARCore horizontal plane polling
  - iOS: ARKit `ARWorldTrackingConfiguration` plane detection
- **Horizon overlay** — accelerometer-based level guide on camera preview
- **Status chip** — AR plane state + scene stability shown on camera screens
- **Lifecycle wiring** — `CameraSessionLifecycle` starts/stops monitor + AR with camera

### Phase 2 UI

On camera and guided-shoot screens you will see:

- Yellow horizon line when the device is level
- Top-left chip: plane detection status + scene lock state

### Known limitations

- ARCore/ARKit sessions may conflict with the Flutter `camera` plugin on some devices (AR falls back to accelerometer-only horizon guide)
- Scene stability uses lightweight heuristics, not ML — good for skipping redundant refreshes, not pixel-perfect scene matching
- iOS project folder is minimal; run `flutter create .` on macOS if Xcode project files are missing before building for iOS

## Phase 3 — On-Device ML (ML Kit)

Delivered in this phase:

- **ML Kit face detection** — refines portrait subject bounds from facial geometry
- **ML Kit pose detection** — maps head / shoulder / torso / hip guides from body landmarks
- **ML Kit image labeling** — improves auto scene classification and aesthetic hints
- **Hybrid pipeline** — ML results merge with existing heuristics; desktop/CI uses fallback
- **Analysis UI** — shows ML source, face count, pose status, inference time on result screen

Architecture:

- `lib/features/ml/services/vision_analyzer.dart` — abstraction
- `lib/features/ml/services/ml_kit_vision_analyzer.dart` — Android/iOS on-device inference
- `lib/features/ml/services/heuristic_vision_analyzer.dart` — Windows/web/test fallback
- Wired into `ImageAnalyzerService` via `visionAnalyzerProvider`

### Run on Android emulator

```powershell
cd C:\Users\ralhk\ai-photo-coach
flutter pub get
flutter run -d emulator-5554
```

Upload a portrait reference with **人像** scene — analysis screen should show **ML Kit (on-device)** when running on a real device or emulator.

## Phase 4 — Onboarding, Settings, Session Summary

Delivered in this phase:

- **Onboarding** — 3-step first-launch walkthrough (skippable), persisted via `shared_preferences`
- **Settings** — language (繁中 / 简中 / EN), voice guidance toggle, prompt strength (low / medium / high)
- **Session tracking** — free and guided camera sessions record captures locally
- **Session summary** — after shooting, on-device analysis of session photos with best-shot highlight and tips
- **Close-camera dialog** — prompts to view summary or discard when leaving mid-session

Architecture:

- `lib/core/settings/` — `SettingsRepository` + `appSettingsProvider`
- `lib/features/onboarding/` — first-run UI
- `lib/features/settings/` — settings screen (home → gear icon)
- `lib/features/session/` — `ShootSessionNotifier`, `SessionSummaryBuilder`, summary UI

### Reset onboarding (dev)

Clear app data on the device/emulator, or delete SharedPreferences keys in debug.

## Phase 5 — Testing + Optimization

Delivered in this phase:

- **Quick session analysis** — downscaled photos + NIMA-like heuristic scorer (< 120 ms/photo target)
- **Power save mode** — settings toggle: slower pHash sampling, AR off, skip ML in quick scorer
- **Performance tracker** — records inference and summary timings against MVP budgets
- **Battery session tracker** — measures camera-session battery delta (MVP: < 7% per 10 min)
- **Diagnostics screen** — settings → Performance diagnostics (budgets, benchmark, last battery report)

Architecture:

- `lib/core/performance/` — `PerformanceTracker`, `BatterySessionTracker`, budgets
- `lib/features/session/services/quick_photo_scorer.dart` — optimized batch scoring
- `lib/features/ml/services/nima_like_scorer.dart` — NIMA-inspired score without TFLite asset
- `lib/features/diagnostics/` — on-device performance UI

### Device testing checklist

1. Enable **Power save** off → shoot 10 min guided session → check diagnostics battery report.
2. Capture 8+ photos → finish session → confirm summary progress and analysis time.
3. Compare summary speed with power save on vs off.
4. Verify AR chip hidden/disabled when power save is on.

### Optional future work

- Bundle quantized NIMA TFLite asset for Android/iOS when model file is available.

## License

Private MVP — not for public distribution yet.