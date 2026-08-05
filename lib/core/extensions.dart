// lib/core/extensions.dart
// Aura — Dart extension methods used across all layers.

import 'dart:math' as math;

/// Extensions on [List<double>] for audio feature vector math.
extension VectorMath on List<double> {
  /// Euclidean distance to [other]. Both lists must have the same length.
  double distanceTo(List<double> other) {
    assert(length == other.length, 'Vector dimension mismatch');
    double sum = 0.0;
    for (int i = 0; i < length; i++) {
      final diff = this[i] - other[i];
      sum += diff * diff;
    }
    return math.sqrt(sum);
  }

  /// Element-wise addition into a new list.
  List<double> operator +(List<double> other) {
    assert(length == other.length);
    return List.generate(length, (i) => this[i] + other[i]);
  }

  /// Scalar division into a new list.
  List<double> operator /(double scalar) {
    return List.generate(length, (i) => this[i] / scalar);
  }

  /// Returns a zero-initialised vector of the same length.
  List<double> zeroCopy() => List.filled(length, 0.0);
}

/// Extensions on [Duration] for display formatting.
extension DurationFormat on Duration {
  /// Returns "3:45" or "1:03:45" style string.
  String toDisplayString() {
    final h = inHours;
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

/// Extensions on [Iterable<T>].
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the element at [index] or null if out of range.
  T? elementAtOrNull(int index) {
    int i = 0;
    for (final e in this) {
      if (i == index) return e;
      i++;
    }
    return null;
  }
}

/// Extensions on [List<T>] for in-place shuffle with a seeded [math.Random].
extension ListShuffle<T> on List<T> {
  /// Fisher-Yates shuffle using the provided [rng].
  void shuffleWith(math.Random rng) {
    for (int i = length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = this[i];
      this[i] = this[j];
      this[j] = tmp;
    }
  }
}
