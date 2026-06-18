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
    this.bodyPartGuides,
    this.headCenter,
  });

  final PhotoFrameTemplate template;
  final Rect cropRect;
  final Rect subjectZone;
  final double safePadding;
  final SubjectShapeKind subjectShape;
  final Path? subjectSilhouettePath;
  final MappedBodyPartGuides? bodyPartGuides;
  final Offset? headCenter;
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
    if (guidance.subjectShape == SubjectShapeKind.humanSilhouette) {
      final points = guidance.subjectSilhouettePoints;
      if (points != null && points.length >= 8) {
        silhouettePath = _mapSilhouettePath(
          points,
          cropRect,
          sourceAspectRatio: sourceAspectRatio,
          targetAspectRatio: targetAspectRatio,
          remapForCropArea: viewportIsCropArea,
        );
      } else {
        final templatePoints = _shapeBuilder.mapTemplateToSubject(
          guidance.subjectTargetRect,
        );
        silhouettePath = _mapSilhouettePath(
          templatePoints,
          cropRect,
          sourceAspectRatio: sourceAspectRatio,
          targetAspectRatio: targetAspectRatio,
          remapForCropArea: viewportIsCropArea,
        );
      }
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

    return GeneratedFrameSpec(
      template: template,
      cropRect: cropRect,
      subjectZone: subjectZone,
      safePadding: safePadding,
      subjectShape: guidance.subjectShape,
      subjectSilhouettePath: silhouettePath,
      bodyPartGuides: bodyParts,
      headCenter: headCenter,
    );
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

  Path _mapSilhouettePath(
    List<Offset> imageNormalizedPoints,
    Rect cropRect, {
    double? sourceAspectRatio,
    double? targetAspectRatio,
    bool remapForCropArea = false,
  }) {
    final mappedPoints = imageNormalizedPoints
        .map(
          (point) => _mapImageNormalizedPoint(
            point,
            cropRect,
            sourceAspectRatio: sourceAspectRatio,
            targetAspectRatio: targetAspectRatio,
            remapForCropArea: remapForCropArea,
          ),
        )
        .toList();
    return _shapeBuilder.pointsToSmoothPath(mappedPoints);
  }
}