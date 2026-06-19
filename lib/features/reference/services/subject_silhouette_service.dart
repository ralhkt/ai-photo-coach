import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/body_part_guides.dart';
import '../../pose/models/pose_point3d.dart';
import 'human_frame_shape_builder.dart';
import 'pose_aware_silhouette_builder.dart';
import 'portrait_contour_extractor.dart';

typedef NativeContourExtractor = Future<List<Offset>?> Function(Uint8List bytes);

/// Builds human silhouette for guided framing — prefers real edge extraction.
class SubjectSilhouetteService {
  SubjectSilhouetteService({
    HumanFrameShapeBuilder? shapeBuilder,
    PortraitContourExtractor? contourExtractor,
    PoseAwareSilhouetteBuilder? poseAwareBuilder,
    NativeContourExtractor? nativeContourExtractor,
  })  : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder(),
        _contourExtractor = contourExtractor ?? const PortraitContourExtractor(),
        _poseAwareBuilder = poseAwareBuilder ?? const PoseAwareSilhouetteBuilder(),
        _nativeContourExtractor = nativeContourExtractor;

  final HumanFrameShapeBuilder _shapeBuilder;
  final PortraitContourExtractor _contourExtractor;
  final PoseAwareSilhouetteBuilder _poseAwareBuilder;
  final NativeContourExtractor? _nativeContourExtractor;

  /// iOS Vision person segmentation first, then Dart contour, then template.
  Future<List<Offset>> extractPortraitSilhouetteAsync(
    Uint8List imageBytes,
    img.Image image,
    Rect subjectRect, {
    BodyPartGuides? bodyPartGuides,
    List<PosePoint3D>? poseLandmarks,
  }) async {
    final native = _nativeContourExtractor;
    if (native != null) {
      final traced = await native(imageBytes);
      if (traced != null && traced.length >= 12) {
        return traced;
      }
    }

    return extractPortraitSilhouette(
      image,
      subjectRect,
      bodyPartGuides: bodyPartGuides,
      poseLandmarks: poseLandmarks,
    );
  }

  List<Offset> extractPortraitSilhouette(
    img.Image image,
    Rect subjectRect, {
    BodyPartGuides? bodyPartGuides,
    List<PosePoint3D>? poseLandmarks,
  }) {
    final traced = _contourExtractor.extract(image, subjectRect);
    if (traced != null && traced.length >= 12) {
      return traced;
    }

    if (poseLandmarks != null &&
        poseLandmarks.length >= 6 &&
        _poseAwareBuilder.canBuild(poseLandmarks)) {
      return _poseAwareBuilder.build(poseLandmarks);
    }

    if (bodyPartGuides != null) {
      return _poseAwareBuilder.buildFromBodyGuides(bodyPartGuides);
    }
    return _shapeBuilder.mapTemplateToSubject(subjectRect);
  }
}