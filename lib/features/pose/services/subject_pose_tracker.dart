import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Locks onto the primary subject across frames using size, centrality, and IoU.
class SubjectPoseTracker {
  SubjectPoseTracker({
    this.minLikelihood = 0.3,
    this.minTrackingIou = 0.25,
    this.maxLostFrames = 12,
  });

  final double minLikelihood;
  final double minTrackingIou;
  final int maxLostFrames;

  Rect? _lockedBox;
  int _lostFrames = 0;

  /// Picks the pose to coach — not simply [List.first].
  Pose? selectPrimary(
    List<Pose> poses, {
    required int imageWidth,
    required int imageHeight,
  }) {
    if (poses.isEmpty) {
      _lostFrames++;
      if (_lostFrames > maxLostFrames) {
        _lockedBox = null;
      }
      return null;
    }

    if (_lockedBox == null) {
      final selected = _scoreInitial(poses, imageWidth, imageHeight);
      if (selected != null) {
        _lockedBox = boundingBoxFromPose(
          selected,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        );
        _lostFrames = 0;
      }
      return selected;
    }

    Pose? best;
    var bestIou = minTrackingIou;
    for (final pose in poses) {
      final box = boundingBoxFromPose(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      if (box.isEmpty) {
        continue;
      }
      final iou = _computeIoU(_lockedBox!, box);
      if (iou > bestIou) {
        bestIou = iou;
        best = pose;
        _lockedBox = box;
      }
    }

    if (best != null) {
      _lostFrames = 0;
      return best;
    }

    _lostFrames++;
    if (_lostFrames > maxLostFrames) {
      _lockedBox = null;
      return _scoreInitial(poses, imageWidth, imageHeight);
    }
    return null;
  }

  void reset() {
    _lockedBox = null;
    _lostFrames = 0;
  }

  Pose? _scoreInitial(List<Pose> poses, int imageWidth, int imageHeight) {
    Pose? best;
    var bestScore = -1.0;

    for (final pose in poses) {
      final box = boundingBoxFromPose(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      if (box.isEmpty) {
        continue;
      }

      final area = box.width * box.height;
      final center = box.center;
      const frameCenter = Offset(0.5, 0.45);
      final centrality =
          1 - (center - frameCenter).distance.clamp(0.0, 0.75) / 0.75;
      final score = area * 0.6 + centrality * 0.4;
      if (score > bestScore) {
        bestScore = score;
        best = pose;
      }
    }

    return best;
  }

  static Rect boundingBoxFromPose(
    Pose pose, {
    required int imageWidth,
    required int imageHeight,
    double minLikelihood = 0.3,
  }) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return Rect.zero;
    }

    var minX = 1.0;
    var minY = 1.0;
    var maxX = 0.0;
    var maxY = 0.0;
    var count = 0;

    for (final landmark in pose.landmarks.values) {
      if (landmark.likelihood < minLikelihood) {
        continue;
      }
      final x = (landmark.x / imageWidth).clamp(0.0, 1.0);
      final y = (landmark.y / imageHeight).clamp(0.0, 1.0);
      minX = x < minX ? x : minX;
      minY = y < minY ? y : minY;
      maxX = x > maxX ? x : maxX;
      maxY = y > maxY ? y : maxY;
      count++;
    }

    if (count < 4) {
      return Rect.zero;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _computeIoU(Rect a, Rect b) {
    final intersection = Rect.fromLTRB(
      a.left > b.left ? a.left : b.left,
      a.top > b.top ? a.top : b.top,
      a.right < b.right ? a.right : b.right,
      a.bottom < b.bottom ? a.bottom : b.bottom,
    );

    if (intersection.width <= 0 || intersection.height <= 0) {
      return 0;
    }

    final intersectionArea = intersection.width * intersection.height;
    final unionArea = a.width * a.height + b.width * b.height - intersectionArea;
    if (unionArea <= 0) {
      return 0;
    }
    return intersectionArea / unionArea;
  }
}