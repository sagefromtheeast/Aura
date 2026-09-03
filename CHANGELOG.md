# Changelog

All notable changes to the **Aura** music player project are documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) using conventional commit prefixes.

---

## [v1.15.1] - 2026-09-03
### Fixed
- Refined Now Playing background album art blur overlay scrim for text contrast across light and dark themes.
- Added physical depth inner shadow styling to primary play/pause FAB.
- Resolved vertical drag gesture conflicts between synced lyrics scrolling and modal sheet dismissal.
- *Commit:* `ecb2741`

## [v1.15.0] - 2026-09-03
### Added
- Vertical swipe down to dismiss Now Playing player; horizontal artwork swipes for skipping tracks.
- Drag-to-reorder playback queue with immediate audio engine playlist synchronization.
- Real-time time-synchronized LRC lyrics sheet with auto-scroll highlighting active lines.
- *Commit:* `a424e1e`

## [v1.14.0] - 2026-09-03
### Added
- Dynamic album artwork background blur, volume slider, and interactive scrubber in Now Playing.
- Detailed `TrackInfoSheet` displaying audio bitrate, sample rate, codec, file size, and file path.
- Queue sheet integration accessible directly from player controls.
- *Commit:* `6f11199`

## [v1.13.0] - 2026-09-03
### Added
- Web platform support with Progressive Web App (PWA) manifest and service worker configuration.
- Maskable PWA icon assets (`Icon-192.png`, `Icon-512.png`, maskable variants, favicon).
- *Commit:* `d072b9d`

## [v1.12.3] - 2026-09-03
### Performance
- Surgically refactored `ScanningScreen` to throttle UI state updates, completely eliminating main thread frame drops during large 10,000+ track library scans.
- *Commit:* `d833465`

## [v1.12.2] - 2026-09-03
### Fixed
- Fixed edge case where `ScanningScreen` stalled at 100% without transitioning to `CompletionScreen`.
- *Commit:* `7e1c7c0`

## [v1.12.1] - 2026-09-03
### Fixed
- Implemented `RefreshIndicator` pull-to-refresh on album and artist detail views.
- Fine-tuned swipe dismissal thresholds and haptic triggers on `TrackTile`.
- *Commit:* `1c03d36`

## [v1.12.0] - 2026-09-03
### Added
- Complete artist discography wiring connecting albums to individual album detail screens.
- Responsive grid layout child aspect ratios and padding optimizations.
- Smoothed sliver header transitions.
- *Commit:* `d7d6de8`

## [v1.11.0] - 2026-09-03
### Added
- Dedicated Album and Artist detail screens with sliver headers and dominant color gradients.
- Reusable `TrackTile` with swipe actions (favorite, add to queue) and popup context menu.
- `NowPlayingIndicator` animated 3-bar equalizer visualizing active audio playback.
- `HeroAlbumArt` transitions.
- *Commit:* `e0215ca`

## [v1.10.1] - 2026-09-03
### Changed
- Refreshed app launcher icons across all Android mipmap densities and iOS asset sets via `flutter_launcher_icons`.
- *Commit:* `b532838`

## [v1.10.0] - 2026-09-03
### Added
- Library sub-views for Albums, Artists, Folders, and Playlists.
- Mock data provider `dummy_library_data.dart` for visual testing and design validation.
- *Commit:* `411b9f9`

## [v1.9.3] - 2026-09-03
### Fixed
- Resolved asynchronous `BuildContext` lint warnings across navigation flows.
- Migrated deprecated `Color.withOpacity()` to modern `Color.withValues(alpha: ...)`.
- *Commit:* `54467b0`

## [v1.9.2] - 2026-09-03
### Added
- `reduceMotion` accessibility support disabling particle/spring animations when requested by system settings.
- *Commit:* `dc902b4`

## [v1.9.1] - 2026-09-03
### Fixed
- Connected onboarding completion directly into `AppShell`.
- Resolved static analysis warnings.
- *Commit:* `06abfe6`

## [v1.9.0] - 2026-09-03
### Added
- Main navigation `AppShell` with persistent bottom navigation bar.
- Floating frosted `MiniPlayer` persistent across all tabs with progress indicator and playback controls.
- *Commit:* `0e90dd7`

## [v1.8.4] - 2026-09-03
### Fixed
- Resolved MSVC/Windows `min`/`max` preprocessor macro collision in `audio_engine.cpp` with `NOMINMAX`.
- *Commit:* `84a3bf2`

## [v1.8.3] - 2026-09-03
### Changed
- Configured development workflow skills via npx.
- *Commit:* `e82aae7`

## [v1.8.2] - 2026-09-03
### Fixed
- Added standard C library headers (`<stdlib.h>`, `<string.h>`) to native audio engine and removed redundant C++ strings.
- *Commit:* `7fb20f3`

## [v1.8.1] - 2026-09-03
### Fixed
- Updated header include paths in native CMake configuration for IDE analyzers.
- *Commit:* `e2d6091`

## [v1.8.0] - 2026-09-03
### Added
- Native C++ DSP feature extraction for tempo (BPM), spectral centroid, and RMS energy.
- Interactive playback control Android Home Widget using `home_widget`.
- *Commit:* `6723bac`

## [v1.7.0] - 2026-09-03
### Added
- Native Android `MediaStore` offline file scanner.
- Native iOS `MPMediaQuery` scanner with asynchronous artwork extraction.
- C++ FFI audio engine integration with Drift database.
- *Commit:* `9486aa6`

## [v1.6.0] - 2026-09-03
### Added
- Integrated low-latency C++ audio engine powered by `miniaudio`.
- Multi-format audio decoding (MP3, FLAC, WAV, AAC, OGG Vorbis).
- Dart FFI bindings for real-time play, pause, seek, and buffer management.
- *Commit:* `02520a8`

## [v1.5.3] - 2026-09-03
### Fixed
- Fixed native directory crawling and metadata ingestion in song scanner.
- Removed artificial paywalls; all features 100% unlocked offline.
- *Commit:* `5d9a89f`

## [v1.5.2] - 2026-09-03
### Fixed
- Upgraded `workmanager` to 0.9.2 to resolve v1 embedding deprecation and duplicate class errors on Android.
- *Commit:* `19c62b5`

## [v1.5.1] - 2026-09-03
### Fixed
- Enabled Java core library desugaring in `build.gradle.kts`.
- Added defensive packaging exclusions (`META-INF/*.version`) to prevent APK ZIP central directory corruption.
- *Commit:* `0fd941d`

## [v1.5.0] - 2026-09-03
### Added
- Offline `AuraWrappedScreen` for personalized listening statistics and story cards.
- `IntelliShuffleSheet` tuning dashboard to adjust artist spacing, recency, and discovery bias.
- `PlaylistIoService` for M3U8 playlist import/export with unit test suite.
- `TagEditorSheet` for batch ID3 tag editing.
- *Commit:* `256468a`

## [v1.4.0] - 2026-09-03
### Added
- Batch ID3 metadata editor in Library screen.
- Offline M3U8 playlist export to local device storage.
- *Commit:* `3e8ba82`

## [v1.3.0] - 2026-09-03
### Added
- Complete reference design screen implementations.
- Comprehensive UI/UX gap analysis resolution and lint cleanup.
- *Commit:* `354c244`

## [v1.2.0] - 2026-09-03
### Added
- Implemented 10 missing deep navigation screens, sheets, and flows (Sprint 3).
- 100% unit and widget test pass rate.
- *Commit:* `f894420`

## [v1.1.0] - 2026-09-03
### Added
- Liquid Glass aesthetic with frosted `GlassCard` component and dynamic color extraction.
- Library views (Albums, Artists, Playlists).
- 10-band graphic equalizer with preset curves.
- Duplicate track cleaner wizard.
- Android Home Widget and rich media notifications.
- *Commit:* `8a18ff8`

## [v1.0.1] - 2026-09-03
### Changed
- Configured `.gitignore` to ignore internal documentation files.
- Refreshed `README.md` with system requirements and architecture.
- *Commit:* `bed8fb2`

## [v1.0.0] - 2026-09-03
### Added
- Initial architectural foundation for Aura (Sprint 1).
- Drift SQLite persistence layer for offline track, artist, album, and behavior data.
- C++ FFI audio engine bridge contracts.
- Privacy-first zero network permission enclave model.
- *Commit:* `be79e55`
