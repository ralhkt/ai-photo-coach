import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../../models/photo_analysis_result.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../scene_stabilization/services/camera_frame_monitor.dart';
import 'camera_providers.dart';

final liveSceneAnalysisProvider = AutoDisposeAsyncNotifierProvider<
    LiveSceneAnalysisNotifier, PhotoAnalysisResult?>(
  LiveSceneAnalysisNotifier.new,
);

class LiveSceneAnalysisNotifier
    extends AutoDisposeAsyncNotifier<PhotoAnalysisResult?> {
  @override
  Future<PhotoAnalysisResult?> build() async => null;

  Future<void> analyzeCurrentScene() async {
    if (state.isLoading) {
      return;
    }

    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();

    try {
      final controller = ref.read(cameraControllerProvider).value;
      if (controller == null || !controller.value.isInitialized) {
        throw StateError('camera_not_ready');
      }

      final monitor = ref.read(cameraFrameMonitorProvider);
      await monitor.stop();

      Uint8List? bytes;
      try {
        bytes =
            await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();
      } finally {
        await monitor.start(controller);
      }

      if (bytes == null) {
        throw StateError('capture_failed');
      }

      final result = await ref.read(imageAnalyzerProvider).analyze(bytes);
      final guidance = result.guidance;

      ref.read(overlayTypeProvider.notifier).state = guidance.overlayType;
      ref.read(overlayVisibleProvider.notifier).state = true;
      await ref
          .read(cameraControllerProvider.notifier)
          .applyGuidanceSettings(guidance);

      ref.read(performanceTrackerProvider).record(
            'live_scene_analysis',
            stopwatch.elapsedMilliseconds,
            budgetMs: PerformanceBudget.sessionTotalAnalysisMs,
          );

      state = AsyncData(result);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}