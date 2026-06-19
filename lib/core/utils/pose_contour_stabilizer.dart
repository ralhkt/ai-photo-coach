import 'dart:ui';

import '../../models/body_part_guides.dart';
import '../../models/camera_guidance.dart';
import 'contour_smoother.dart';

/// Temporal EMA stabilizer for live pose-guide overlays (reduces ML jitter).
class PoseContourStabilizer {
  PoseContourStabilizer({this.alpha = 0.32});

  final double alpha;

  Rect? _previousSubjectRect;
  BodyPartGuides? _previousBodyGuides;
  List<Offset>? _previousSilhouette;

  CameraGuidance stabilize(CameraGuidance guidance) {
    final subjectRect = _emaRect(
      guidance.subjectTargetRect,
      _previousSubjectRect,
    );
    _previousSubjectRect = subjectRect;

    BodyPartGuides? bodyParts = guidance.bodyPartGuides;
    if (bodyParts != null) {
      bodyParts = _emaBodyGuides(bodyParts, _previousBodyGuides);
      _previousBodyGuides = bodyParts;
    }

    List<Offset>? silhouette = guidance.subjectSilhouettePoints;
    if (silhouette != null && silhouette.length >= 4) {
      silhouette = ContourSmoother.temporalEma(
        silhouette,
        previous: _previousSilhouette,
        alpha: alpha,
      );
      _previousSilhouette = silhouette;
    }

    return guidance.copyWith(
      subjectTargetRect: subjectRect,
      bodyPartGuides: bodyParts,
      subjectSilhouettePoints: silhouette,
    );
  }

  void reset() {
    _previousSubjectRect = null;
    _previousBodyGuides = null;
    _previousSilhouette = null;
  }

  Rect _emaRect(Rect current, Rect? previous) {
    if (previous == null) {
      return current;
    }
    return Rect.fromLTRB(
      _lerp(previous.left, current.left),
      _lerp(previous.top, current.top),
      _lerp(previous.right, current.right),
      _lerp(previous.bottom, current.bottom),
    );
  }

  BodyPartGuides _emaBodyGuides(BodyPartGuides current, BodyPartGuides? previous) {
    if (previous == null) {
      return current;
    }
    return BodyPartGuides(
      headOval: _emaRect(current.headOval, previous.headOval),
      shoulders: _emaRect(current.shoulders, previous.shoulders),
      torso: _emaRect(current.torso, previous.torso),
      hips: _emaRect(current.hips, previous.hips),
    );
  }

  double _lerp(double from, double to) => from + (to - from) * alpha;
}