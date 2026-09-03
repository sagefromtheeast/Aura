import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateProvider for current tab index
final navigationStateProvider = StateProvider<int>((ref) => 0);
