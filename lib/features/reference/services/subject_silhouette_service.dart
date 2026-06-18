import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import 'human_frame_shape_builder.dart';

/// Builds a stable human silhouette for guided framing (no noisy edge tracing).
class SubjectSilhouetteService {
  SubjectSilhouetteService({HumanFrameShapeBuilder? shapeBuilder})
      : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder();

  final HumanFrameShapeBuilder _shapeBuilder;

  List<Offset> extractPortraitSilhouette(
    img.Image image,
    Rect subjectRect, {
    BodyPartGuides? bodyPartGuides,
  }) {
    if (bodyPartGuides != null) {
      return _shapeBuilder.silhouetteFromBodyGuides(bodyPartGuides);
    }
    return _shapeBuilder.mapTemplateToSubject(subjectRect);
  }
}