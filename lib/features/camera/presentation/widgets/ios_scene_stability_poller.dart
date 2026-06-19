import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/performance/performance_budget.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../../scene_stabilization/services/scene_change_detector.dart';
import '../../../../models/shoot_session.dart';
import '../../models/preview_capture_request.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import '../../../pose/providers/pose_coaching_provider.dart';
import '../../../session/providers/shoot_session_provider.dart';

/// iOS pHash polling — image stream deadlocks with preview + takePicture.
class IosSceneStabilityPoller extends ConsumerStatefulWidget {
  const IosSceneStabilityPoller({super.key});

  @override
  ConsumerState<IosSceneStabilityPoller> createState() =>
      _IosSceneStabilityPollerState();
}

class _IosSceneStabilityPollerState extends ConsumerState<IosSceneStabilityPoller> {
  Timer? _timer;
  bool _tickInFlight = false;
  final SceneChangeDetector _detector = SceneChangeDetector();
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isIOS) {
      _timer = Timer.periodic(const Duration(milliseconds: 5000), (_) {
        unawaited(_tick());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted || _tickInFlight) {
      return;
    }

    final session = ref.read(shootSessionProvider);
    if (session?.mode == ShootSessionMode.guided) {
      return;
    }

    if (!ref.read(autoLiveSceneAnalysisProvider)) {
      return;
    }

    if (ref.read(poseCoachingShouldRunProvider)) {
      return;
    }

    if (ref.read(isPreviewSamplingProvider) ||
        ref.read(cameraSwitchingProvider) ||
        ref.read(isCameraUiInteractionPausedProvider)) {
      return;
    }

    final powerSave = ref.read(powerSaveEnabledProvider);
    final intervalMs = powerSave
        ? PerformanceBudget.phashFrameIntervalPowerSaveMs
        : PerformanceBudget.phashFrameIntervalMs;
    final now = DateTime.now();
    if (now.difference(_lastProcessed) < Duration(milliseconds: intervalMs)) {
      return;
    }

    if (ref.read(isCapturingProvider) ||
        ref.read(isBurstingProvider) ||
        ref.read(liveSceneAnalyzingProvider) ||
        ref.read(timerCountdownProvider) != null) {
      return;
    }

    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _tickInFlight = true;
    try {
      final bytes = await ref
          .read(cameraControllerProvider.notifier)
          .capturePreviewFrame(PreviewCaptureRequest.scene);
      if (!mounted || bytes == null || bytes.isEmpty) {
        return;
      }

      _lastProcessed = now;
      final result = _detector.evaluateFromJpeg(bytes);
      final notifier = ref.read(sceneStabilityProvider.notifier);
      if (result.isStable) {
        notifier.reportStable(hammingDistance: result.hammingDistance);
      } else {
        notifier.reportChanged(hammingDistance: result.hammingDistance);
      }
    } catch (error) {
      debugPrint('IosSceneStabilityPoller: $error');
    } finally {
      _tickInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}