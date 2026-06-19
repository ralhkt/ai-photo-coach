import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../../core/utils/image_bytes_normalizer.dart';
import '../../../models/photo_analysis_result.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../scene_stabilization/providers/scene_stability_provider.dart';
import 'camera_capture_provider.dart';
import 'camera_providers.dart';
import 'camera_settings_provider.dart';

enum LiveSceneAnalysisFailure {
  cameraNotReady,
  cameraBusy,
  captureFailed,
  analysisFailed,
}

class LiveSceneAnalysisException implements Exception {
  LiveSceneAnalysisException(this.reason);

  final LiveSceneAnalysisFailure reason;

  @override
  String toString() => 'LiveSceneAnalysisException($reason)';
}

final liveSceneAnalysisErrorProvider =
    StateProvider<LiveSceneAnalysisFailure?>((ref) => null);

final liveSceneAnalyzingProvider = StateProvider<bool>((ref) => false);

/// True when the current/last analysis run was triggered manually (✨ button).
final liveSceneManualRunProvider = StateProvider<bool>((ref) => true);

final autoLiveSceneAnalysisProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings.autoLiveSceneAnalysis,
        orElse: () => false,
      );
});

final liveSceneAnalysisProvider = AutoDisposeAsyncNotifierProvider<
    LiveSceneAnalysisNotifier, PhotoAnalysisResult?>(
  LiveSceneAnalysisNotifier.new,
);

class LiveSceneAnalysisNotifier
    extends AutoDisposeAsyncNotifier<PhotoAnalysisResult?> {
  @override
  Future<PhotoAnalysisResult?> build() async => null;

  bool get _isCameraBusy {
    return ref.read(isBurstingProvider) ||
        ref.read(timerCountdownProvider) != null ||
        ref.read(isCapturingProvider);
  }

  void _setAnalyzing(bool value) {
    ref.read(liveSceneAnalyzingProvider.notifier).state = value;
  }

  void _setError(LiveSceneAnalysisFailure? failure) {
    ref.read(liveSceneAnalysisErrorProvider.notifier).state = failure;
  }

  void _fail(LiveSceneAnalysisFailure failure, {PhotoAnalysisResult? cached}) {
    _setError(failure);
    _setAnalyzing(false);
    if (cached != null) {
      state = AsyncData(cached);
    }
  }

  Future<void> analyzeCurrentScene({bool manual = true}) async {
    if (ref.read(liveSceneAnalyzingProvider)) {
      return;
    }

    ref.read(liveSceneManualRunProvider.notifier).state = manual;

    final cached = state.value;
    if (!manual &&
        ref.read(shouldSkipLiveAnalysisProvider) &&
        cached != null) {
      return;
    }

    if (_isCameraBusy) {
      _fail(LiveSceneAnalysisFailure.cameraBusy, cached: cached);
      return;
    }

    _setError(null);
    _setAnalyzing(true);
    if (cached == null) {
      state = const AsyncLoading();
    }

    final stopwatch = Stopwatch()..start();

    try {
      final controller = ref.read(cameraControllerProvider).value;
      if (controller == null || !controller.value.isInitialized) {
        throw LiveSceneAnalysisException(
          LiveSceneAnalysisFailure.cameraNotReady,
        );
      }

      final bytes =
          await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();

      if (bytes == null || bytes.isEmpty) {
        throw LiveSceneAnalysisException(
          LiveSceneAnalysisFailure.captureFailed,
        );
      }

      final normalizedBytes = ImageBytesNormalizer.forAnalysis(
        bytes,
        maxSide: 960,
      );
      final result = await ref.read(imageAnalyzerProvider).analyze(
            normalizedBytes,
            forLiveCoaching: true,
          );
      final guidance = result.guidance;

      ref.read(performanceTrackerProvider).record(
            'live_scene_analysis',
            stopwatch.elapsedMilliseconds,
            budgetMs: PerformanceBudget.sessionTotalAnalysisMs,
          );

      state = AsyncData(result);
      _setAnalyzing(false);

      try {
        ref.read(overlayTypeProvider.notifier).state = guidance.overlayType;
        ref.read(overlayVisibleProvider.notifier).state = true;
        await ref
            .read(cameraControllerProvider.notifier)
            .applyLiveSceneAdvice(guidance);
      } catch (error, stackTrace) {
        debugPrint('LiveSceneAnalysis: apply advice failed: $error');
        debugPrint('$stackTrace');
      }
    } on LiveSceneAnalysisException catch (error) {
      _fail(error.reason, cached: cached);
    } on FormatException catch (error, stackTrace) {
      debugPrint('LiveSceneAnalysis: decode failed: $error');
      debugPrint('$stackTrace');
      _fail(LiveSceneAnalysisFailure.captureFailed, cached: cached);
    } catch (error, stackTrace) {
      debugPrint('LiveSceneAnalysis: unexpected failure: $error');
      debugPrint('$stackTrace');
      _fail(LiveSceneAnalysisFailure.analysisFailed, cached: cached);
    }
  }

  void clear() {
    _setError(null);
    _setAnalyzing(false);
    state = const AsyncData(null);
  }
}