# Aura 🎵 ✨

> **The Intelligent Music Companion.** A privacy-first, offline-only music player built with Flutter 3.35+, Drift SQLite, and an audiophile-grade C++ audio engine via Dart FFI.

[![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## 🌟 Core Pillars & Privacy Invariants

Aura is designed around a zero-compromise **offline and privacy-first** architecture:
- 🚫 **Zero Internet Dependency**: No network permissions are declared or requested.
- 🔒 **100% On-Device Processing**: All playback analysis, playlist clustering, and listening habit statistics execute entirely locally on your machine or mobile device.
- 💎 **Liquid Glass UI**: A fluid, glassmorphic design system adhering to strict 8-point grid ergonomics, dynamic color extraction (Material You / iOS Fluid Glass), and delightful micro-interactions.

---

## 🏗️ Clean Architecture Setup

```
┌────────────────────────────────────────────────────────┐
│ UI Layer (Flutter 3.35+ / Dart 3.6)                    │
│ • Liquid Glass System • Dynamic Colors • Thumb-Zone UI │
├────────────────────────────────────────────────────────┤
│ State Management (Riverpod 2.x)                        │
│ • Unidirectional reactive data streams & controllers   │
├────────────────────────────────────────────────────────┤
│ Domain Layer (Pure Dart)                               │
│ • Entities (freezed) • Interfaces • Intelligent Engines│
├────────────────────────────────────────────────────────┤
│ Data Layer (Drift / SQLite)                            │
│ • WAL mode storage • Non-destructive migrations        │
├────────────────────────────────────────────────────────┤
│ C++ Audio Engine (dart:ffi & NativeCallable)           │
│ • 64-bit DSP • Parametric EQ • Chromaprint Hashing     │
└────────────────────────────────────────────────────────┘
```

---

## ✨ Key Features & Intelligent Algorithms

### 1. **IntelliShuffle™ Engine**
Unlike standard randomizers that repeat artists or skip favorite tracks, Aura utilizes a custom implementation of **A-Res (Weighted Reservoir Sampling)** ($O(n \log n)$ complexity). Tracks are dynamically scored based on replay stats, skip penalty, and user ratings while enforcing customizable spacing guarantees (e.g., minimum 3 songs between identical artists).

### 2. **Offline Smart Mixes ($k$-Means++ Clustering)**
Aura synthesizes cohesive listening journeys (Morning, Workout, Focus, Chill, Evening) without communicating with external streaming servers. It extracts 6-dimensional audio feature vectors (tempo, energy, valence, danceability, loudness, acousticness) and categorizes your local library using local $k$-means++ clustering ($k=5$).

### 3. **Three-Path Duplicate Detector**
Keep your local digital collection clean with a three-tier deduplication engine:
- **Exact Path**: Hash-based composite matching on normalized titles, artists, and duration intervals ($\pm 1$s tolerance).
- **Fuzzy Path**: Jaro-Winkler string similarity (threshold $\ge 0.75$) evaluated across localized duration windows ($\pm 2$s) to prune $O(n^2)$ search spaces down to $O(n \times \text{bucket\_size})$.
- **Acoustic Path**: Chromaprint audio fingerprinting (via C++ FFI) to identify duplicate audio recordings regardless of file metadata discrepancies.

### 4. **Audiophile C++ Engine (FFI)**
Heavy digital signal processing lives entirely outside the Dart garbage collector. Communication occurs via safe Dart 3 FFI bindings and asynchronous `NativeCallable` listener ports, ensuring graphical rendering remains locked at a fluid 60fps/120fps on modern iOS and Android displays.

---

## 🚀 Getting Started & Testing

### Prerequisites
- **Flutter SDK**: `>=3.35.0`
- **Dart SDK**: `>=3.6.0`
- **Platform Tooling**: Android Studio (AGP 8+) or Xcode 16+ (for iOS builds)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Code Generation (Drift, Freezed & Riverpod)
If you make modifications to database schemas or domain entities, regenerate code bindings:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Static Analysis
Verify that all source code adheres to strict zero-slop architectural guidelines and lint rules:
```bash
flutter analyze
```

### 4. Run Automated Test Suites
Execute all domain algorithm unit tests and widget lifecycle verifications:
```bash
flutter test
```

---

## 📜 License & Acknowledgments

Built with precision and passion for offline music enthusiasts. Licensed under the MIT License.
