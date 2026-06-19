import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings_provider.dart';
import '../../../models/shoot_session.dart';
import '../../reference/services/reference_photo_pose_analyzer.dart';
import '../../camera/providers/live_scene_analysis_provider.dart';
import '../../session/providers/shoot_session_provider.dart';
import '../data/trendy_template_catalog.dart';
import '../models/pose_coaching_result.dart';
import '../models/trendy_photo_template.dart';
import '../services/pose_coaching_service.dart';
import '../services/reference_pose_template_factory.dart';

final poseCoachingServiceProvider = Provider<PoseCoachingService>((ref) {
  final service = PoseCoachingService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Active trendy template selected from reference sample or crawler ingest.
final activeTrendyTemplateProvider =
    StateProvider<TrendyPhotoTemplate?>((ref) => null);

/// Latest unified coaching output for camera overlay chips.
final poseCoachingResultProvider =
    StateProvider<PoseCoachingResult?>((ref) => null);

/// Loads bundled trendy metadata when user picks a reference sample.
void loadTrendyTemplateForSample(WidgetRef ref, String sampleId) {
  ref.read(activeTrendyTemplateProvider.notifier).state =
      trendyTemplateForSample(sampleId);
}

void clearActiveTrendyTemplate(WidgetRef ref) {
  ref.read(activeTrendyTemplateProvider.notifier).state = null;
}

/// Uses the uploaded reference photo pose as the live coaching target.
void loadReferencePoseTemplate(Ref ref, ReferencePoseAnalysis? pose) {
  if (pose == null || !pose.hasTemplateLandmarks) {
    ref.read(activeTrendyTemplateProvider.notifier).state = null;
    return;
  }

  ref.read(activeTrendyTemplateProvider.notifier).state =
      ReferencePoseTemplateFactory.fromLandmarks(pose.templateLandmarks);
}

/// Whether the background pose coaching loop should run.
bool shouldRunPoseCoaching({
  required ShootSession? session,
  required bool hasLiveSceneAnalysis,
  required bool powerSaveEnabled,
}) {
  if (powerSaveEnabled) {
    return false;
  }

  if (session?.mode == ShootSessionMode.guided) {
    return true;
  }

  return hasLiveSceneAnalysis;
}

final poseCoachingShouldRunProvider = Provider<bool>((ref) {
  final session = ref.watch(shootSessionProvider);
  final hasLiveAdvice = ref.watch(liveSceneAnalysisProvider).value != null;
  final powerSave = ref.watch(powerSaveEnabledProvider);
  return shouldRunPoseCoaching(
    session: session,
    hasLiveSceneAnalysis: hasLiveAdvice,
    powerSaveEnabled: powerSave,
  );
});