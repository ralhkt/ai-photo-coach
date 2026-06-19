import 'dart:ui';

/// Poze造型-style centered standing guide geometry (normalized 0–1 crop coords).
abstract final class PozeFrameLayout {
  /// Canonical full-body standing rect — always centered in the viewfinder.
  static Rect canonicalStandingRect() {
    return Rect.fromCenter(
      center: const Offset(0.5, 0.48),
      width: 0.50,
      height: 0.76,
    );
  }

  /// Seated side-profile rect — café / mirror selfie poses (Poze default).
  static Rect canonicalSeatedRect() {
    return Rect.fromCenter(
      center: const Offset(0.52, 0.52),
      width: 0.56,
      height: 0.72,
    );
  }

  /// Recenters a detected subject rect when contrast heuristics drift sideways.
  static Rect stabilizeForOverlay(Rect rect) {
    final width = rect.width.clamp(0.42, 0.56);
    final height = rect.height.clamp(0.62, 0.80);
    final centerX = rect.center.dx;
    final centerY = rect.center.dy.clamp(0.38, 0.54);

    final horizontalDrift = (centerX - 0.5).abs();
    final stabilizedX = horizontalDrift > 0.14 ? 0.5 : centerX;

    return Rect.fromCenter(
      center: Offset(stabilizedX, centerY),
      width: width,
      height: height,
    );
  }

  /// Poze overlay uses a seated phone pose box, centered and drift-corrected.
  static Rect seatedOverlayRect(Rect rect) {
    final canonical = canonicalSeatedRect();
    final horizontalDrift = (rect.center.dx - 0.5).abs();
    final stabilizedX = horizontalDrift > 0.14 ? canonical.center.dx : rect.center.dx;
    final centerY = rect.center.dy.clamp(0.44, 0.58);

    return Rect.fromCenter(
      center: Offset(stabilizedX, centerY),
      width: canonical.width,
      height: canonical.height,
    );
  }
}