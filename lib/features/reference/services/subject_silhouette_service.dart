import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import 'human_frame_shape_builder.dart';
import 'portrait_contour_extractor.dart';

/// Builds human silhouette for guided framing — prefers real edge extraction.
class SubjectSilhouetteService {
  SubjectSilhouetteService({
    HumanFrameShapeBuilder? shapeBuilder,
    PortraitContourExtractor? contourExtractor,
  })  : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder(),
        _contourExtractor = contourExtractor ?? const PortraitContourExtractor();

  final HumanFrameShapeBuilder _shapeBuilder;
  final PortraitContourExtractor _contourExtractor;

  List<Offset> extractPortraitSilhouette(
    img.Image image,
    Rect subjectRect, {
    BodyPartGuides? bodyPartGuides,
  }) {
    final traced = _contourExtractor.extract(image, subjectRect);
    if (traced != null && traced.length >= 8) {
      return traced;
    }

    if (bodyPartGuides != null) {
      return _shapeBuilder.silhouetteFromBodyGuides(bodyPartGuides);
    }
    return _shapeBuilder.mapTemplateToSubject(subjectRect);
  }
}