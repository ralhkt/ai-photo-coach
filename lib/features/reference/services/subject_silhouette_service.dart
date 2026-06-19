import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import 'human_frame_shape_builder.dart';
import 'portrait_contour_extractor.dart';

typedef NativeContourExtractor = Future<List<Offset>?> Function(Uint8List bytes);

/// Builds human silhouette for guided framing — prefers real edge extraction.
class SubjectSilhouetteService {
  SubjectSilhouetteService({
    HumanFrameShapeBuilder? shapeBuilder,
    PortraitContourExtractor? contourExtractor,
    NativeContourExtractor? nativeContourExtractor,
  })  : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder(),
        _contourExtractor = contourExtractor ?? const PortraitContourExtractor(),
        _nativeContourExtractor = nativeContourExtractor;

  final HumanFrameShapeBuilder _shapeBuilder;
  final PortraitContourExtractor _contourExtractor;
  final NativeContourExtractor? _nativeContourExtractor;

  /// iOS Vision person segmentation first, then Dart contour, then template.
  Future<List<Offset>> extractPortraitSilhouetteAsync(
    Uint8List imageBytes,
    img.Image image,
    Rect subjectRect, {
    BodyPartGuides? bodyPartGuides,
  }) async {
    final native = _nativeContourExtractor;
    if (native != null) {
      final traced = await native(imageBytes);
      if (traced != null && traced.length >= 8) {
        return traced;
      }
    }

    return extractPortraitSilhouette(
      image,
      subjectRect,
      bodyPartGuides: bodyPartGuides,
    );
  }

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