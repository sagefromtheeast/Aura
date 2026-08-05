# Instructions for Claude (Opus 4.6, High Capability) – Flutter Focus

You are Claude, tasked with building the **core intelligence** of Aura, now a Flutter app with a shared C++ engine. Use the attached documents: **Architecture.md (Flutter)**, **PRD.md (Flutter)**, and **Design.md**.

## Your Focus Areas (Adapted for Flutter)

### 1. IntelliShuffle Algorithm (Dart)
Implement the IntelliShuffle engine in pure **Dart** (can later be migrated to C++ if performance demands). The class `IntelliShuffleEngine` should:
- Accept `ShuffleConfig` (artist spacing, recency, bias, discovery).
- Use the behavior database (via a repository interface) to fetch play counts, skip history, ratings.
- Generate a non‑repeating, constrained permutation of track IDs.
- Provide methods: `nextTrack()`, `skip()`, `onTrackFinished()`, `addTracks()`.
- Persist its internal state to JSON (for SQLite storage) so it survives app restarts.
- Time complexity must be O(n log n) for initial generation, O(log n) per next track.

Provide a clean Dart class with unit tests sketch.

### 2. Smart Mix Generator (Dart)
Design a `SmartMixGenerator` that uses audio features (stored in Drift DB, pre‑extracted by C++) and user behavior to create daily mixes.
- Implement anchor selection: pick tracks with high play counts that represent different clusters.
- Cluster tracks using a simplified k‑means (or DBSCAN) based on feature vectors.
- Generate playlists of 25‑50 tracks per mix, ensuring variety constraints.
- Schedule generation with `workmanager` (Android) and iOS background tasks (via a platform channel or using `BGTaskScheduler` plugin).
- Write the logic for time‑based mood adjustment (morning = higher energy, evening = chill).

### 3. Duplicate Detection (Dart + C++ glue)
Create a `DuplicateDetector` service in Dart that:
- Exact match using composite key (title+artist+duration).
- Fuzzy match using `string_similarity` package or custom Levenshtein.
- Calls the C++ fingerprinter via FFI for the deep path.
- Provide a workflow for the resolution wizard UI.

### 4. Audio Engine FFI Interface (Dart + C++)
Define the Dart FFI bindings for the audio engine. Write the `.dart` class that loads the library, defines native function signatures, and wraps them in a clean API.
- Functions: `init()`, `loadTrack(path)`, `play()`, `pause()`, `seek(pos)`, `setEqBand(band, gain, q)`, etc.
- Ensure the callback mechanism for position updates works efficiently (use `NativeCallable`).

### Coding Standards
- Dart 3.6, null safety, strong typing.
- Use `freezed` for immutable data classes.
- All processing on‑device; no network calls.
- Include comments linking back to the PRD requirements.

**Output:** Provide Dart files with thorough explanations. Assume the UI is separate; focus on performance and correctness.