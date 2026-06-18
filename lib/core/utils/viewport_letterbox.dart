import 'dart:ui';

import 'package:flutter/material.dart';

/// Centered crop / letterbox helpers for camera and frame overlays.
class ViewportLetterbox {
  const ViewportLetterbox._();

  /// Returns a centered crop rect matching [targetRatio] inside [viewport].
  static Rect cropRectForRatio(double targetRatio, Size viewport) {
    final viewRatio = viewport.width / viewport.height;
    if (viewRatio > targetRatio) {
      final width = viewport.height * targetRatio;
      final left = (viewport.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, viewport.height);
    }

    final height = viewport.width / targetRatio;
    final top = (viewport.height - height) / 2;
    return Rect.fromLTWH(0, top, viewport.width, height);
  }

  /// Viewport size of the centered crop for [targetRatio] inside [viewport].
  static Size cropViewportSize(double targetRatio, Size viewport) {
    final crop = cropRectForRatio(targetRatio, viewport);
    return Size(crop.width, crop.height);
  }

  /// Orients a photo ratio (4:3, 16:9…) for [viewport] width÷height.
  static double orientPhotoRatio(double photoWidthOverHeight, Size viewport) {
    final portrait = viewport.height >= viewport.width;
    return portrait ? 1 / photoWidthOverHeight : photoWidthOverHeight;
  }

  /// Maps a source-image normalized point into crop normalized coords using
  /// centered cover-fit (same semantics as [BoxFit.cover]).
  static Offset mapNormalizedPointCoverFit(
    Offset sourcePoint, {
    required double sourceAspectRatio,
    required double targetAspectRatio,
  }) {
    if (sourceAspectRatio <= 0 || targetAspectRatio <= 0) {
      return sourcePoint;
    }

    if ((sourceAspectRatio - targetAspectRatio).abs() < 0.001) {
      return sourcePoint;
    }

    if (sourceAspectRatio > targetAspectRatio) {
      final visibleWidth = targetAspectRatio / sourceAspectRatio;
      final offsetX = (1 - visibleWidth) / 2;
      return Offset(
        ((sourcePoint.dx - offsetX) / visibleWidth).clamp(0.0, 1.0),
        sourcePoint.dy.clamp(0.0, 1.0),
      );
    }

    final visibleHeight = sourceAspectRatio / targetAspectRatio;
    final offsetY = (1 - visibleHeight) / 2;
    return Offset(
      sourcePoint.dx.clamp(0.0, 1.0),
      ((sourcePoint.dy - offsetY) / visibleHeight).clamp(0.0, 1.0),
    );
  }

  /// Destination [Rect] for drawing [imageAspectRatio] with cover-fit inside [cropRect].
  static Rect coverFitDestRect({
    required Rect cropRect,
    required double imageAspectRatio,
  }) {
    if (imageAspectRatio <= 0) {
      return cropRect;
    }

    final cropAspect = cropRect.width / cropRect.height;
    if (imageAspectRatio > cropAspect) {
      final height = cropRect.height;
      final width = height * imageAspectRatio;
      final left = cropRect.left + (cropRect.width - width) / 2;
      return Rect.fromLTWH(left, cropRect.top, width, height);
    }

    final width = cropRect.width;
    final height = width / imageAspectRatio;
    final top = cropRect.top + (cropRect.height - height) / 2;
    return Rect.fromLTWH(cropRect.left, top, width, height);
  }
}