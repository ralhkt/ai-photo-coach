import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart' show BoxFit;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../../core/utils/viewport_letterbox.dart';
import '../models/pose_point3d.dart';

/// Maps ML Kit normalized landmarks into [CameraPreview] / crop widget pixels.
///
/// Pipeline: sensor-normalized → rotation → cover-fit letterbox → mirror.
class PoseSkeletonCoordinateMapper {
  const PoseSkeletonCoordinateMapper({
    required this.imageSize,
    required this.previewSize,
    this.cropRect,
    this.rotation = InputImageRotation.rotation0deg,
    this.isFrontCamera = false,
    this.mirrorFront = true,
    this.fit = BoxFit.cover,
  });

  /// Width/height of the buffer ML Kit analyzed (after any downscale).
  final Size imageSize;

  /// Size of the overlay widget (usually the letterboxed crop area).
  final Size previewSize;

  /// Visible crop inside [previewSize]; defaults to full widget bounds.
  final Rect? cropRect;

  /// Native buffer rotation reported by the camera / InputImage metadata.
  final InputImageRotation rotation;

  final bool isFrontCamera;
  final bool mirrorFront;
  final BoxFit fit;

  factory PoseSkeletonCoordinateMapper.fromCamera({
    required Size imageSize,
    required Size previewSize,
    Rect? cropRect,
    required CameraLensDirection lensDirection,
    bool mirrorFront = true,
    InputImageRotation rotation = InputImageRotation.rotation0deg,
    BoxFit fit = BoxFit.cover,
  }) {
    return PoseSkeletonCoordinateMapper(
      imageSize: imageSize,
      previewSize: previewSize,
      cropRect: cropRect,
      rotation: rotation,
      isFrontCamera: lensDirection == CameraLensDirection.front,
      mirrorFront: mirrorFront,
      fit: fit,
    );
  }

  Rect get _crop => cropRect ?? (Offset.zero & previewSize);

  double get _sourceAspectRatio {
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return 1;
    }
    return imageSize.width / imageSize.height;
  }

  double get _targetAspectRatio {
    if (_crop.width <= 0 || _crop.height <= 0) {
      return 1;
    }
    return _crop.width / _crop.height;
  }

  /// Converts one landmark into canvas coordinates for [CustomPainter].
  Offset mapLandmark(PosePoint3D landmark) {
    return mapNormalized(Offset(landmark.x, landmark.y));
  }

  /// Converts normalized image-space (0–1) into preview pixels.
  Offset mapNormalized(Offset normalized) {
    final rotated = _applyRotation(normalized);
    final mirrored = _applyMirror(rotated);

    if (fit == BoxFit.cover) {
      final remapped = ViewportLetterbox.mapNormalizedPointCoverFit(
        mirrored,
        sourceAspectRatio: _sourceAspectRatio,
        targetAspectRatio: _targetAspectRatio,
      );
      return Offset(
        _crop.left + remapped.dx * _crop.width,
        _crop.top + remapped.dy * _crop.height,
      );
    }

    return _mapContain(mirrored);
  }

  Offset _mapContain(Offset point) {
    final dest = ViewportLetterbox.coverFitDestRect(
      cropRect: _crop,
      imageAspectRatio: _sourceAspectRatio,
    );
    return Offset(
      dest.left + point.dx * dest.width,
      dest.top + point.dy * dest.height,
    );
  }

  Offset _applyRotation(Offset point) {
    return switch (rotation) {
      InputImageRotation.rotation0deg => point,
      InputImageRotation.rotation90deg => Offset(point.dy, 1 - point.dx),
      InputImageRotation.rotation180deg => Offset(1 - point.dx, 1 - point.dy),
      InputImageRotation.rotation270deg => Offset(1 - point.dy, point.dx),
    };
  }

  Offset _applyMirror(Offset point) {
    if (!isFrontCamera || !mirrorFront) {
      return point;
    }
    return Offset(1 - point.dx, point.dy);
  }
}