import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';

/// When enabled in settings, runs live scene analysis once after the view stabilizes.
class LiveSceneAutoAnalyzer extends ConsumerStatefulWidget {
  const LiveSceneAutoAnalyzer({super.key});

  @override
  ConsumerState<LiveSceneAutoAnalyzer> createState() =>
      _LiveSceneAutoAnalyzerState();
}

class _LiveSceneAutoAnalyzerState extends ConsumerState<LiveSceneAutoAnalyzer> {
  DateTime? _lastTriggered;
  static const _cooldown = Duration(seconds: 45);

  @override
  Widget build(BuildContext context) {
    final autoEnabled = ref.watch(autoLiveSceneAnalysisProvider);

    ref.listen<SceneStabilityStatus>(sceneStabilityProvider, (previous, next) {
      if (!autoEnabled) {
        return;
      }

      final wasStable = previous?.state == SceneStabilityState.stable;
      final isStable = next.state == SceneStabilityState.stable;
      if (wasStable || !isStable) {
        return;
      }

      final now = DateTime.now();
      if (_lastTriggered != null &&
          now.difference(_lastTriggered!) < _cooldown) {
        return;
      }

      if (ref.read(liveSceneAnalyzingProvider) ||
          ref.read(isCapturingProvider) ||
          ref.read(isBurstingProvider) ||
          ref.read(isCameraUiInteractionPausedProvider)) {
        return;
      }

      if (ref.read(shouldSkipLiveAnalysisProvider) &&
          ref.read(liveSceneAnalysisProvider).value != null) {
        return;
      }

      _lastTriggered = now;
      Future.microtask(() {
        ref
            .read(liveSceneAnalysisProvider.notifier)
            .analyzeCurrentScene(manual: false);
      });
    });

    return const SizedBox.shrink();
  }
}