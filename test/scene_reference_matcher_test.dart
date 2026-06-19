import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/scene_reference_matcher_service.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_analysis_result.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const matcher = SceneReferenceMatcherService();

  PhotoAnalysisResult analysis({
    required String sceneTypeKey,
    required double brightness,
    double aspect = 0.75,
  }) {
    return PhotoAnalysisResult(
      sourceAspectRatio: aspect,
      brightness: brightness,
      subjectFillRatio: 0.2,
      recommendedFrame: PhotoFrameTemplate.portraitPost,
      guidance: const CameraGuidance(
        frameTemplate: PhotoFrameTemplate.portraitPost,
        overlayType: CompositionOverlayType.ruleOfThirds,
        subjectTargetRect: Rect.fromLTWH(0.25, 0.12, 0.5, 0.76),
        suggestedZoom: 1,
        angleDegrees: 0,
        exposureEv: 0,
        framingHintKey: 'hintFramingCenter',
        exposureHintKey: 'hintExposureBalanced',
        distanceHintKey: 'hintDistanceGood',
        angleHintKey: 'hintAngleLevel',
      ),
      sceneTypeKey: sceneTypeKey,
      imageBytes: Uint8List(0),
    );
  }

  test('dark scene prefers neon reference', () {
    final sample = matcher.match(
      analysis(sceneTypeKey: 'scenePortrait', brightness: 0.28),
    );
    expect(sample.id, 'checkin_neon_city');
  });

  test('bright portrait prefers café or brunch reference', () {
    final sample = matcher.match(
      analysis(sceneTypeKey: 'scenePortrait', brightness: 0.55),
    );
    expect(
      ['checkin_cafe', 'checkin_brunch', 'checkin_street_portrait'],
      contains(sample.id),
    );
  });

  test('landscape scene prefers travel reference', () {
    final sample = matcher.match(
      analysis(
        sceneTypeKey: 'sceneLandscape',
        brightness: 0.62,
        aspect: 0.9,
      ),
    );
    expect(sample.id, 'checkin_travel_alps');
  });
}