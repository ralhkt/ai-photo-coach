import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../../core/utils/image_downscaler.dart';
import '../../../models/photo_analysis_result.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../scene_stabilization/services/camera_frame_monitor.dart';
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

  Future<void> analyzeCurrentScene() async {
    if (state.isLoading) {
      return;
    }

    if (_isCameraBusy) {
      state = AsyncError(
        LiveSceneAnalysisException(LiveSceneAnalysisFailure.cameraBusy),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();
    var streamResumed = false;

    try {
      final controller = ref.read(cameraControllerProvider).value;
      if (controller == null || !controller.value.isInitialized) {
        throw LiveSceneAnalysisException(
          LiveSceneAnalysisFailure.cameraNotReady,
        );
      }

      final monitor = ref.read(cameraFrameMonitorProvider);
      await monitor.stop();

      Uint8List? bytes;
      try {
        bytes =
            await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();
      } finally {
        await monitor.start(controller);
        streamResumed = true;
      }

      if (bytes == null || bytes.isEmpty) {
        throw LiveSceneAnalysisException(
          LiveSceneAnalysisFailure.captureFailed,
        );
      }

      final optimizedBytes = ImageDownscaler.downscale(bytes, maxSide: 960);
      final result =
          await ref.read(imageAnalyzerProvider).analyze(optimizedBytes);
      final guidance = result.guidance;

      ref.read(overlayTypeProvider.notifier).state = guidance.overlayType;
      ref.read(overlayVisibleProvider.notifier).state = true;
      await ref
          .read(cameraControllerProvider.notifier)
          .applyLiveSceneAdvice(guidance);

      ref.read(performanceTrackerProvider).record(
            'live_scene_analysis',
            stopwatch.elapsedMilliseconds,
            budgetMs: PerformanceBudget.sessionTotalAnalysisMs,
          );

      state = AsyncData(result);
    } on LiveSceneAnalysisException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } catch (error, stackTrace) {
      if (!streamResumed) {
        final controller = ref.read(cameraControllerProvider).value;
        if (controller != null && controller.value.isInitialized) {
          await ref.read(cameraFrameMonitorProvider).start(controller);
        }
      }
      state = AsyncError(
        LiveSceneAnalysisException(LiveSceneAnalysisFailure.analysisFailed),
        stackTrace,
      );
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}