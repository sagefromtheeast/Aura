// lib/core/constants.dart
// Aura — App-wide constants
// PRD §7: Non-Functional Requirements

/// Default database version. Increment when adding/modifying Drift tables.
const int kDatabaseVersion = 1;

/// Name of the SQLite database file on disk.
const String kDatabaseName = 'aura.db';

/// Maximum number of tracks in a single Smart Mix playlist (PRD §6.4).
const int kSmartMixMaxTracks = 50;
const int kSmartMixMinTracks = 25;

/// Number of k-means clusters for mood-based mixing (Morning, Workout,
/// Chill, Focus, Evening). Maps to [MixMood] enum values.
const int kKMeansClusters = 5;

/// Max k-means iterations before forced convergence.
const int kKMeansMaxIterations = 50;

/// Convergence threshold for centroid movement (Euclidean distance).
const double kKMeansConvergenceThreshold = 1e-4;

/// Default IntelliShuffle artist-spacing (tracks between same-artist plays).
const int kDefaultArtistSpacing = 3;

/// PRD §7: shuffle generation must complete in <500ms for 50k songs.
/// Binary search gives O(log n); this constant is the performance budget hint.
const Duration kShuffleGenerationBudget = Duration(milliseconds: 500);

/// How long to retain playback history rows (for stats aggregation).
const Duration kHistoryRetentionDuration = Duration(days: 365);

/// Platform channel name for MediaStore / MPMediaQuery scanner.
const String kFileScannerChannel = 'com.aura/file_scanner';

/// Platform channel method: scan all audio files.
const String kScanAllAudioMethod = 'scanAllAudio';

/// Platform channel name for fingerprint (C++ bridge until FFI fully wired).
const String kFingerprintChannel = 'com.aura/fingerprint';

/// How many seconds of play count as a "complete" listen (for stats).
const double kListenCompletionRatio = 0.8;

/// Fuzzy duplicate similarity threshold (0.0–1.0).
/// Tracks scoring above this on Jaro-Winkler are considered duplicates.
const double kFuzzyDuplicateThreshold = 0.75;

/// Audio feature vector dimension (tempo, energy, valence, danceability,
/// loudness, acousticness). Must match DB schema.
const int kAudioFeatureDimension = 6;
