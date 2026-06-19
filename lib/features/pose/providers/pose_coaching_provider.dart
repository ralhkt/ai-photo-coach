import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings_provider.dart';
import '../../../models/shoot_session.dart';
import '../../camera/providers/live_scene_analysis_provider.dart';
import '../../session/providers/shoot_session_provider.dart';
import '../models/pose_coaching_result.dart';
import '../services/pose_coaching_service.dart';

final poseCoachingServiceProvider = Provider<PoseCoachingService>((ref) {
  final service = PoseCoachingService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Latest unified coaching output for camera overlay chips.
final poseCoachingResultProvider =
    StateProvider<PoseCoachingResult?>((ref) => null);

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