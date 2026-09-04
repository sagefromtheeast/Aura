// lib/data/search_provider.dart
// Aura — Search provider. An AsyncNotifier that takes a query and returns
// ranked, category-grouped results from a local dummy library.
//
// Matching (all case-insensitive, offline):
//   exact  > prefix > contains > fuzzy (string_similarity / Dice coefficient)
// Searchable fields: track title, artist name, album name, genre.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';

// ── Library item models (dummy) ───────────────────────────────────────────────

@immutable
class LibraryArtist {
  const LibraryArtist({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.color,
    this.genre = '',
  });
  final String id;
  final String name;
  final int trackCount;
  final Color color;
  final String genre;
}

@immutable
class LibraryAlbum {
  const LibraryAlbum({
    required this.id,
    required this.title,
    required this.artistName,
    required this.color,
    this.genre = '',
  });
  final String id;
  final String title;
  final String artistName;
  final Color color;
  final String genre;
}

@immutable
class LibrarySong {
  const LibrarySong({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.durationMs,
    this.genre = '',
  });
  final String id;
  final String title;
  final String artistName;
  final String albumTitle;
  final int durationMs;
  final String genre;
}

// ── Ranked hit wrappers ───────────────────────────────────────────────────────

@immutable
class ArtistHit {
  const ArtistHit(this.artist, this.score);
  final LibraryArtist artist;
  final double score;
}

@immutable
class AlbumHit {
  const AlbumHit(this.album, this.score);
  final LibraryAlbum album;
  final double score;
}

@immutable
class SongHit {
  const SongHit(this.song, this.score);
  final LibrarySong song;
  final double score;
}

/// Grouped, ranked results for a single query.
@immutable
class SearchResults {
  const SearchResults({
    required this.query,
    this.artists = const [],
    this.albums = const [],
    this.songs = const [],
  });

  final String query;
  final List<ArtistHit> artists;
  final List<AlbumHit> albums;
  final List<SongHit> songs;

  bool get isEmpty => artists.isEmpty && albums.isEmpty && songs.isEmpty;
  int get total => artists.length + albums.length + songs.length;

  static const SearchResults none = SearchResults(query: '');
}

// ── Ranking ───────────────────────────────────────────────────────────────────

/// Minimum Dice similarity for a fuzzy (non-substring) match to count.
const double _kFuzzyThreshold = 0.34;

/// Scores [text] against [query]. Higher is better; returns a negative number
/// when there is no acceptable match.
double _scoreField(String query, String text) {
  if (query.isEmpty || text.isEmpty) return -1;
  final q = query;
  final t = text.toLowerCase();
  if (t == q) return 1000;
  if (t.startsWith(q)) return 800 - (t.length - q.length).clamp(0, 200) * 0.1;
  final idx = t.indexOf(q);
  if (idx >= 0) return 600 - idx * 0.5 - (t.length - q.length).clamp(0, 200) * 0.05;
  // Fuzzy fallback (Dice coefficient via string_similarity).
  final sim = q.similarityTo(t);
  if (sim >= _kFuzzyThreshold) return 100 * sim;
  // Token-level fuzzy: best word match (helps multi-word titles).
  double best = 0;
  for (final word in t.split(RegExp(r'\s+'))) {
    final s = q.similarityTo(word);
    if (s > best) best = s;
  }
  if (best >= _kFuzzyThreshold) return 80 * best;
  return -1;
}

/// Best score across several candidate fields.
double _bestScore(String query, List<String> fields) {
  double best = -1;
  for (final f in fields) {
    final s = _scoreField(query, f);
    if (s > best) best = s;
  }
  return best;
}

// ── AsyncNotifier ─────────────────────────────────────────────────────────────

class SearchController extends AsyncNotifier<SearchResults> {
  @override
  Future<SearchResults> build() async => SearchResults.none;

  /// Run a query. Empty/whitespace resets to the no-query state.
  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      state = const AsyncData(SearchResults.none);
      return;
    }
    state = const AsyncLoading<SearchResults>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _compute(query));
  }

  Future<SearchResults> _compute(String query) async {
    // Simulate a tiny async DB hit.
    await Future<void>.delayed(const Duration(milliseconds: 40));

    final artists = <ArtistHit>[];
    for (final a in _kArtists) {
      final s = _bestScore(query, [a.name, a.genre]);
      if (s > 0) artists.add(ArtistHit(a, s));
    }
    final albums = <AlbumHit>[];
    for (final al in _kAlbums) {
      final s = _bestScore(query, [al.title, al.artistName, al.genre]);
      if (s > 0) albums.add(AlbumHit(al, s));
    }
    final songs = <SongHit>[];
    for (final so in _kSongs) {
      final s =
          _bestScore(query, [so.title, so.artistName, so.albumTitle, so.genre]);
      if (s > 0) songs.add(SongHit(so, s));
    }

    artists.sort((x, y) => y.score.compareTo(x.score));
    albums.sort((x, y) => y.score.compareTo(x.score));
    songs.sort((x, y) => y.score.compareTo(x.score));

    return SearchResults(
      query: query,
      artists: artists,
      albums: albums,
      songs: songs,
    );
  }
}

/// Query-driven search results. Call
/// `ref.read(searchProvider.notifier).search(query)` (debounced by the UI).
final searchProvider =
    AsyncNotifierProvider<SearchController, SearchResults>(SearchController.new);

// ── Trending (initial state) ──────────────────────────────────────────────────

/// "Trending in Your Library" — a curated slice of the dummy data.
final trendingProvider = Provider<List<LibraryAlbum>>((ref) {
  return _kAlbums.take(8).toList();
});

// ── Dummy library data ────────────────────────────────────────────────────────

const List<LibraryArtist> _kArtists = [
  LibraryArtist(id: 'ar1', name: 'Tame Impala', trackCount: 48, color: Color(0xFFFF8F6D), genre: 'Psychedelic'),
  LibraryArtist(id: 'ar2', name: 'Frank Ocean', trackCount: 32, color: Color(0xFF6DD5FF), genre: 'R&B'),
  LibraryArtist(id: 'ar3', name: 'Radiohead', trackCount: 61, color: Color(0xFF8E7CFF), genre: 'Alternative'),
  LibraryArtist(id: 'ar4', name: 'Kendrick Lamar', trackCount: 40, color: Color(0xFFFFD36E), genre: 'Hip-Hop'),
  LibraryArtist(id: 'ar5', name: 'Fleetwood Mac', trackCount: 27, color: Color(0xFF4ADE80), genre: 'Rock'),
  LibraryArtist(id: 'ar6', name: 'Beach House', trackCount: 35, color: Color(0xFFFF6B9D), genre: 'Dream Pop'),
  LibraryArtist(id: 'ar7', name: 'Mac DeMarco', trackCount: 22, color: Color(0xFFF97316), genre: 'Indie'),
  LibraryArtist(id: 'ar8', name: 'Bon Iver', trackCount: 29, color: Color(0xFF38BDF8), genre: 'Folktronica'),
  LibraryArtist(id: 'ar9', name: 'Phoebe Bridgers', trackCount: 24, color: Color(0xFFA78BFA), genre: 'Indie Folk'),
  LibraryArtist(id: 'ar10', name: 'Miles Davis', trackCount: 55, color: Color(0xFF64748B), genre: 'Jazz'),
  LibraryArtist(id: 'ar11', name: 'Daft Punk', trackCount: 33, color: Color(0xFFF472B6), genre: 'Electronic'),
  LibraryArtist(id: 'ar12', name: 'Arcade Fire', trackCount: 31, color: Color(0xFF22D3EE), genre: 'Indie Rock'),
];

const List<LibraryAlbum> _kAlbums = [
  LibraryAlbum(id: 'al1', title: 'Currents', artistName: 'Tame Impala', color: Color(0xFFFF8F6D), genre: 'Psychedelic'),
  LibraryAlbum(id: 'al2', title: 'Blonde', artistName: 'Frank Ocean', color: Color(0xFF6DD5FF), genre: 'R&B'),
  LibraryAlbum(id: 'al3', title: 'In Rainbows', artistName: 'Radiohead', color: Color(0xFF8E7CFF), genre: 'Alternative'),
  LibraryAlbum(id: 'al4', title: 'To Pimp a Butterfly', artistName: 'Kendrick Lamar', color: Color(0xFFFFD36E), genre: 'Hip-Hop'),
  LibraryAlbum(id: 'al5', title: 'Rumours', artistName: 'Fleetwood Mac', color: Color(0xFF4ADE80), genre: 'Rock'),
  LibraryAlbum(id: 'al6', title: 'Teen Dream', artistName: 'Beach House', color: Color(0xFFFF6B9D), genre: 'Dream Pop'),
  LibraryAlbum(id: 'al7', title: 'Salad Days', artistName: 'Mac DeMarco', color: Color(0xFFF97316), genre: 'Indie'),
  LibraryAlbum(id: 'al8', title: 'For Emma, Forever Ago', artistName: 'Bon Iver', color: Color(0xFF38BDF8), genre: 'Folktronica'),
  LibraryAlbum(id: 'al9', title: 'Punisher', artistName: 'Phoebe Bridgers', color: Color(0xFFA78BFA), genre: 'Indie Folk'),
  LibraryAlbum(id: 'al10', title: 'Kind of Blue', artistName: 'Miles Davis', color: Color(0xFF64748B), genre: 'Jazz'),
  LibraryAlbum(id: 'al11', title: 'Discovery', artistName: 'Daft Punk', color: Color(0xFFF472B6), genre: 'Electronic'),
  LibraryAlbum(id: 'al12', title: 'The Suburbs', artistName: 'Arcade Fire', color: Color(0xFF22D3EE), genre: 'Indie Rock'),
];

const List<LibrarySong> _kSongs = [
  LibrarySong(id: 's1', title: 'The Less I Know The Better', artistName: 'Tame Impala', albumTitle: 'Currents', durationMs: 216000, genre: 'Psychedelic'),
  LibrarySong(id: 's2', title: 'Let It Happen', artistName: 'Tame Impala', albumTitle: 'Currents', durationMs: 467000, genre: 'Psychedelic'),
  LibrarySong(id: 's3', title: 'Nights', artistName: 'Frank Ocean', albumTitle: 'Blonde', durationMs: 307000, genre: 'R&B'),
  LibrarySong(id: 's4', title: 'Ivy', artistName: 'Frank Ocean', albumTitle: 'Blonde', durationMs: 249000, genre: 'R&B'),
  LibrarySong(id: 's5', title: 'Weird Fishes / Arpeggi', artistName: 'Radiohead', albumTitle: 'In Rainbows', durationMs: 318000, genre: 'Alternative'),
  LibrarySong(id: 's6', title: 'Nude', artistName: 'Radiohead', albumTitle: 'In Rainbows', durationMs: 255000, genre: 'Alternative'),
  LibrarySong(id: 's7', title: 'Alright', artistName: 'Kendrick Lamar', albumTitle: 'To Pimp a Butterfly', durationMs: 219000, genre: 'Hip-Hop'),
  LibrarySong(id: 's8', title: 'The Chain', artistName: 'Fleetwood Mac', albumTitle: 'Rumours', durationMs: 271000, genre: 'Rock'),
  LibrarySong(id: 's9', title: 'Dreams', artistName: 'Fleetwood Mac', albumTitle: 'Rumours', durationMs: 257000, genre: 'Rock'),
  LibrarySong(id: 's10', title: 'Space Song', artistName: 'Beach House', albumTitle: 'Teen Dream', durationMs: 320000, genre: 'Dream Pop'),
  LibrarySong(id: 's11', title: 'Chamber of Reflection', artistName: 'Mac DeMarco', albumTitle: 'Salad Days', durationMs: 235000, genre: 'Indie'),
  LibrarySong(id: 's12', title: 'Skinny Love', artistName: 'Bon Iver', albumTitle: 'For Emma, Forever Ago', durationMs: 238000, genre: 'Folktronica'),
  LibrarySong(id: 's13', title: 'Kyoto', artistName: 'Phoebe Bridgers', albumTitle: 'Punisher', durationMs: 185000, genre: 'Indie Folk'),
  LibrarySong(id: 's14', title: 'So What', artistName: 'Miles Davis', albumTitle: 'Kind of Blue', durationMs: 545000, genre: 'Jazz'),
  LibrarySong(id: 's15', title: 'Get Lucky', artistName: 'Daft Punk', albumTitle: 'Random Access Memories', durationMs: 369000, genre: 'Electronic'),
  LibrarySong(id: 's16', title: 'Wake Up', artistName: 'Arcade Fire', albumTitle: 'Funeral', durationMs: 335000, genre: 'Indie Rock'),
];
