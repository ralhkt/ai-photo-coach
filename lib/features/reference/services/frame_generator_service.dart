import 'dart:ui';

import '../../../core/utils/viewport_letterbox.dart';
import '../../../models/body_part_guides.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/subject_shape_kind.dart';
import 'human_frame_shape_builder.dart';

class GeneratedFrameSpec {
  const GeneratedFrameSpec({
    required this.template,
    required this.cropRect,
    required this.subjectZone,
    required this.safePadding,
    this.subjectShape = SubjectShapeKind.rectangle,
    this.subjectSilhouettePath,
    this.viewportSilhouettePoints = const [],
    this.bodyPartGuides,
    this.headCenter,
    this.poseSkeletonSegments = const [],
    this.viewportSkeletonSegments = const [],
  });

  final PhotoFrameTemplate template;
  final Rect cropRect;
  final Rect subjectZone;
  final double safePadding;
  final SubjectShapeKind subjectShape;
  final Path? subjectSilhouettePath;

  /// Silhouette polyline in 0–1 coords relative to [cropRect] (native overlay).
  final List<Offset> viewportSilhouettePoints;
  final MappedBodyPartGuides? bodyPartGuides;
  final Offset? headCenter;

  /// Mapped art-student skeleton lines in crop canvas coordinates.
  final List<List<Offset>> poseSkeletonSegments;

  /// Skeleton segments in 0–1 coords relative to [cropRect] (native overlay).
  final List<List<Offset>> viewportSkeletonSegments;
}

class MappedBodyPartGuides {
  const MappedBodyPartGuides({
    required this.headOval,
    required this.shoulders,
    required this.torso,
    required this.hips,
  });

  final Rect headOval;
  final Rect shoulders;
  final Rect torso;
  final Rect hips;
}

class FrameGeneratorService {
  FrameGeneratorService({HumanFrameShapeBuilder? shapeBuilder})
      : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder();

  final HumanFrameShapeBuilder _shapeBuilder;

  GeneratedFrameSpec generate({
    required PhotoFrameTemplate template,
    required CameraGuidance guidance,
    required Size viewportSize,
    bool viewportIsCropArea = false,
    double? sourceAspectRatio,
    double? targetAspectRatio,
  }) {
    final cropRect = viewportIsCropArea
        ? (Offset.zero & viewportSize)
        : _cropRectForTemplate(template, viewportSize);
    final subjectZone = _mapImageNormalizedRect(
      guidance.subjectTargetRect,
      cropRect,
      sourceAspectRatio: sourceAspectRatio,
      targetAspectRatio: targetAspectRatio,
      remapForCropArea: viewportIsCropArea,
    );
    final safePadding = switch (template) {
      PhotoFrameTemplate.story => 0.06,
      PhotoFrameTemplate.portraitPost => 0.05,
      PhotoFrameTemplate.squarePost => 0.04,
      PhotoFrameTemplate.landscapePost => 0.04,
      PhotoFrameTemplate.classicPortrait => 0.05,
    };

    Path? silhouettePath;
    var viewportSilhouettePoints = const <Offset>[];
    if (guidance.subjectShape == SubjectShapeKind.humanSilhouette) {
      final points = guidance.subjectSilhouettePoints;
      final List<Offset> sourcePoints;
      if (points != null && points.length >= 8) {
        sourcePoints = points;
      } else {
        sourcePoints = _shapeBuilder.mapTemplateToSubject(
          guidance.subjectTargetRect,
        );
      }

      final mappedPoints = sourcePoints
          .map(
            (point) => _mapImageNormalizedPoint(
              point,
              cropRect,
              sourceAspectRatio: sourceAspectRatio,
              targetAspectRatio: targetAspectRatio,
              remapForCropArea: viewportIsCropArea,
            ),
          )
          .toList(growable: false);
      silhouettePath = _shapeBuilder.pointsToSmoothPath(mappedPoints);
      viewportSilhouettePoints =
          _normalizeToViewport(mappedPoints, cropRect);
    }

    MappedBodyPartGuides? bodyParts;
    Offset? headCenter;
    if (guidance.bodyPartGuides != null) {
      bodyParts = _mapBodyPartGuidesToCrop(
        guidance.bodyPartGuides!,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: viewportIsCropArea,
      );
      headCenter = bodyParts.headOval.center;
    }

    final skeletonSegments = _mapSkeletonSegments(
      guidance.subjectPoseSkeleton,
      cropRect,
      sourceAspectRatio: sourceAspectRatio,
      targetAspectRatio: targetAspectRatio,
      remapForCropArea: viewportIsCropArea,
    );
    final viewportSkeletonSegments = [
      for (final segment in skeletonSegments)
        _normalizeToViewport(segment, cropRect),
    ];

    return GeneratedFrameSpec(
      template: template,
      cropRect: cropRect,
      subjectZone: subjectZone,
      safePadding: safePadding,
      subjectShape: guidance.subjectShape,
      subjectSilhouettePath: silhouettePath,
      viewportSilhouettePoints: viewportSilhouettePoints,
      bodyPartGuides: bodyParts,
      headCenter: headCenter,
      poseSkeletonSegments: skeletonSegments,
      viewportSkeletonSegments: viewportSkeletonSegments,
    );
  }

  List<Offset> _normalizeToViewport(List<Offset> cropPoints, Rect cropRect) {
    if (cropRect.width <= 0 || cropRect.height <= 0) {
      return cropPoints;
    }
    return [
      for (final point in cropPoints)
        Offset(
          ((point.dx - cropRect.left) / cropRect.width).clamp(0.0, 1.0),
          ((point.dy - cropRect.top) / cropRect.height).clamp(0.0, 1.0),
        ),
    ];
  }

  List<List<Offset>> _mapSkeletonSegments(
    List<List<Offset>>? segments,
    Rect cropRect, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    if (segments == null || segments.isEmpty) {
      return const [];
    }

    return [
      for (final segment in segments)
        if (segment.length >= 2)
          [
            for (final point in segment)
              _mapImageNormalizedPoint(
                point,
                cropRect,
                sourceAspectRatio: sourceAspectRatio,
                targetAspectRatio: targetAspectRatio,
                remapForCropArea: remapForCropArea,
              ),
          ],
    ];
  }

  MappedBodyPartGuides _mapBodyPartGuidesToCrop(
    BodyPartGuides guides,
    Rect cropRect, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    return MappedBodyPartGuides(
      headOval: _mapImageNormalizedRect(
        guides.headOval,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
      shoulders: _mapImageNormalizedRect(
        guides.shoulders,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
      torso: _mapImageNormalizedRect(
        guides.torso,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
      hips: _mapImageNormalizedRect(
        guides.hips,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
    );
  }

  Rect _mapImageNormalizedRect(
    Rect imageRect,
    Rect cropRect, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    return Rect.fromPoints(
      _mapImageNormalizedPoint(
        imageRect.topLeft,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
      _mapImageNormalizedPoint(
        imageRect.bottomRight,
        cropRect,
        sourceAspectRatio: sourceAspectRatio,
        targetAspectRatio: targetAspectRatio,
        remapForCropArea: remapForCropArea,
      ),
    );
  }

  Offset _mapImageNormalizedPoint(
    Offset imagePoint,
    Rect cropRect, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    final normalized = _remapSourcePoint(
      imagePoint,
      sourceAspectRatio: sourceAspectRatio,
      targetAspectRatio: targetAspectRatio,
      remapForCropArea: remapForCropArea,
    );
    return Offset(
      cropRect.left + normalized.dx * cropRect.width,
      cropRect.top + normalized.dy * cropRect.height,
    );
  }

  Offset _remapSourcePoint(
    Offset imagePoint, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    if (!remapForCropArea ||
        sourceAspectRatio == null ||
        targetAspectRatio == null) {
      return imagePoint;
    }

    return ViewportLetterbox.mapNormalizedPointCoverFit(
      imagePoint,
      sourceAspectRatio: sourceAspectRatio,
      targetAspectRatio: targetAspectRatio,
    );
  }

  Rect _cropRectForTemplate(PhotoFrameTemplate template, Size viewportSize) {
    return ViewportLetterbox.cropRectForRatio(
      template.aspectRatio,
      viewportSize,
    );
  }

}