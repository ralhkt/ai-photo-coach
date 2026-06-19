import 'dart:ui';

import 'pose_silhouette_platform_service.dart';

/// Dedupes native channel writes across rebuilds.
class PoseSilhouetteSyncController {
  List<Offset>? _lastContour;
  int? _lastScore;
  bool? _lastEnabled;
  String? _lastRenderMode;
  List<List<Offset>>? _lastSkeleton;

  Future<void> sync({
    required PoseSilhouettePlatformService service,
    required bool supported,
    List<Offset>? contour,
    required int score,
    required bool enabled,
    required String renderMode,
    required List<List<Offset>> skeletonSegments,
  }) async {
    if (!supported) {
      return;
    }

    if (enabled != _lastEnabled) {
      await service.setEnabled(enabled);
      _lastEnabled = enabled;
    }

    if (!enabled) {
      return;
    }

    if (contour != null &&
        contour.length >= 4 &&
        !_pointsEqual(contour, _lastContour)) {
      await service.setGuideContour(contour);
      _lastContour = List<Offset>.from(contour);
    }

    if (renderMode != _lastRenderMode) {
      await service.setRenderMode(renderMode);
      _lastRenderMode = renderMode;
    }

    if (!_segmentsEqual(skeletonSegments, _lastSkeleton)) {
      await service.setSkeletonSegments(skeletonSegments);
      _lastSkeleton = skeletonSegments
          .map((segment) => List<Offset>.from(segment))
          .toList(growable: false);
    }

    if (score != _lastScore) {
      await service.setAlignmentScore(score);
      _lastScore = score;
    }
  }

  bool _pointsEqual(List<Offset>? a, List<Offset>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).distance > 0.0005) {
        return false;
      }
    }
    return true;
  }

  bool _segmentsEqual(List<List<Offset>>? a, List<List<Offset>>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_pointsEqual(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
}