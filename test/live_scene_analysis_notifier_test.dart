import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/camera/providers/camera_settings_provider.dart';
import 'package:ai_photo_coach/features/camera/providers/live_scene_analysis_provider.dart';
import 'package:ai_photo_coach/features/scene_stabilization/providers/scene_stability_provider.dart';
import 'package:ai_photo_coach/models/app_settings.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/ml_detection_result.dart';
import 'package:ai_photo_coach/models/photo_analysis_result.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveSceneAnalysisNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('camera busy keeps prior advice while reporting error', () async {
      final analysis = _sampleAnalysis();
      await _primeWithAdvice(container, analysis);
      container.read(isBurstingProvider.notifier).state = true;

      await container
          .read(liveSceneAnalysisProvider.notifier)
          .analyzeCurrentScene();

      expect(container.read(liveSceneAnalysisProvider).value, analysis);
      expect(
        container.read(liveSceneAnalysisErrorProvider),
        LiveSceneAnalysisFailure.cameraBusy,
      );
    });

    test('camera busy reports error without entering loading state', () async {
      container.read(isBurstingProvider.notifier).state = true;

      await container
          .read(liveSceneAnalysisProvider.notifier)
          .analyzeCurrentScene();

      expect(
        container.read(liveSceneAnalysisErrorProvider),
        LiveSceneAnalysisFailure.cameraBusy,
      );
      expect(container.read(liveSceneAnalyzingProvider), isFalse);
      expect(container.read(liveSceneAnalysisProvider).isLoading, isFalse);
    });

    test('clear resets error and analyzing flags', () {
      container.read(liveSceneAnalysisErrorProvider.notifier).state =
          LiveSceneAnalysisFailure.analysisFailed;
      container.read(liveSceneAnalyzingProvider.notifier).state = true;

      container.read(liveSceneAnalysisProvider.notifier).clear();

      expect(container.read(liveSceneAnalysisErrorProvider), isNull);
      expect(container.read(liveSceneAnalyzingProvider), isFalse);
      expect(container.read(liveSceneAnalysisProvider).value, isNull);
    });

    test('auto analyze skips when scene is stable and advice exists', () async {
      final analysis = _sampleAnalysis();
      container.read(sceneStabilityProvider.notifier).reportStable(
            hammingDistance: 2,
          );
      await _primeWithAdvice(container, analysis);

      await container
          .read(liveSceneAnalysisProvider.notifier)
          .analyzeCurrentScene(manual: false);

      expect(container.read(liveSceneAnalyzingProvider), isFalse);
      expect(container.read(liveSceneAnalysisErrorProvider), isNull);
    });

    test('manual analyze runs even when scene is stable and advice exists',
        () async {
      await _primeWithAdvice(container, _sampleAnalysis());
      container.read(sceneStabilityProvider.notifier).reportStable(
            hammingDistance: 2,
          );
      container.read(isBurstingProvider.notifier).state = true;

      await container
          .read(liveSceneAnalysisProvider.notifier)
          .analyzeCurrentScene(manual: true);

      expect(
        container.read(liveSceneAnalysisErrorProvider),
        LiveSceneAnalysisFailure.cameraBusy,
      );
    });
  });
}

Future<void> _primeWithAdvice(
  ProviderContainer container,
  PhotoAnalysisResult analysis,
) async {
  await container.read(liveSceneAnalysisProvider.future);
  container.read(liveSceneAnalysisProvider.notifier).state =
      AsyncData(analysis);
}

PhotoAnalysisResult _sampleAnalysis() {
  return PhotoAnalysisResult(
    sourceAspectRatio: 0.75,
    brightness: 0.5,
    subjectFillRatio: 0.3,
    recommendedFrame: PhotoFrameTemplate.portraitPost,
    guidance: const CameraGuidance(
      frameTemplate: PhotoFrameTemplate.portraitPost,
      overlayType: CompositionOverlayType.ruleOfThirds,
      subjectTargetRect: Rect.fromLTWH(0.2, 0.2, 0.6, 0.6),
      suggestedZoom: 1,
      angleDegrees: 5,
      exposureEv: 0,
      framingHintKey: 'hintFramingCenter',
      exposureHintKey: 'hintExposureBalanced',
      distanceHintKey: 'hintDistanceGood',
      angleHintKey: 'hintAngleTiltUp',
      subjectShape: SubjectShapeKind.rectangle,
    ),
    sceneTypeKey: 'scenePortrait',
    imageBytes: Uint8List(0),
    mlDetection: const MlDetectionResult(
      source: 'heuristic_fallback',
      inferenceMs: 12,
      aestheticScore: 0.72,
    ),
  );
}