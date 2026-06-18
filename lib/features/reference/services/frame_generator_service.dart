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
  }) {
    final cropRect = _cropRectForTemplate(template, viewportSize);
    final subjectZone = _mapSubjectZone(guidance.subjectTargetRect, cropRect);
    final safePadding = switch (template) {
      PhotoFrameTemplate.story => 0.06,
      PhotoFrameTemplate.portraitPost => 0.05,
      PhotoFrameTemplate.squarePost => 0.04,
      PhotoFrameTemplate.landscapePost => 0.04,
      PhotoFrameTemplate.classicPortrait => 0.05,
    };

    final normalizedSubject = guidance.subjectTargetRect;

    Path? silhouettePath;
    if (guidance.subjectShape == SubjectShapeKind.humanSilhouette) {
      final points = guidance.subjectSilhouettePoints;
      if (points != null && points.length >= 8) {
        silhouettePath = _mapSilhouettePath(
          points,
          normalizedSubject,
          subjectZone,
        );
      } else {
        final templatePoints =
            _shapeBuilder.mapTemplateToSubject(normalizedSubject);
        final mappedPoints = templatePoints
            .map(
              (point) => _mapNormalizedPoint(
                point,
                normalizedSubject,
                subjectZone,
              ),
            )
            .toList();
        silhouettePath = _shapeBuilder.pointsToSmoothPath(mappedPoints);
      }
    }

    MappedBodyPartGuides? bodyParts;
    Offset? headCenter;
    if (guidance.bodyPartGuides != null) {
      bodyParts = _mapBodyPartGuides(
        guidance.bodyPartGuides!,
        normalizedSubject,
        subjectZone,
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

  MappedBodyPartGuides _mapBodyPartGuides(
    BodyPartGuides guides,
    Rect normalizedSubject,
    Rect mappedSubject,
  ) {
    return MappedBodyPartGuides(
      headOval: _mapNormalizedRect(guides.headOval, normalizedSubject, mappedSubject),
      shoulders:
          _mapNormalizedRect(guides.shoulders, normalizedSubject, mappedSubject),
      torso: _mapNormalizedRect(guides.torso, normalizedSubject, mappedSubject),
      hips: _mapNormalizedRect(guides.hips, normalizedSubject, mappedSubject),
    );
  }

  Rect _mapNormalizedRect(
    Rect normalized,
    Rect normalizedSubject,
    Rect mappedSubject,
  ) {
    final topLeft =
        _mapNormalizedPoint(normalized.topLeft, normalizedSubject, mappedSubject);
    final bottomRight = _mapNormalizedPoint(
      normalized.bottomRight,
      normalizedSubject,
      mappedSubject,
    );
    return Rect.fromPoints(topLeft, bottomRight);
  }

  Offset _mapNormalizedPoint(
    Offset point,
    Rect normalizedSubject,
    Rect mappedSubject,
  ) {
    final relX = normalizedSubject.width == 0
        ? 0.5
        : ((point.dx - normalizedSubject.left) / normalizedSubject.width)
            .clamp(0.0, 1.2);
    final relY = normalizedSubject.height == 0
        ? 0.5
        : ((point.dy - normalizedSubject.top) / normalizedSubject.height)
            .clamp(0.0, 1.2);

    return Offset(
      mappedSubject.left + relX * mappedSubject.width,
      mappedSubject.top + relY * mappedSubject.height,
    );
  }

  Rect _cropRectForTemplate(PhotoFrameTemplate template, Size viewportSize) {
    return ViewportLetterbox.cropRectForRatio(
      template.aspectRatio,
      viewportSize,
    );
  }

  Rect _mapSubjectZone(Rect normalizedSubject, Rect cropRect) {
    return Rect.fromLTWH(
      cropRect.left + normalizedSubject.left * cropRect.width,
      cropRect.top + normalizedSubject.top * cropRect.height,
      normalizedSubject.width * cropRect.width,
      normalizedSubject.height * cropRect.height,
    );
  }

  Path _mapSilhouettePath(
    List<Offset> normalizedPoints,
    Rect normalizedSubject,
    Rect mappedSubject,
  ) {
    final mappedPoints = normalizedPoints
        .map(
          (point) =>
              _mapNormalizedPoint(point, normalizedSubject, mappedSubject),
        )
        .toList();
    return _shapeBuilder.pointsToSmoothPath(mappedPoints);
  }
}