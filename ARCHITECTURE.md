# Aura – System Architecture (Flutter)

**Version:** 2.0  
**Last Updated:** 2026-05-14  
**Target:** Flutter 3.27+, Android 15+, iOS 18+

## 1. Overview

Aura is a **privacy‑first, offline‑only** music player built with Flutter for true cross‑platform deployment. It combines an audiophile‑grade C++ audio engine, an intelligent local recommendation system, and a stunning “Liquid Material” UI that adapts dynamically to album art and system themes. All business logic is shared via Dart, while the heavy audio processing resides in a platform‑agnostic C++ library exposed through FFI.

---

## 2. High‑Level Architecture
┌──────────────────────────────────────────────────────┐
│ Flutter UI Layer │
│ - Liquid Glass Design System (Custom Widgets) │
│ - Dynamic Theming (Material You + Album Art) │
│ - Screens: Onboarding, Library, Player, Stats, │
│ Settings, Widgets (Home/Lock screen via │
│ home_widget / widget_extension plugins) │
├──────────────────────────────────────────────────────┤
│ State Management (Riverpod 2.x) │
│ - Unidirectional data flow (StateNotifier, │
│ AsyncNotifier) │
│ - Providers for Playback, Library, Shuffle, Mixes, │
│ Stats, Settings │
├──────────────────────────────────────────────────────┤
│ Domain Layer (Pure Dart) │
│ Use Cases (interactors): │
│ - PlaybackOrchestrator, IntelliShuffleEngine, │
│ SmartMixGenerator, DuplicateDetector, │
│ StatsCalculator │
│ Entities: Track, Album, Artist, Playlist, │
│ PlaybackState, ShuffleConfig │
├──────────────────────────────────────────────────────┤
│ Data Layer (Dart) │
│ Repository Implementations: │
│ - LocalMusicRepo (sqflite + path_provider) │
│ - BehaviorRepo (drift or floor for SQLite) │
│ - PlaylistRepo, SettingsRepo (shared_preferences │
│ with encryption) │
│ - FileScanner (uses platform channels to query │
│ MediaStore on Android / MPMediaQuery on iOS) │
├──────────────────────────────────────────────────────┤
│ C++ Core Engine (dart:ffi) │
│ - AudioEngine (FFmpeg‑based player, 64‑bit float │
│ DSP, gapless, parametric EQ, ReplayGain) │
│ - AudioAnalyzer (chromaprint, essentia‑like feature │
│ extraction) │
│ - IntelliShuffle (constrained weighted random │
│ permutation) │
│ - AudioFingerprinter (Chromaprint) │
├──────────────────────────────────────────────────────┤
│ Platform Services (via Plugins) │
│ - audio_session, just_audio (fallback) │
│ - flutter_local_notifications │
│ - home_widget (Android/iOS widgets) │
│ - media_store (Android MediaStore) / │
│ ios_media_library (custom plugin) │
│ - carplay / android_auto (future Pro) │
└──────────────────────────────────────────────────────┘
---

## 3. Technology Stack

| Layer               | Technology                                       |
|---------------------|--------------------------------------------------|
| UI Framework        | Flutter 3.27+ (Dart 3.6)                         |
| State Management    | Riverpod 2.x (with code generation)              |
| Local Database      | Drift (SQLite) for behavior, playlists, metadata |
| Audio Playback      | Custom C++ engine via `dart:ffi`                 |
| Audio Analysis      | C++ library (Chromaprint, Essentia) via FFI      |
| Platform Channels   | MethodChannel for MediaStore, MPMediaQuery       |
| Notifications       | flutter_local_notifications (local only)         |
| Widgets             | home_widget + widget_extension (iOS)             |
| Car Integration     | flutter_carplay (future), android_auto (future)  |
| Build & CI/CD       | Antigravity platform, Fastlane, GitHub Actions   |

---

## 4. Core Module Details (Flutter Adaptations)

### 4.1 Audio Engine Integration
- The C++ engine is compiled as a shared library (`.so` / `.dylib`) and loaded via `dart:ffi`.
- Dart bindings generated with `ffigen`.
- A thin Dart wrapper (`AudioEngine`) exposes methods: `play`, `pause`, `seek`, `setEqBand`, etc.
- The engine emits playback state and position via callback ports; translated into Riverpod state.

### 4.2 Library & Metadata
- On Android, `MediaStore` is queried via a platform channel to get all audio files.
- On iOS, `MPMediaQuery` is used (custom plugin).
- File system scanning (for folders not indexed) is performed with `path_provider` + Dart `io`.
- Metadata extracted with `flutter_media_metadata` (or custom C++ taglib via FFI).
- Results stored in a Drift database.

### 4.3 IntelliShuffle Engine
- Implemented as a pure Dart class `IntelliShuffleEngine`, with configuration and state.
- It interacts with the behavior database to get play counts, skips, ratings.
- Generates a shuffled list of track IDs; persists state to SQLite.
- For extremely large libraries, the weighted sampling uses pre‑computed cumulative weights and binary search.

### 4.4 Smart Mix Generator
- Dart implementation using the audio features extracted by the C++ analyzer (stored in DB).
- Clustering via k‑means (custom or using `ml_linalg` package) to form taste clusters.
- Daily generation triggered by a `WorkManager`-like plugin (`workmanager` for Android, `BGTaskScheduler` for iOS via plugin).
- Generated playlists stored as regular playlists with a special flag.

### 4.5 Statistics & Insights
- Play events recorded locally: track_id, timestamp, duration_played, skipped, rating.
- Aggregated daily/weekly/monthly using Drift queries.
- CSV export via Dart `csv` package.
- Shareable image cards generated with `screenshot` package (or custom painting).

### 4.6 Widgets & Notifications
- **Android Widget**: Using `home_widget` plugin; sends data from Flutter via method channel.
- **iOS Widget**: `widget_extension` (SwiftUI) with data shared via UserDefaults (app group).
- **Notifications**: `flutter_local_notifications` for playback controls and daily alerts.

---

## 5. Privacy & Permissions

- No internet permission declared.
- Android: `READ_MEDIA_AUDIO` (API 33+) or `READ_EXTERNAL_STORAGE` (older). iOS: `NSAppleMusicUsageDescription`.
- All processing on‑device. Database encrypted with `flutter_secure_storage` for keys.

---

## 6. Testing & CI

- Unit tests for domain and data layers (pure Dart).
- Widget tests with `flutter_test` and golden image tests.
- Integration tests for platform channels and audio engine.
- Builds automated via Antigravity pipelines.

---

## 7. Antigravity Integration

Antigravity will serve as the build and deployment orchestrator. The Flutter project is configured with flavors (`dev`, `prod`). Antigravity’s AI‑driven code generation can consume the design prompts and produce initial UI widgets, which are then refined manually. The platform also manages signing, distribution, and over‑the‑air updates for the Pro features.
