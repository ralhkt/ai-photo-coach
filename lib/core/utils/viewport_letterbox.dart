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
}