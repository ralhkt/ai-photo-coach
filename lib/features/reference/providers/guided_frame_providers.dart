import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/photo_frame_template.dart';
import '../../camera/providers/camera_interaction_provider.dart';
import '../../frames/presentation/poze_wireframe_style.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../pose/services/alignment_overlay_state.dart';
import 'reference_providers.dart';

final referenceGhostVisibleProvider = StateProvider<bool>((ref) => true);

/// Guided ghost overlay opacity — user-adjustable in overlay tools sheet.
final referenceGhostOpacityProvider = StateProvider<double>(
  (ref) => PozeWireframeStyle.ghostOpacity,
);

const guidedGhostOpacityMin = 0.08;
const guidedGhostOpacityMax = 0.72;

/// Guided-mode composition grid — isolated from preview subtree rebuilds.
final guidedCompositionVisibleProvider = StateProvider<bool>((ref) => true);

/// Guided-mode pose frame overlay — isolated from preview subtree rebuilds.
final guidedFrameVisibleProvider = StateProvider<bool>((ref) => true);

/// Lightweight frame template — avoids rebuilding the full camera host.
final guidedFrameTemplateProvider =
    StateProvider<PhotoFrameTemplate?>((ref) => null);

PhotoFrameTemplate resolveGuidedFrameTemplate({
  required PhotoFrameTemplate analysisTemplate,
  PhotoFrameTemplate? override,
}) {
  return override ?? analysisTemplate;
}

void toggleGuidedCompositionVisible(WidgetRef ref) {
  final current = ref.read(guidedCompositionVisibleProvider);
  ref.read(guidedCompositionVisibleProvider.notifier).state = !current;
}

void toggleGuidedFrameVisible(WidgetRef ref) {
  final current = ref.read(guidedFrameVisibleProvider);
  ref.read(guidedFrameVisibleProvider.notifier).state = !current;
}

/// Cycles template on the fast provider; persists to analysis after the frame.
void cycleGuidedFrameTemplate(
  WidgetRef ref, {
  required PhotoFrameTemplate current,
}) {
  markGuidedUserActivity(ref);
  final next = current.next;
  ref.read(guidedFrameTemplateProvider.notifier).state = next;
  SchedulerBinding.instance.scheduleFrameCallback((_) {
    ref.read(referenceAnalysisProvider.notifier).setFrameTemplate(next);
  });
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