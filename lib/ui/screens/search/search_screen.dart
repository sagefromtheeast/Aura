// lib/ui/screens/search/search_screen.dart
// Aura — Global search with three states: initial, active typing, no results.
//
// F-pattern layout: search bar spans the top, section headers are left-aligned,
// trending scrolls horizontally, and results flow in a vertical scannable list.
// Query is debounced 300ms and dispatched to [searchProvider] (an AsyncNotifier).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/search_provider.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  String _query = '';

  final List<String> _recent = [
    'tame impala',
    'jazz',
    'frank ocean',
    'rumours',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchProvider.notifier).search(value);
    });
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection =
        TextSelection.collapsed(offset: value.length);
    _onChanged(value);
    _focus.requestFocus();
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  void _remember(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    setState(() {
      _recent.removeWhere((e) => e.toLowerCase() == v.toLowerCase());
      _recent.insert(0, v);
      if (_recent.length > 8) _recent.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _controller,
              focusNode: _focus,
              showClear: hasQuery,
              onChanged: _onChanged,
              onClear: _clear,
              onSubmitted: _remember,
            ),
            Expanded(
              child: hasQuery ? _buildResults(context) : _buildInitial(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── State 1: initial ────────────────────────────────────────────────────────

  Widget _buildInitial(BuildContext context) {
    final trending = ref.watch(trendingProvider);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: _SectionHeader('Recent Searches')),
              TextButton(
                onPressed: () => setState(_recent.clear),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Wrap(
            spacing: DesignTokens.spacing8,
            runSpacing: DesignTokens.spacing8,
            children: [
              for (final term in _recent)
                _RecentChip(
                  key: ValueKey(term),
                  term: term,
                  onTap: () => _setQuery(term),
                  onRemove: () => setState(() => _recent.remove(term)),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing24),
        ],
        _SectionHeader('Trending in Your Library'),
        const SizedBox(height: DesignTokens.spacing12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _TrendingCard(
              album: trending[i],
              onTap: () => _setQuery(trending[i].title),
            ),
          ),
        ),
      ],
    );
  }

  // ── States 2 & 3: results / no results ────────────────────────────────────────

  Widget _buildResults(BuildContext context) {
    final async = ref.watch(searchProvider);
    final currentQ = _query.trim().toLowerCase();

    if (async.isLoading && !async.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    final results = async.valueOrNull ?? SearchResults.none;

    if (results.isEmpty) {
      // Results for the current query are genuinely empty → State 3.
      // Otherwise the debounce/fetch for the latest keystroke is still in
      // flight; show a spinner rather than a premature "no results".
      if (results.query != currentQ) {
        return const Center(child: CircularProgressIndicator());
      }
      return _NoResults(
        query: _query.trim(),
        onBrowse: () => Navigator.of(context).maybePop(),
        onScan: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Folder scan started'))),
      );
    }

    final q = results.query;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (results.artists.isNotEmpty) ...[
          _SectionHeader('Artists'),
          const SizedBox(height: DesignTokens.spacing8),
          for (final h in results.artists.take(6))
            _ArtistRow(artist: h.artist, query: q),
          const SizedBox(height: DesignTokens.spacing16),
        ],
        if (results.albums.isNotEmpty) ...[
          _SectionHeader('Albums'),
          const SizedBox(height: DesignTokens.spacing8),
          for (final h in results.albums.take(6))
            _AlbumRow(album: h.album, query: q),
          const SizedBox(height: DesignTokens.spacing16),
        ],
        if (results.songs.isNotEmpty) ...[
          _SectionHeader('Songs'),
          const SizedBox(height: DesignTokens.spacing8),
          for (final h in results.songs.take(12))
            _SongRow(song: h.song, query: q),
        ],
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.showClear,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showClear;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GlassCard(
        enableBlur: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        borderColor: DesignTokens.primarySeed.withValues(alpha: 0.35),
        child: Row(
          children: [
            // Glowing magnifying glass.
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primarySeed.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.search_rounded,
                  color: DesignTokens.primarySeed, size: 24),
            ),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: DesignTokens.bodyLarge.copyWith(color: _primary(context)),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search songs, artists, albums…',
                  hintStyle: DesignTokens.bodyLarge
                      .copyWith(color: _secondary(context)),
                ),
              ),
            ),
            if (showClear)
              IconButton(
                icon: Icon(Icons.close_rounded, color: _secondary(context)),
                onPressed: onClear,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }
}

// ── Recent chip (swipe / tap to remove) ───────────────────────────────────────

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    super.key,
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // Dismissible enables swipe-to-remove; the trailing × is a tap affordance.
    return Dismissible(
      key: ValueKey('recent_$term'),
      direction: DismissDirection.up,
      onDismissed: (_) => onRemove(),
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radiusPill,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: DesignTokens.primarySeed.withValues(alpha: 0.12),
            borderRadius: DesignTokens.radiusPill,
            border: Border.all(
                color: DesignTokens.primarySeed.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded,
                  size: 16, color: _secondary(context)),
              const SizedBox(width: 6),
              Text(term,
                  style: DesignTokens.bodyMedium
                      .copyWith(color: _primary(context))),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded,
                    size: 16, color: _secondary(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trending card (120px wide) ────────────────────────────────────────────────

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.album, required this.onTap});

  final LibraryAlbum album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radius16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius16,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [album.color, album.color.withValues(alpha: 0.55)],
                ),
              ),
              child: const Icon(Icons.trending_up_rounded,
                  color: Colors.white70, size: 20),
            ),
            const SizedBox(height: 6),
            Text(album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DesignTokens.bodyMedium.copyWith(
                    color: _primary(context), fontWeight: FontWeight.w600)),
            Text(album.artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    DesignTokens.caption.copyWith(color: _secondary(context))),
          ],
        ),
      ),
    );
  }
}

// ── Result rows ───────────────────────────────────────────────────────────────

class _ArtistRow extends StatelessWidget {
  const _ArtistRow({required this.artist, required this.query});
  final LibraryArtist artist;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [artist.color, artist.color.withValues(alpha: 0.5)],
          ),
        ),
        child: Text(
          _initials(artist.name),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      title: _highlight(artist.name, query, base: _titleStyle(context)),
      subtitle: Text('${artist.trackCount} tracks',
          style: DesignTokens.bodyMedium.copyWith(color: _secondary(context))),
    );
  }
}

class _AlbumRow extends StatelessWidget {
  const _AlbumRow({required this.album, required this.query});
  final LibraryAlbum album;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: DesignTokens.radius12,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [album.color, album.color.withValues(alpha: 0.5)],
          ),
        ),
        child: const Icon(Icons.album_rounded, color: Colors.white70),
      ),
      title: _highlight(album.title, query, base: _titleStyle(context)),
      subtitle: _highlight(album.artistName, query,
          base: DesignTokens.bodyMedium.copyWith(color: _secondary(context))),
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.query});
  final LibrarySong song;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.music_note_rounded, color: _secondary(context)),
      title: _highlight(song.title, query, base: _titleStyle(context)),
      subtitle: _highlight(song.artistName, query,
          base: DesignTokens.bodyMedium.copyWith(color: _secondary(context))),
      trailing: Text(
        _fmtDuration(song.durationMs),
        style: TextStyle(
          fontFamily: DesignTokens.fontMono,
          fontFamilyFallback: const <String>['monospace'],
          color: _secondary(context),
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── State 3: no results ───────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.onBrowse,
    required this.onScan,
  });

  final String query;
  final VoidCallback onBrowse;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Magnifying glass with a music note inside.
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          DesignTokens.primarySeed.withValues(alpha: 0.25),
                          DesignTokens.accentSparkle.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.music_note_rounded,
                      size: 40, color: DesignTokens.primarySeed),
                  // Magnifier handle.
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Transform.rotate(
                      angle: 0.785398, // 45°
                      child: Container(
                        width: 8,
                        height: 34,
                        decoration: BoxDecoration(
                          color: DesignTokens.primarySeed,
                          borderRadius: DesignTokens.radiusPill,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: DesignTokens.primarySeed
                                  .withValues(alpha: 0.6),
                              width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text(
              "No results for '$query'",
              textAlign: TextAlign.center,
              style: DesignTokens.headlineMedium.copyWith(
                  color: _primary(context)),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              'Try a different spelling or browse your library.',
              textAlign: TextAlign.center,
              style:
                  DesignTokens.bodyLarge.copyWith(color: _secondary(context)),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onBrowse,
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primarySeed,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.library_music_rounded),
                  label: const Text('Browse Library'),
                ),
                const SizedBox(width: DesignTokens.spacing12),
                OutlinedButton.icon(
                  onPressed: onScan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.primarySeed,
                    side: const BorderSide(color: DesignTokens.primarySeed),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: const Text('Scan Folder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DesignTokens.titleLarge.copyWith(color: _primary(context)),
    );
  }
}

TextStyle _titleStyle(BuildContext context) => DesignTokens.bodyLarge
    .copyWith(fontWeight: FontWeight.w600, color: _primary(context));

/// Highlights the contiguous case-insensitive match of [query] within [text]
/// using the accent colour. Falls back to plain text for fuzzy-only matches.
Widget _highlight(String text, String query, {required TextStyle base}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: base);
  }
  final lower = text.toLowerCase();
  final idx = lower.indexOf(q);
  if (idx < 0) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: base);
  }
  final hi = base.copyWith(
    color: DesignTokens.primarySeed,
    fontWeight: FontWeight.w800,
  );
  return Text.rich(
    TextSpan(children: [
      TextSpan(text: text.substring(0, idx), style: base),
      TextSpan(text: text.substring(idx, idx + q.length), style: hi),
      TextSpan(text: text.substring(idx + q.length), style: base),
    ]),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _fmtDuration(int ms) {
  final total = ms ~/ 1000;
  final m = total ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
