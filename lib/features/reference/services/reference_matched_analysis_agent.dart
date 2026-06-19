import '../../../models/camera_guidance.dart';
import '../../../models/deep_photo_insights.dart';
import '../../../models/photo_analysis_result.dart';
import '../../../models/subject_shape_kind.dart';
import '../../frames/services/poze_frame_layout.dart';
import 'photo_analysis_agent.dart';
import 'reference_guidance_cache.dart';
import 'scene_reference_matcher_service.dart';

/// Enriches live-scene analysis by matching a similar influencer reference photo.
class ReferenceMatchedPhotoAnalysisAgent implements PhotoAnalysisAgent {
  ReferenceMatchedPhotoAnalysisAgent({
    SceneReferenceMatcherService? matcher,
    ReferenceGuidanceCache? cache,
  })  : _matcher = matcher ?? const SceneReferenceMatcherService(),
        _cache = cache ?? ReferenceGuidanceCache();

  final SceneReferenceMatcherService _matcher;
  final ReferenceGuidanceCache _cache;

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    final sample = _matcher.match(base);
    final reference = await _cache.get(sample.id);
    final mergedGuidance = _mergeGuidance(
      live: base.guidance,
      reference: reference.guidance,
    );

    final insights = base.deepInsights;
    final enrichedInsights = insights == null
        ? DeepPhotoInsights(
            contrastScore: 0.5,
            colorTemperatureKey: 'insightColorNeutral',
            lightingDirectionKey: 'insightLightingEven',
            compositionBalanceKey: 'insightBalanceCentered',
            moodKey: 'insightMoodNatural',
            depthHintKey: 'insightDepthModerate',
            confidence: 0.62,
            detailedTips: const ['referenceMatchTip'],
            analysisSource: 'reference_matched_local',
          )
        : DeepPhotoInsights(
            contrastScore: insights.contrastScore,
            colorTemperatureKey: insights.colorTemperatureKey,
            lightingDirectionKey: insights.lightingDirectionKey,
            compositionBalanceKey: insights.compositionBalanceKey,
            moodKey: insights.moodKey,
            depthHintKey: insights.depthHintKey,
            confidence: insights.confidence,
            detailedTips: [
              'referenceMatchTip',
              ...insights.detailedTips,
            ],
            analysisSource: 'reference_matched_local',
          );

    return PhotoAnalysisResult(
      sourceAspectRatio: base.sourceAspectRatio,
      brightness: base.brightness,
      subjectFillRatio: base.subjectFillRatio,
      recommendedFrame: reference.recommendedFrame,
      guidance: mergedGuidance,
      sceneTypeKey: base.sceneTypeKey,
      imageBytes: base.imageBytes,
      userSceneType: base.userSceneType,
      deepInsights: enrichedInsights,
      mlDetection: base.mlDetection,
      matchedReferenceSampleId: sample.id,
      matchedReferenceTitleKey: sample.titleKey,
      matchedReferenceImageBytes: reference.imageBytes,
      exif: base.exif,
      subjectDetectionReliable: base.subjectDetectionReliable,
    );
  }

  CameraGuidance _mergeGuidance({
    required CameraGuidance live,
    required CameraGuidance reference,
  }) {
    final poseRect = PozeFrameLayout.stabilizeForOverlay(
      reference.subjectTargetRect,
    );

    return live.copyWith(
      frameTemplate: reference.frameTemplate,
      overlayType: reference.overlayType,
      subjectTargetRect: poseRect,
      subjectShape: reference.subjectShape == SubjectShapeKind.humanSilhouette
          ? SubjectShapeKind.humanSilhouette
          : live.subjectShape,
      subjectSilhouettePoints: reference.subjectSilhouettePoints,
      bodyPartGuides: reference.bodyPartGuides,
      framingHintKey: live.framingHintKey,
      exposureHintKey: live.exposureHintKey,
      distanceHintKey: live.distanceHintKey,
      angleHintKey: live.angleHintKey,
      suggestedZoom: live.suggestedZoom,
      angleDegrees: live.angleDegrees,
      exposureEv: live.exposureEv,
    );
  }
}