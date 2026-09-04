// test/queue_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/domain/entities/track.dart';
import 'package:aura/domain/queue/queue_manager.dart';

Track track(String id) => Track(
      id: id,
      title: 'Song $id',
      artistName: 'Artist $id',
      albumTitle: 'Album $id',
      artistId: 'a_$id',
      albumId: 'al_$id',
      durationMs: 200000,
      filePath: '/m/$id',
      fileSizeBytes: 1,
      dateAddedMs: 0,
    );

QueueManager manager() {
  var n = 0;
  return QueueManager(idGenerator: () => 'q${n++}');
}

void main() {
  group('active queue navigation', () {
    test('replaceWith sets tracks, cursor and active', () {
      final m = manager();
      m.replaceWith([track('a'), track('b'), track('c')], name: 'Mix');
      expect(m.current?.id, 'a');
      expect(m.active?.length, 3);
      expect(m.queues, hasLength(1));
    });

    test('replaceWith honours a start index', () {
      final m = manager();
      m.replaceWith([track('a'), track('b'), track('c')],
          name: 'Mix', startIndex: 2);
      expect(m.current?.id, 'c');
    });

    test('advance / goBack walk the queue and stop at the ends', () {
      final m = manager();
      m.replaceWith([track('a'), track('b')], name: 'Mix');
      expect(m.advance()?.id, 'b');
      expect(m.advance(), isNull); // exhausted
      expect(m.current?.id, 'b');
      expect(m.goBack()?.id, 'a');
      expect(m.goBack(), isNull); // at start
    });

    test('jumpTo moves the cursor', () {
      final m = manager();
      m.replaceWith([track('a'), track('b'), track('c')], name: 'Mix');
      expect(m.jumpTo(2)?.id, 'c');
      expect(m.jumpTo(9), isNull);
    });
  });

  group('add to queue / play next', () {
    test('addToQueue appends to the end', () {
      final m = manager();
      m.replaceWith([track('a')], name: 'Mix');
      m.addToQueue(track('z'));
      expect(m.active!.tracks.map((t) => t.id), ['a', 'z']);
    });

    test('playNext inserts right after the current track', () {
      final m = manager();
      m.replaceWith([track('a'), track('b')], name: 'Mix');
      m.playNext(track('x'));
      expect(m.active!.tracks.map((t) => t.id), ['a', 'x', 'b']);
      // Current is unchanged; the inserted track is up next.
      expect(m.current?.id, 'a');
      expect(m.advance()?.id, 'x');
    });

    test('addToQueue with no active queue creates one', () {
      final m = manager();
      m.addToQueue(track('a'));
      expect(m.active, isNotNull);
      expect(m.current?.id, 'a');
    });
  });

  group('remove and reorder', () {
    test('removeAt keeps the cursor on the same upcoming track', () {
      final m = manager();
      m.replaceWith([track('a'), track('b'), track('c')],
          name: 'Mix', startIndex: 1); // current = b
      m.removeAt(0); // remove a (before cursor)
      expect(m.current?.id, 'b'); // still b
      expect(m.active!.tracks.map((t) => t.id), ['b', 'c']);
    });

    test('removeAt past the end clamps the cursor', () {
      final m = manager();
      m.replaceWith([track('a'), track('b')], name: 'Mix', startIndex: 1);
      m.removeAt(1); // remove current last
      expect(m.current?.id, 'a');
    });

    test('reorder preserves which track is current', () {
      final m = manager();
      m.replaceWith([track('a'), track('b'), track('c')],
          name: 'Mix', startIndex: 1); // current = b
      m.reorder(2, 0); // move c to front
      expect(m.active!.tracks.map((t) => t.id), ['c', 'a', 'b']);
      expect(m.current?.id, 'b'); // b is still current
    });
  });

  group('multiple named queues', () {
    test('addQueue does not disturb the active one', () {
      final m = manager();
      m.replaceWith([track('a')], name: 'Playlist', source: 'playlist');
      m.addQueue([track('x'), track('y')],
          name: 'Search: foo', source: 'search');
      expect(m.queues, hasLength(2));
      expect(m.active?.name, 'Playlist'); // unchanged
      expect(m.current?.id, 'a');
    });

    test('switchTo changes the active queue and keeps each position', () {
      final m = manager();
      m.replaceWith([track('a'), track('b')], name: 'One');
      final one = m.active!.id;
      m.advance(); // One now at b
      final two = m.addQueue([track('x'), track('y')], name: 'Two').id;

      expect(m.switchTo(two), isTrue);
      expect(m.current?.id, 'x');
      expect(m.switchTo(one), isTrue);
      expect(m.current?.id, 'b'); // One remembered its position
      expect(m.switchTo('nope'), isFalse);
    });

    test('rename and removeAllButActive', () {
      final m = manager();
      m.replaceWith([track('a')], name: 'Keep');
      final keepId = m.active!.id;
      m.addQueue([track('x')], name: 'Drop1');
      m.addQueue([track('y')], name: 'Drop2');
      m.renameQueue(keepId, 'Renamed');

      m.removeAllButActive();
      expect(m.queues, hasLength(1));
      expect(m.active?.name, 'Renamed');
    });

    test('removeQueue re-points active when needed', () {
      final m = manager();
      m.replaceWith([track('a')], name: 'One');
      final oneId = m.active!.id;
      m.addQueue([track('x')], name: 'Two', makeActive: true);
      expect(m.active?.name, 'Two');

      m.removeQueue(m.active!.id); // remove active
      expect(m.queues, hasLength(1));
      expect(m.active?.name, 'One');

      m.removeQueue(oneId); // remove last
      expect(m.hasQueues, isFalse);
      expect(m.current, isNull);
    });
  });

  test('toJson captures the shape for persistence', () {
    final m = manager();
    m.replaceWith([track('a'), track('b')],
        name: 'Mix', startIndex: 1, source: 'playlist');
    final json = m.active!.toJson();
    expect(json['name'], 'Mix');
    expect(json['cursor'], 1);
    expect(json['source'], 'playlist');
    expect(json['trackIds'], ['a', 'b']);
  });
}
