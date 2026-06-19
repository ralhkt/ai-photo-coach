import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/vision_api_config.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/photo_analysis_result.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/scene_type.dart';
import '../../ml/providers/ml_providers.dart';
import '../services/frame_generator_service.dart';
import '../services/image_analyzer_service.dart';
import '../services/photo_analysis_agent_factory.dart';

final imageAnalyzerProvider = Provider<ImageAnalyzerService>((ref) {
  return ImageAnalyzerService(
    visionAnalyzer: ref.watch(visionAnalyzerProvider),
    agent: createPhotoAnalysisAgent(),
  );
});

final visionApiConfiguredProvider = Provider<bool>(
  (ref) => VisionApiConfig.isVisionConfigured,
);

final frameGeneratorProvider = Provider<FrameGeneratorService>(
  (ref) => FrameGeneratorService(),
);

final selectedSceneTypeProvider = StateProvider<SceneType>(
  (ref) => SceneType.auto,
);

final referenceAnalysisProvider =
    AsyncNotifierProvider<ReferenceAnalysisNotifier, PhotoAnalysisResult?>(
  ReferenceAnalysisNotifier.new,
);

class ReferenceAnalysisNotifier extends AsyncNotifier<PhotoAnalysisResult?> {
  @override
  Future<PhotoAnalysisResult?> build() async => null;

  Future<void> analyze(
    Uint8List bytes, {
    SceneType userSceneType = SceneType.auto,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(imageAnalyzerProvider).analyze(
            bytes,
            userSceneType: userSceneType,
          );
    });
  }

  void clear() {
    state = const AsyncData(null);
  }

  void setFrameTemplate(PhotoFrameTemplate template) {
    final current = state.value;
    if (current == null) {
      return;
    }

    final guidance = current.guidance;
    state = AsyncData(
      PhotoAnalysisResult(
        sourceAspectRatio: current.sourceAspectRatio,
        brightness: current.brightness,
        subjectFillRatio: current.subjectFillRatio,
        recommendedFrame: template,
        guidance: CameraGuidance(
          frameTemplate: template,
          overlayType: guidance.overlayType,
          subjectTargetRect: guidance.subjectTargetRect,
          suggestedZoom: guidance.suggestedZoom,
          angleDegrees: guidance.angleDegrees,
          exposureEv: guidance.exposureEv,
          framingHintKey: guidance.framingHintKey,
          exposureHintKey: guidance.exposureHintKey,
          distanceHintKey: guidance.distanceHintKey,
          angleHintKey: guidance.angleHintKey,
          subjectShape: guidance.subjectShape,
          subjectSilhouettePoints: guidance.subjectSilhouettePoints,
          bodyPartGuides: guidance.bodyPartGuides,
        ),
        sceneTypeKey: current.sceneTypeKey,
        imageBytes: current.imageBytes,
        userSceneType: current.userSceneType,
        deepInsights: current.deepInsights,
        mlDetection: current.mlDetection,
        exif: current.exif,
        subjectDetectionReliable: current.subjectDetectionReliable,
      ),
    );
  }
}