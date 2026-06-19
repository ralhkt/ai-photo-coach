import '../l10n/generated/app_localizations.dart';
import '../../features/pose/models/pose_coaching_result.dart';
import '../../features/pose/services/alignment_overlay_state.dart';
import '../../features/scene_stabilization/providers/scene_stability_provider.dart';

/// Dynamic Poze-style coaching copy for the camera hint pill.
String poseCoachingHint(
  AppLocalizations l10n,
  SceneStabilityStatus stability,
) {
  return switch (stability.state) {
    SceneStabilityState.stable => l10n.poseCoachMatched,
    SceneStabilityState.monitoring => l10n.poseCoachAligning,
    SceneStabilityState.changed => l10n.poseCoachAdjust,
    SceneStabilityState.idle => l10n.poseCoachAligning,
  };
}

bool isPoseAligned(SceneStabilityStatus stability) {
  return stability.state == SceneStabilityState.stable;
}

/// Prefers live pose coaching output; falls back to scene-stability copy.
String resolvePoseCoachingMessage({
  required AppLocalizations l10n,
  required SceneStabilityStatus stability,
  PoseCoachingResult? coaching,
}) {
  if (coaching != null) {
    final needsTiltOrProportionHint =
        !coaching.isLevel || coaching.proportionStatus != 'OK';
    if (needsTiltOrProportionHint && coaching.combinedGuidance.isNotEmpty) {
      return coaching.combinedGuidance;
    }
    if (coaching.poseScore > 0) {
      final phase = AlignmentOverlayState.phaseForScore(coaching.poseScore);
      return AlignmentOverlayState.toastForPhase(phase, l10n: l10n);
    }
    if (coaching.combinedGuidance.isNotEmpty) {
      return coaching.combinedGuidance;
    }
  }
  return poseCoachingHint(l10n, stability);
}

/// True when proportion, level, and template pose all pass (or scene is stable).
bool isPoseCoachingAligned({
  required SceneStabilityStatus stability,
  PoseCoachingResult? coaching,
}) {
  if (coaching != null) {
    return coaching.isLevel &&
        coaching.proportionStatus == 'OK' &&
        coaching.poseMatched;
  }
  return isPoseAligned(stability);
}