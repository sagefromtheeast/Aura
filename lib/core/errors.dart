// lib/core/errors.dart
// Aura — Domain-level error hierarchy (no external deps, pure Dart).

/// Base for all Aura application errors.
sealed class AuraError implements Exception {
  const AuraError(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (cause: $cause)' : ''}';
}

// ── Audio Engine Errors ───────────────────────────────────────────────────────

/// Thrown when the C++ audio engine fails to initialise (FFI load failure,
/// missing .so/.dylib, or native init() returned non-zero).
final class AudioEngineInitError extends AuraError {
  const AudioEngineInitError(super.message, {super.cause});
}

/// Thrown when loadTrack() fails (file not found, unsupported codec, etc.).
final class TrackLoadError extends AuraError {
  const TrackLoadError(this.trackPath, super.message, {super.cause});
  final String trackPath;
}

/// Thrown when a seek goes out of bounds.
final class SeekOutOfBoundsError extends AuraError {
  const SeekOutOfBoundsError(this.positionMs, this.durationMs)
      : super('Seek $positionMs ms exceeds track duration $durationMs ms');
  final int positionMs;
  final int durationMs;
}

// ── Library / Scanner Errors ──────────────────────────────────────────────────

/// Thrown when the platform channel for MediaStore/MPMediaQuery fails.
final class FileScanError extends AuraError {
  const FileScanError(super.message, {super.cause});
}

/// Thrown when a required file system permission is denied.
final class PermissionDeniedError extends AuraError {
  const PermissionDeniedError(this.permission)
      : super('Permission denied: $permission');
  final String permission;
}

// ── Database Errors ───────────────────────────────────────────────────────────

/// Wraps unexpected Drift / SQLite exceptions.
final class DatabaseError extends AuraError {
  const DatabaseError(super.message, {super.cause});
}

/// Thrown when a required entity is not found in the DB.
final class EntityNotFoundError extends AuraError {
  const EntityNotFoundError(String entityType, String id)
      : super('$entityType with id=$id not found');
}

// ── Shuffle / Mix Errors ──────────────────────────────────────────────────────

/// Thrown when IntelliShuffleEngine has no tracks to shuffle.
final class EmptyLibraryError extends AuraError {
  const EmptyLibraryError() : super('Cannot shuffle an empty library');
}

/// Thrown when SmartMixGenerator cannot produce a playlist (e.g. no features).
final class MixGenerationError extends AuraError {
  const MixGenerationError(super.message, {super.cause});
}

// ── Duplicate Detection Errors ────────────────────────────────────────────────

/// Thrown when the C++ fingerprinter is unavailable and the caller required it.
final class FingerprintUnavailableError extends AuraError {
  const FingerprintUnavailableError()
      : super('C++ fingerprinter not yet linked (Sprint 2)');
}
