# Aura 🎵 ✨

> **The Intelligent Music Companion.** A privacy-first, offline-only audiophile music player built with Flutter 3.32+, Riverpod 2.x, Drift SQLite, and an ultra-low latency C++ audio engine via Dart FFI.

[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## 🌟 Core Pillars & Privacy Invariants

Aura is designed around a zero-compromise **offline and privacy-first** architecture:
- 🚫 **Zero Internet Dependency**: No network tracking, cloud servers, or telemetry endpoints exist. Your music library remains solely on your local device.
- 🔒 **100% On-Device Processing**: All playback analysis, feature vector clustering, deduplication, and listening habit statistics execute entirely within your device's secure local sandbox.
- 💎 **Liquid Glass UI**: A fluid, glassmorphic design system adhering to strict 8-point spatial grid ergonomics, dynamic color extraction (Material You on Android / iOS Fluid Glass), single-layer blur rendering for peak 60fps/120fps graphics performance, and delightful spring-curved micro-interactions.

---

## 🏗️ Clean Architecture Setup

```
┌────────────────────────────────────────────────────────┐
│ UI & Feature Layer (Flutter 3.32+ / Dart 3.8)          │
│ • Liquid Glass System • Dynamic Colors • Thumb-Zone UI │
│ • Interactive Modal Suite • AI Smart Mix Dashboards     │
├────────────────────────────────────────────────────────┤
│ State Management & Orchestration (Riverpod 2.x)        │
│ • Unidirectional reactive data streams & controllers   │
│ • PlaybackOrchestrator • Async Drift Stream Synchronization
├────────────────────────────────────────────────────────┤
│ Domain Layer (Pure Dart / Immutable Freezed)           │
│ • Entities • A-Res IntelliShuffle • k-Means Clustering │
├────────────────────────────────────────────────────────┤
│ Data & Persistence Layer (Drift / SQLite / WAL Mode)   │
│ • Non-destructive migrations • Encrypted local storage │
├────────────────────────────────────────────────────────┤
│ Audiophile C++ Audio Engine (dart:ffi & NativeCallable)│
│ • 64-bit Floating DSP • 3D Spatial Soundfield EQ       │
│ • Chromaprint Hashing • Ring-Buffer Gapless Playback   │
└────────────────────────────────────────────────────────┘
```

---

## 📱 Comprehensive UI & Feature Showcase

Aura includes a complete, production-ready implementation across all core audio modules:

### 🎧 Now Playing & Liquid Glass Audio Suite
The primary playback view extracts harmonious color palettes from album artwork in real time and provides an interactive toolbar connected to five specialized audiophile control sheets:
1. **Up Next & Interactive Queue**: Reorderable play queue with swipe-to-dismiss gestures and instant track clearing.
2. **Synchronized Lyrics Viewer**: Timed LRC real-time word/line highlighting with interactive click-to-seek and smooth scroll animations.
3. **Sleep Timer & Audio Fade**: Programmable duration timers and stop-after-track options featuring a gentle 60-second acoustic fade-out.
4. **Audiophile DSP & 3D Spatial Enhancer**: Deep soundfield parameter controls including 3D spatial width, sub-bass punch (60 Hz), vocal air (3.5 kHz), binaural headphone crossfeed guards against listening fatigue, 384kHz/32-bit floating sinc upsampling, and zero-latency gapless ring buffering.
5. **Wireless Cast & Output Selector**: Latency-aware sink selection switching effortlessly between Internal Hi-Res PCM DACs, Bluetooth 5.3 LDAC/aptX HD endpoints, and UPnP/DLNA home studio network speakers.

### 🧠 On-Device AI & Smart Library
- **IntelliShuffle™ Engine**: Powered by **A-Res (Weighted Reservoir Sampling)** ($O(n \log n)$ complexity). Tracks are dynamically scored based on completion ratios, skip penalties, and favorite ratings while enforcing strict artist spacing guarantees (e.g., minimum 2-3 songs between identical artist repetitions).
- **Offline Smart Mixes ($k$-Means++ Clustering)**: Synthesizes immersive listening journeys (*Morning Awakening*, *Deep Focus Flow*, *High-Octane Workout*, *Midnight Chillout*) completely offline. Extracts 6-dimensional audio feature vectors (tempo, energy, valence, danceability, loudness, acousticness) and routes to a dedicated **Smart Mix Detail & Infinite Mixtape Screen** featuring real-time radar analysis and endless vector similarity track weaving.
- **Directory Folder Browser**: For traditional digital collectors, navigate physical device storage trees with breadcrumb tracking and whole-folder queue playback.

### 🧹 Three-Path Duplicate Detection & Hygiene
Keep your high-resolution audio repository clean with a three-tier deduplication engine:
- **Exact Path**: Hash-based composite matching on normalized titles, artists, and duration intervals ($\pm 1$s tolerance), automatically preserving the highest-bitrate recording as the primary keeper.
- **Fuzzy Path**: Jaro-Winkler string similarity (threshold $\ge 0.75$) evaluated across localized duration windows ($\pm 2$s) to prune $O(n^2)$ search spaces down to rapid $O(n \times \text{bucket\_size})$ evaluations.
- **Acoustic Path**: Chromaprint audio fingerprinting (via C++ FFI) to identify duplicate audio recordings regardless of file metadata discrepancies or ID3 tag variations.

### 📊 Offline Telemetry & CSV History Export
- **Listening Stats & Analytics**: Review completion stats, replay distributions, and high-resolution lossless audio shares without a single byte of data leaving your machine.
- **Chronological Telemetry Logs**: Dive into exact timestamp logs displaying file format badges (FLAC, DSD, ALAC, WAV, MP3), sample rates (up to 192 kHz), and bitrate statistics.
- **One-Tap CSV Export**: Export complete historical listening telemetry to a local `.csv` file in your application documents directory for personal archiving or spreadsheet analysis.

---

## 🚀 Getting Started & Development Setup

### Prerequisites
- **Flutter SDK**: `>=3.32.0` (verified on 3.35.7 / Dart 3.9.2)
- **Dart SDK**: `>=3.6.0`
- **Platform Tooling**: Android Studio (AGP 8+, NDK enabled) or Xcode 16+ (for iOS builds)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Code Generation (Drift, Freezed & Riverpod)
If you make modifications to database schemas, immutable entities, or providers, regenerate code bindings:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Static Analysis
Verify that all source code adheres to strict zero-slop architectural guidelines, accessible semantics, and lint rules:
```bash
flutter analyze
```

### 4. Run Automated Test Suites
Execute all domain algorithm unit tests, duplicate detection edge-case assertions, and UI widget lifecycle verifications:
```bash
flutter test
```

---

## 📜 License & Acknowledgments

Built with engineering precision and architectural elegance for offline audiophiles and privacy enthusiasts. Licensed under the MIT License.
