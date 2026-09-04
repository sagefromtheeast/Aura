// lib/domain/queue/queue_manager.dart
// Aura — Multiple named playback queues.
//
// A single "up next" list is the norm; this generalises it. The user can have
// several independent named queues at once — a playlist playing while a search
// result waits to be returned to — each with its own tracks and cursor, and
// switch between them without losing position. One queue is active at a time.
//
// Pure domain logic: no engine, no Flutter, no persistence. The orchestrator
// drives audio from whatever `current` returns; a repository can serialise
// `toJson` when persistence is wired.

import '../entities/track.dart';

/// One named, ordered queue with a play cursor.
class NamedQueue {
  NamedQueue({
    required this.id,
    required this.name,
    List<Track>? tracks,
    this.cursor = 0,
    this.source,
  }) : tracks = tracks ?? [];

  final String id;
  String name;

  /// Ordered tracks. Mutated in place by the manager.
  final List<Track> tracks;

  /// Index of the current track, clamped to the list.
  int cursor;

  /// Where the queue came from — 'playlist', 'album', 'search', 'manual', …
  /// Purely informational, shown in the queues manager.
  final String? source;

  Track? get current =>
      tracks.isEmpty ? null : tracks[cursor.clamp(0, tracks.length - 1)];

  bool get hasNext => cursor < tracks.length - 1;
  bool get hasPrevious => cursor > 0;

  int get length => tracks.length;
  bool get isEmpty => tracks.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cursor': cursor,
        'source': source,
        'trackIds': [for (final t in tracks) t.id],
      };
}

/// Manages a set of [NamedQueue]s, one of them active.
class QueueManager {
  QueueManager({String Function()? idGenerator})
      : _nextId = idGenerator ?? _defaultIdGenerator();

  final List<NamedQueue> _queues = [];
  int _activeIndex = -1;
  final String Function() _nextId;

  static String Function() _defaultIdGenerator() {
    var counter = 0;
    return () => 'q${counter++}_${DateTime.now().microsecondsSinceEpoch}';
  }

  List<NamedQueue> get queues => List.unmodifiable(_queues);
  bool get hasQueues => _queues.isNotEmpty;

  NamedQueue? get active =>
      (_activeIndex >= 0 && _activeIndex < _queues.length)
          ? _queues[_activeIndex]
          : null;

  /// The track that should be playing now.
  Track? get current => active?.current;

  // ── Queue lifecycle ──────────────────────────────────────────────────────

  /// Replaces all queues with a single one built from [tracks] and makes it
  /// active — the "play this playlist / album now" path.
  NamedQueue replaceWith(
    List<Track> tracks, {
    required String name,
    int startIndex = 0,
    String? source,
  }) {
    final queue = NamedQueue(
      id: _nextId(),
      name: name,
      tracks: List.of(tracks),
      cursor: tracks.isEmpty ? 0 : startIndex.clamp(0, tracks.length - 1),
      source: source,
    );
    _queues
      ..clear()
      ..add(queue);
    _activeIndex = 0;
    return queue;
  }

  /// Adds a queue without disturbing the active one — the "save this for later"
  /// path (e.g. a search result).
  NamedQueue addQueue(
    List<Track> tracks, {
    required String name,
    String? source,
    bool makeActive = false,
  }) {
    final queue = NamedQueue(
      id: _nextId(),
      name: name,
      tracks: List.of(tracks),
      source: source,
    );
    _queues.add(queue);
    if (makeActive || _activeIndex < 0) _activeIndex = _queues.length - 1;
    return queue;
  }

  /// Switches the active queue by id. Returns false when unknown.
  bool switchTo(String queueId) {
    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index < 0) return false;
    _activeIndex = index;
    return true;
  }

  void renameQueue(String queueId, String name) {
    final queue = _byId(queueId);
    if (queue != null) queue.name = name;
  }

  /// Removes a queue. If it was active, the next remaining queue becomes
  /// active (or none, when the list empties).
  void removeQueue(String queueId) {
    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index < 0) return;
    _queues.removeAt(index);
    if (_queues.isEmpty) {
      _activeIndex = -1;
    } else if (index <= _activeIndex) {
      _activeIndex = (_activeIndex - 1).clamp(0, _queues.length - 1);
    }
  }

  /// Keeps only the active queue.
  void removeAllButActive() {
    final keep = active;
    _queues
      ..clear()
      ..addAll([if (keep != null) keep]);
    _activeIndex = _queues.isEmpty ? -1 : 0;
  }

  void clear() {
    _queues.clear();
    _activeIndex = -1;
  }

  // ── Within the active queue ──────────────────────────────────────────────

  /// Appends [track] to the end of the active queue (creating one if needed).
  void addToQueue(Track track, {String queueName = 'Queue'}) {
    final queue = _ensureActive(queueName);
    queue.tracks.add(track);
  }

  /// Inserts [track] to play immediately after the current one.
  void playNext(Track track, {String queueName = 'Queue'}) {
    final queue = _ensureActive(queueName);
    final at = queue.isEmpty ? 0 : queue.cursor + 1;
    queue.tracks.insert(at.clamp(0, queue.tracks.length), track);
  }

  /// Advances the active queue and returns the new current track, or null when
  /// the queue is exhausted.
  Track? advance() {
    final queue = active;
    if (queue == null || !queue.hasNext) return null;
    queue.cursor++;
    return queue.current;
  }

  /// Steps back and returns the new current track, or null at the start.
  Track? goBack() {
    final queue = active;
    if (queue == null || !queue.hasPrevious) return null;
    queue.cursor--;
    return queue.current;
  }

  /// Jumps to [index] in the active queue and returns that track.
  Track? jumpTo(int index) {
    final queue = active;
    if (queue == null || index < 0 || index >= queue.length) return null;
    queue.cursor = index;
    return queue.current;
  }

  /// Removes the track at [index] from the active queue, keeping the cursor on
  /// the same upcoming track.
  void removeAt(int index) {
    final queue = active;
    if (queue == null || index < 0 || index >= queue.length) return;
    queue.tracks.removeAt(index);
    if (index < queue.cursor) {
      queue.cursor--;
    } else if (queue.cursor >= queue.length && queue.length > 0) {
      queue.cursor = queue.length - 1;
    }
  }

  /// Reorders a track within the active queue, preserving which track is
  /// current.
  void reorder(int oldIndex, int newIndex) {
    final queue = active;
    if (queue == null) return;
    if (oldIndex < 0 || oldIndex >= queue.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    target = target.clamp(0, queue.length - 1);

    final currentTrack = queue.current;
    final moved = queue.tracks.removeAt(oldIndex);
    queue.tracks.insert(target, moved);
    // Re-find the cursor so the same track stays current.
    if (currentTrack != null) {
      final at = queue.tracks.indexWhere((t) => t.id == currentTrack.id);
      if (at >= 0) queue.cursor = at;
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  NamedQueue _ensureActive(String name) {
    final existing = active;
    if (existing != null) return existing;
    return addQueue(const [], name: name, source: 'manual', makeActive: true);
  }

  NamedQueue? _byId(String id) {
    for (final q in _queues) {
      if (q.id == id) return q;
    }
    return null;
  }
}
