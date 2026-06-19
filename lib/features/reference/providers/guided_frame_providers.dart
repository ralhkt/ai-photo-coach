import 'package:flutter_riverpod/flutter_riverpod.dart';

final referenceGhostVisibleProvider = StateProvider<bool>((ref) => true);

final bodyPartGuidesVisibleProvider = StateProvider<bool>((ref) => false);

/// Guided-mode composition grid — isolated from preview subtree rebuilds.
final guidedCompositionVisibleProvider = StateProvider<bool>((ref) => true);

/// Guided-mode pose frame overlay — isolated from preview subtree rebuilds.
final guidedFrameVisibleProvider = StateProvider<bool>((ref) => true);

void toggleGuidedCompositionVisible(WidgetRef ref) {
  final current = ref.read(guidedCompositionVisibleProvider);
  ref.read(guidedCompositionVisibleProvider.notifier).state = !current;
}

void toggleGuidedFrameVisible(WidgetRef ref) {
  final current = ref.read(guidedFrameVisibleProvider);
  ref.read(guidedFrameVisibleProvider.notifier).state = !current;
}