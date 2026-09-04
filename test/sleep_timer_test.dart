// test/sleep_timer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/domain/playback/sleep_timer.dart';

void main() {
  group('SleepTimerState', () {
    test('off is inactive', () {
      expect(SleepTimerState.off.isActive, isFalse);
      expect(SleepTimerState.off.mode, SleepTimerMode.off);
    });

    test('duration mode reports remaining time', () {
      final s = SleepTimerState(
        mode: SleepTimerMode.duration,
        endsAtMs: 10000,
      );
      expect(s.isActive, isTrue);
      expect(s.remaining(4000), const Duration(milliseconds: 6000));
    });

    test('remaining never goes negative', () {
      final s = SleepTimerState(mode: SleepTimerMode.duration, endsAtMs: 1000);
      expect(s.remaining(5000), Duration.zero);
    });

    test('end-of-track carries no deadline', () {
      const s = SleepTimerState(mode: SleepTimerMode.endOfTrack);
      expect(s.isActive, isTrue);
      expect(s.remaining(0), Duration.zero);
    });
  });
}
