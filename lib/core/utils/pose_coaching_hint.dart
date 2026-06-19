import '../l10n/generated/app_localizations.dart';
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