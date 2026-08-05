# Product Requirements Document – Aura (Flutter)

**Product:** Aura – The Intelligent Offline Music Player  
**Version:** 2.0  
**Platform:** Flutter 3.27+ (Android 15+, iOS 18+)  
**Status:** Final Draft  

## 1. Executive Summary

(Unchanged from original – see above. Adding platform specifics.)

Aura is built with **Flutter** to ensure a single codebase for both platforms, reducing maintenance and guaranteeing visual consistency. The use of a shared C++ audio engine via FFI allows audiophile‑grade performance without sacrificing platform‑specific optimizations.

## 2. Problem Statement

(Unchanged.)

## 3. Target Audience

(Unchanged.)

## 4. Goals & Success Metrics

| Goal | Metric |
|------|--------|
| High user activation | >80% complete onboarding & library scan |
| Daily engagement | 60% of users return within 48 hours |
| Smart feature adoption | 40% use Daily Mixes weekly |
| Premium conversion | 15% purchase Pro (advanced EQ, custom themes) |
| Crash‑free rate | >99.5% (tracked via optional opt‑in, anonymized) |
| Cross‑platform parity | UI and features identical on Android/iOS |

## 5. User Stories (MVP)

(Unchanged from original; all implemented in Flutter.)

## 6. Feature Set (Detailed)

### 6.1 Core Playback
- Support all major formats (MP3, AAC, FLAC, ALAC, DSD, WAV, etc.) via C++ engine.
- 64‑bit float DSP with 10‑band parametric EQ.
- Gapless playback, crossfade (0‑12s), ReplayGain, true hi‑res output.
- Cast support: Chromecast (via `dart_cast` package) / AirPlay (native AVRoutePickerView) – Pro feature.

### 6.2 Library & Management
- Folder and metadata browsing (Albums, Artists, Genres, Folders).
- Background file scanner with progress notification.
- Tag editor (single and batch) using C++ taglib.
- Duplicate detection (exact + fuzzy + fingerprinting) with resolution wizard.
- Import/export .m3u, .m3u8 playlists.

### 6.3 IntelliShuffle
- Non‑repeating full‑cycle shuffle with sliders for:
  - Artist spacing (0‑5 tracks)
  - Recency avoidance
  - Favorite bias
  - Discovery injection
- Persistent shuffle state survives restarts and library changes.

### 6.4 Smart Mixes (On‑Device AI)
- Daily Mixes (Morning, Workout, Chill, Focus, etc.)
- Mood‑based mixing using extracted audio features.
- “Infinite Mixtape” mode for continuous themed playback.
- Mix generation runs in background (Android WorkManager / iOS BGProcessingTask).

### 6.5 Statistics & Wrapped
- Dashboard with weekly/monthly listening stats.
- “Aura Wrapped” shareable story‑style cards.
- CSV export of play history.

### 6.6 UI/UX (Liquid Material)
- Flutter custom design system with glass morphism.
- Dynamic accent color extracted from album art (using `palette_generator` package).
- Material You theming on Android (dynamic_color plugin); custom on iOS.
- Fluid animations (springs, hero transitions).
- Home screen widgets (Android – Glance‑like via `home_widget`; iOS – WidgetKit via `widget_extension`).

### 6.7 Privacy
- Zero internet permission (optional for cast/radio).
- All data local, encrypted at rest.

## 7. Non‑Functional Requirements

- **Performance**: Library scan 20k songs < 2 min (background). Shuffle generation < 500ms for 50k songs.
- **Battery**: Background playback < 2% per hour.
- **Storage**: App binary < 60 MB (Flutter + C++ libs).
- **Accessibility**: Flutter’s accessibility tree well‑defined; support screen readers.

## 8. Release Phases

(Unchanged.)

## 9. Technical Dependencies & Plugins

| Plugin | Purpose |
|--------|---------|
| `drift` | Local database (SQLite) |
| `riverpod` | State management |
| `ffi` + `ffigen` | C++ bindings |
| `flutter_local_notifications` | Playback & reminder notifications |
| `home_widget` | Android home screen widget |
| `widget_extension` | iOS home screen widget |
| `palette_generator` | Extract colors from album art |
| `dynamic_color` | Material You theming |
| `path_provider` | File access |
| `permission_handler` | Manage audio permissions |
| `workmanager` | Background tasks (Android) |
| `flutter_background_service` | Keep audio alive in background |

---

## 10. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| FFI complexity / crashes | Thorough testing; fallback to `just_audio` if engine fails |
| Platform‑specific behavior | Isolate platform channels; extensive CI on both OS |
| Widget differences (Android vs iOS) | Use adaptive design; test on both with golden files |
| Background processing killed by OS | Use official plugins; keep service foreground when possible |
