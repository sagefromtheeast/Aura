// lib/domain/duplicate_detector/fingerprint_math.dart
// Aura — Chromaprint fingerprint comparison.

/// Pure-Dart bit error rate between two raw Chromaprint fingerprints.
///
/// Mirrors `aura_fingerprint_bit_error_rate` in the C++ engine, and is used
/// whenever the native library is unavailable (tests, desktop, a build without
/// the engine). Returns 1.0 — maximally different — when either side is empty.
///
/// It lives in the domain layer, not next to the FFI bindings, so the duplicate
/// detector can compare fingerprints without importing `dart:ffi`.
double fingerprintBitErrorRateDart(List<int> a, List<int> b) {
  if (a.isEmpty || b.isEmpty) return 1.0;

  // Compare the overlapping prefix; a length mismatch just means one file was
  // shorter than the other.
  final n = a.length < b.length ? a.length : b.length;
  var differing = 0;
  for (var i = 0; i < n; i++) {
    var x = (a[i] ^ b[i]) & 0xFFFFFFFF;
    // Kernighan's popcount: one iteration per set bit.
    while (x != 0) {
      x &= x - 1;
      differing++;
    }
  }
  return differing / (n * 32);
}
