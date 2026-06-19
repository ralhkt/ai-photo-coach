import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pose/providers/pose_coaching_provider.dart';
import '../../pose/services/alignment_overlay_state.dart';

final referenceGhostVisibleProvider = StateProvider<bool>((ref) => true);

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

/// Repaints guided outline only when match phase changes (not every score tick).
final poseCoachingAlignmentPhaseProvider = Provider<AlignmentOverlayPhase>(
  (ref) {
    final coaching = ref.watch(
      poseCoachingResultProvider.select(
        (result) => (
          result?.poseScore,
          result?.poseMatched,
        ),
      ),
    );
    final score = coaching.$1;
    if (score != null) {
      return AlignmentOverlayState.phaseForScore(score);
    }
    return coaching.$2 == true
        ? AlignmentOverlayPhase.matched
        : AlignmentOverlayPhase.noMatch;
  },
);