import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_providers.dart';
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
  Timer? _iosReadyTimer;
  static const _cooldown = Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    // iOS pHash poller is disabled — fall back to a one-shot delay after open.
    if (!kIsWeb && Platform.isIOS) {
      _iosReadyTimer = Timer(const Duration(seconds: 4), _tryAutoAnalyzeOnce);
    }
  }

  @override
  void dispose() {
    _iosReadyTimer?.cancel();
    super.dispose();
  }

  void _tryAutoAnalyzeOnce() {
    if (!mounted) {
      return;
    }
    if (!ref.read(autoLiveSceneAnalysisProvider)) {
      return;
    }
    if (_lastTriggered != null) {
      return;
    }
    _triggerAutoAnalyze();
  }

  void _triggerAutoAnalyze() {
    if (!_canAutoAnalyze()) {
      return;
    }

    _lastTriggered = DateTime.now();
    Future.microtask(() {
      ref
          .read(liveSceneAnalysisProvider.notifier)
          .analyzeCurrentScene(manual: false);
    });
  }

  bool _canAutoAnalyze() {
    if (!ref.read(autoLiveSceneAnalysisProvider)) {
      return false;
    }
    if (ref.read(liveSceneAnalyzingProvider) ||
        ref.read(isCapturingProvider) ||
        ref.read(isBurstingProvider) ||
        ref.read(isCameraUiInteractionPausedProvider)) {
      return false;
    }
    if (ref.read(shouldSkipLiveAnalysisProvider) &&
        ref.read(liveSceneAnalysisProvider).value != null) {
      return false;
    }
    final controller = ref.read(cameraControllerProvider).value;
    return controller != null && controller.value.isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    final autoEnabled = ref.watch(autoLiveSceneAnalysisProvider);

    ref.listen<bool>(autoLiveSceneAnalysisProvider, (previous, next) {
      if (next && previous != true) {
        _tryAutoAnalyzeOnce();
      }
    });

    ref.listen(cameraControllerProvider, (previous, next) {
      if (!autoEnabled || (!kIsWeb && Platform.isIOS)) {
        return;
      }
      final wasReady = previous?.value?.value.isInitialized == true;
      final isReady = next.value?.value.isInitialized == true;
      if (!wasReady && isReady) {
        _iosReadyTimer?.cancel();
        _iosReadyTimer = Timer(const Duration(seconds: 3), _tryAutoAnalyzeOnce);
      }
    });

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

      _triggerAutoAnalyze();
    });

    return const SizedBox.shrink();
  }
}