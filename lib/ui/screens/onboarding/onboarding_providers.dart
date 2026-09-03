import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String? selectedVibe;
  OnboardingState({this.selectedVibe});

  OnboardingState copyWith({String? selectedVibe}) {
    return OnboardingState(
      selectedVibe: selectedVibe ?? this.selectedVibe,
    );
  }
}

class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  OnboardingStateNotifier() : super(OnboardingState());

  void setVibe(String vibe) {
    state = state.copyWith(selectedVibe: vibe);
  }
}

final onboardingStateProvider = StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  return OnboardingStateNotifier();
});

final libraryScanProvider = StreamProvider.autoDispose<int>((ref) {
  final streamController = StreamController<int>();
  int count = 0;
  
  final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
    count += 41;
    streamController.add(count);
    if (timer.tick >= 60) {
      timer.cancel();
      streamController.close();
    }
  });

  ref.onDispose(() {
    timer.cancel();
    if (!streamController.isClosed) {
      streamController.close();
    }
  });

  return streamController.stream;
});
