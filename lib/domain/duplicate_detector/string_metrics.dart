// lib/domain/duplicate_detector/string_metrics.dart
// Aura — String similarity metrics for fuzzy duplicate detection.
//
// The spec names two specific metrics: Levenshtein for titles (which are long
// and where an inserted "(Remastered)" should cost proportionally) and
// Jaro-Winkler for artists (which are short and where a shared prefix is
// strong evidence — "Beyonce" vs "Beyoncé", "Sigur Ros" vs "Sigur Rós").
//
// These are implemented here rather than taken from the `string_similarity`
// package, which despite its name exposes the Sørensen-Dice coefficient over
// bigrams — neither of the metrics the spec calls for.

import 'dart:math' as math;

/// Levenshtein edit distance between [a] and [b].
///
/// Uses two rolling rows rather than a full matrix, so memory is O(min(n, m))
/// instead of O(n × m) — this runs across every candidate pair in a library.
int levenshteinDistance(String a, String b) {
  if (identical(a, b) || a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  // Index the shorter string across the row to keep the row small.
  if (a.length > b.length) {
    final tmp = a;
    a = b;
    b = tmp;
  }

  final n = a.length;
  var previous = List<int>.generate(n + 1, (i) => i, growable: false);
  var current = List<int>.filled(n + 1, 0, growable: false);

  for (var j = 1; j <= b.length; j++) {
    current[0] = j;
    final bj = b.codeUnitAt(j - 1);
    for (var i = 1; i <= n; i++) {
      final cost = a.codeUnitAt(i - 1) == bj ? 0 : 1;
      final deletion = previous[i] + 1;
      final insertion = current[i - 1] + 1;
      final substitution = previous[i - 1] + cost;
      current[i] = math.min(math.min(deletion, insertion), substitution);
    }
    final swap = previous;
    previous = current;
    current = swap;
  }

  return previous[n];
}

/// Levenshtein distance normalised to a [0, 1] similarity, where 1.0 is an
/// exact match. Two empty strings are treated as identical.
double levenshteinSimilarity(String a, String b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  final longest = math.max(a.length, b.length);
  if (longest == 0) return 1.0;
  return 1.0 - (levenshteinDistance(a, b) / longest);
}

/// Jaro similarity between [a] and [b], in [0, 1].
double jaroSimilarity(String a, String b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  if (a.isEmpty || b.isEmpty) return 0.0;
  if (a == b) return 1.0;

  // Characters may only match within this window of each other.
  final window = math.max(a.length, b.length) ~/ 2 - 1;
  if (window < 0) {
    // Both strings are single characters and already known to differ.
    return 0.0;
  }

  final aMatched = List<bool>.filled(a.length, false);
  final bMatched = List<bool>.filled(b.length, false);

  var matches = 0;
  for (var i = 0; i < a.length; i++) {
    final start = math.max(0, i - window);
    final end = math.min(i + window + 1, b.length);
    for (var j = start; j < end; j++) {
      if (bMatched[j]) continue;
      if (a.codeUnitAt(i) != b.codeUnitAt(j)) continue;
      aMatched[i] = true;
      bMatched[j] = true;
      matches++;
      break;
    }
  }

  if (matches == 0) return 0.0;

  // Half the number of matched characters that are out of order.
  var transpositions = 0;
  var k = 0;
  for (var i = 0; i < a.length; i++) {
    if (!aMatched[i]) continue;
    while (!bMatched[k]) {
      k++;
    }
    if (a.codeUnitAt(i) != b.codeUnitAt(k)) transpositions++;
    k++;
  }
  final halfTranspositions = transpositions / 2.0;

  return (matches / a.length +
          matches / b.length +
          (matches - halfTranspositions) / matches) /
      3.0;
}

/// Jaro-Winkler similarity: Jaro, boosted for a shared prefix.
///
/// [prefixScale] is Winkler's constant p (0.1 in the standard formulation) and
/// the prefix is capped at four characters, both per the original paper.
double jaroWinklerSimilarity(String a, String b, {double prefixScale = 0.1}) {
  final jaro = jaroSimilarity(a, b);

  // Winkler only boosts strings that are already fairly similar.
  if (jaro < 0.7) return jaro;

  var prefix = 0;
  final maxPrefix = math.min(4, math.min(a.length, b.length));
  while (prefix < maxPrefix && a.codeUnitAt(prefix) == b.codeUnitAt(prefix)) {
    prefix++;
  }

  return jaro + prefix * prefixScale * (1.0 - jaro);
}
