// lib/domain/entities/camelot.dart
// Aura — Camelot wheel key compatibility (harmonic mixing).
//
// The wheel maps every key to a number 1-12 and a letter (A = minor,
// B = major). Two keys mix smoothly when they are the same, one step around
// the wheel, or the relative major/minor of each other.

/// A position on the Camelot wheel, e.g. 8A (A minor) or 8B (C major).
class CamelotKey {
  const CamelotKey(this.number, this.isMinor)
      : assert(number >= 1 && number <= 12);

  /// 1-12 around the wheel.
  final int number;

  /// A = minor, B = major.
  final bool isMinor;

  String get letter => isMinor ? 'A' : 'B';

  /// Standard notation, e.g. "8A".
  String get label => '$number$letter';

  /// Camelot numbers indexed by pitch class (0 = C … 11 = B).
  /// Major (B) ring: C=8B, C#=3B, D=10B, D#=5B, E=12B, F=7B,
  ///                 F#=2B, G=9B, G#=4B, A=11B, A#=6B, B=1B.
  static const List<int> _majorNumbers = [
    8, 3, 10, 5, 12, 7, 2, 9, 4, 11, 6, 1,
  ];

  /// Minor (A) ring: A minor = 8A, so the minor number for a pitch class is
  /// the major number of the pitch three semitones above (relative major).
  static const List<int> _minorNumbers = [
    5, 12, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10,
  ];

  /// Builds a key from a pitch class 0-11, or null when out of range.
  static CamelotKey? fromPitchClass(int pitchClass, {bool minor = false}) {
    if (pitchClass < 0 || pitchClass > 11) return null;
    final number =
        minor ? _minorNumbers[pitchClass] : _majorNumbers[pitchClass];
    return CamelotKey(number, minor);
  }

  /// True when moving from this key to [other] is harmonically smooth:
  /// same key, ±1 around the wheel, or the relative major/minor swap.
  bool isCompatibleWith(CamelotKey other) {
    if (number == other.number && isMinor == other.isMinor) return true;
    // Relative major/minor: same number, different letter.
    if (number == other.number) return true;
    // Adjacent on the wheel, same letter (12 wraps to 1).
    if (isMinor == other.isMinor) {
      final diff = (number - other.number).abs();
      if (diff == 1 || diff == 11) return true;
    }
    return false;
  }

  /// 1.0 for a perfect match, decreasing as the move gets harsher.
  /// Used to rank candidates when sequencing a mix.
  double compatibilityScore(CamelotKey other) {
    if (number == other.number && isMinor == other.isMinor) return 1.0;
    if (number == other.number) return 0.9; // relative major/minor
    if (isMinor == other.isMinor) {
      final diff = (number - other.number).abs();
      final steps = diff > 6 ? 12 - diff : diff;
      if (steps == 1) return 0.8;
      if (steps == 2) return 0.5;
      return 0.2;
    }
    return 0.1;
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      other is CamelotKey && other.number == number && other.isMinor == isMinor;

  @override
  int get hashCode => Object.hash(number, isMinor);
}
