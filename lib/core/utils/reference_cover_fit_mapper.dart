import 'dart:ui';

import 'viewport_letterbox.dart';

/// Photoshop-style reference mapping: the uploaded photo and its subject
/// selection boundary share one cover-fit transform into the viewfinder.
///
/// Contour points are stored in 0–1 coordinates over the photo pixels (like a
/// "Select Subject" mask boundary). [mapImageNormalizedPoint] projects them into
/// the same destination rect used to draw the ghost reference image.
class ReferenceCoverFitMapper {
  const ReferenceCoverFitMapper._();

  static Rect imageDestRect({
    required Rect cropRect,
    required double imageAspectRatio,
  }) {
    return ViewportLetterbox.coverFitDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspectRatio,
    );
  }

  static Offset mapImageNormalizedPoint(Offset point, Rect imageDestRect) {
    return Offset(
      imageDestRect.left + point.dx * imageDestRect.width,
      imageDestRect.top + point.dy * imageDestRect.height,
    );
  }

  static List<Offset> mapContour(
    List<Offset> imageNormalizedPoints,
    Rect imageDestRect,
  ) {
    return [
      for (final point in imageNormalizedPoints)
        mapImageNormalizedPoint(point, imageDestRect),
    ];
  }
}