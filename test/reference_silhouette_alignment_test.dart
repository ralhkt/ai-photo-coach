import 'dart:io';
import 'dart:ui';

import 'package:ai_photo_coach/core/utils/coaching_guidance_helper.dart';
import 'package:ai_photo_coach/core/utils/pose_contour_stabilizer.dart';
import 'package:ai_photo_coach/core/utils/reference_cover_fit_mapper.dart';
import 'package:ai_photo_coach/features/frames/presentation/reference_image_cache.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_ml_vision_analyzer.dart';

Rect _bounds(List<Offset> points) {
  var minX = double.infinity;
  var maxX = -double.infinity;
  var minY = double.infinity;
  var maxY = -double.infinity;
  for (final point in points) {
    minX = minX < point.dx ? minX : point.dx;
    maxX = maxX > point.dx ? maxX : point.dx;
    minY = minY < point.dy ? minY : point.dy;
    maxY = maxY > point.dy ? maxY : point.dy;
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final samples = [
    'checkin_cafe',
    'checkin_neon_city',
    'checkin_brunch',
    'checkin_street_portrait',
  ];

  for (final name in samples) {
    test('$name Photoshop-style outline stays on decoded photo', () async {
      final bytes =
          await File('assets/reference_samples/$name.jpg').readAsBytes();
      final analysis = await ImageAnalyzerService(
        visionAnalyzer: const FakeMlVisionAnalyzer(),
      ).analyze(
        bytes,
        userSceneType: SceneType.portrait,
      );

      final guidance = analysis.guidance;
      final silhouette = guidance.subjectSilhouettePoints;
      expect(silhouette, isNotNull);
      expect(silhouette!.length, greaterThan(8));

      final image = await decodeReferenceImage(bytes);
      expect(image, isNotNull);

      const cropRect = Rect.fromLTWH(0, 0, 390, 844);
      final dest = ReferenceCoverFitMapper.imageDestRect(
        cropRect: cropRect,
        imageAspectRatio: image!.width / image.height,
      );
      final mapped = ReferenceCoverFitMapper.mapContour(silhouette, dest);

      for (final point in mapped) {
        expect(dest.contains(point), isTrue);
      }

      final bounds = _bounds(mapped);
      expect(
        bounds.width > dest.width * 0.05 || bounds.height > dest.height * 0.05,
        isTrue,
        reason: 'selection should span a visible subject region for $name',
      );
      expect(dest.overlaps(bounds.inflate(4)), isTrue);
    });
  }

  test('guided overlay must not reuse live stabilizer history', () {
    const referenceSilhouette = [
      Offset(0.42, 0.18),
      Offset(0.58, 0.18),
      Offset(0.62, 0.45),
      Offset(0.55, 0.82),
      Offset(0.45, 0.82),
      Offset(0.38, 0.45),
      Offset(0.4, 0.3),
      Offset(0.6, 0.3),
    ];
    const referenceSubject = Rect.fromLTWH(0.35, 0.12, 0.3, 0.78);

    final stabilizer = PoseContourStabilizer(alpha: 0.32);
    stabilizer.stabilize(
      _guidance(
        subjectRect: const Rect.fromLTWH(0.55, 0.55, 0.25, 0.35),
        silhouette: const [
          Offset(0.72, 0.58),
          Offset(0.82, 0.58),
          Offset(0.85, 0.75),
          Offset(0.75, 0.88),
          Offset(0.7, 0.65),
          Offset(0.8, 0.65),
          Offset(0.74, 0.7),
          Offset(0.78, 0.72),
        ],
      ),
    );

    final polluted = CoachingGuidanceHelper().forGuidedOverlay(
      _guidance(
        subjectRect: referenceSubject,
        silhouette: referenceSilhouette,
      ),
      stabilizer: stabilizer,
    );

    final clean = CoachingGuidanceHelper().forGuidedOverlay(
      _guidance(
        subjectRect: referenceSubject,
        silhouette: referenceSilhouette,
      ),
    );

    expect(
      (polluted.subjectSilhouettePoints!.first - referenceSilhouette.first)
          .distance,
      greaterThan(0.03),
    );
    expect(clean.subjectSilhouettePoints, referenceSilhouette);
  });
}

CameraGuidance _guidance({
  required Rect subjectRect,
  required List<Offset> silhouette,
}) {
  return CameraGuidance(
    frameTemplate: PhotoFrameTemplate.portraitPost,
    overlayType: CompositionOverlayType.center,
    subjectTargetRect: subjectRect,
    suggestedZoom: 1,
    angleDegrees: 0,
    exposureEv: 0,
    framingHintKey: 'hintFramingCenter',
    exposureHintKey: 'hintExposureBalanced',
    distanceHintKey: 'hintDistanceGood',
    angleHintKey: 'hintAngleLevel',
    subjectSilhouettePoints: silhouette,
    bodyPartGuides: BodyPartGuides(
      headOval: Rect.fromCenter(
        center: Offset(subjectRect.center.dx, subjectRect.top + subjectRect.height * 0.12),
        width: subjectRect.width * 0.55,
        height: subjectRect.height * 0.14,
      ),
      shoulders: Rect.fromCenter(
        center: Offset(subjectRect.center.dx, subjectRect.top + subjectRect.height * 0.28),
        width: subjectRect.width * 0.9,
        height: subjectRect.height * 0.1,
      ),
      torso: Rect.fromCenter(
        center: Offset(subjectRect.center.dx, subjectRect.top + subjectRect.height * 0.48),
        width: subjectRect.width * 0.7,
        height: subjectRect.height * 0.28,
      ),
      hips: Rect.fromCenter(
        center: Offset(subjectRect.center.dx, subjectRect.top + subjectRect.height * 0.68),
        width: subjectRect.width * 0.75,
        height: subjectRect.height * 0.12,
      ),
    ),
  );
}