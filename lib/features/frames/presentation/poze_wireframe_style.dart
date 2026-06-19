import 'dart:ui';

/// Visual constants matching Poze造型 pose-guide overlays.
abstract final class PozeWireframeStyle {
  static const Color lineColor = Color(0xB3FFFFFF); // 70% hairline
  static const Color glowColor = Color(0x14FFFFFF);
  static const Color alignedColor = Color(0xB330D158); // success flash
  static const Color cropBorderColor = Color(0x66FFFFFF);
  static const Color silhouetteFillColor = Color(0x2BFFFFFF); // ~17% fill
  static const Color crosshairColor = Color(0x66FFFFFF); // 40% white
  static const Color faceFocusColor = Color(0xCCFFFFFF); // 80% white
  static const Color faceFocusGlowColor = Color(0x33FFFFFF); // soft glow

  static const double bodyStrokeWidth = 1.25;
  static const double minimalBodyStrokeWidth = 1.0;
  static const double limbStrokeWidth = 0.9;
  static const double glowStrokeWidth = 2.0;
  static const double cropStrokeWidth = 0.33;
  static const double crosshairArm = 10.0;
  static const double faceFocusStrokeWidth = 1.0;
  static const double faceFocusGlowStrokeWidth = 3.5;

  static const double ghostOpacity = 0.32;
}

/// Normalized limb polylines (0–1 within subject bounds) for Poze-style arms.
class PozeLimbGuide {
  const PozeLimbGuide(this.points);

  final List<Offset> points;
}

/// Limb guides used when optional detail mode is enabled.
class PozeWireframeLimbs {
  const PozeWireframeLimbs({
    required this.leftArm,
    required this.rightArm,
    required this.leftLeg,
    required this.rightLeg,
    required this.spine,
  });

  final PozeLimbGuide leftArm;
  final PozeLimbGuide rightArm;
  final PozeLimbGuide leftLeg;
  final PozeLimbGuide rightLeg;
  final PozeLimbGuide spine;

  /// Seated side pose — phone raised toward face (Poze café / mirror check-in).
  static const PozeWireframeLimbs seatedPhone = PozeWireframeLimbs(
    leftArm: PozeLimbGuide([
      Offset(0.50, 0.32),
      Offset(0.44, 0.42),
      Offset(0.42, 0.52),
    ]),
    rightArm: PozeLimbGuide([
      Offset(0.64, 0.30),
      Offset(0.50, 0.26),
      Offset(0.36, 0.22),
    ]),
    leftLeg: PozeLimbGuide([
      Offset(0.44, 0.72),
      Offset(0.38, 0.86),
      Offset(0.36, 0.96),
    ]),
    rightLeg: PozeLimbGuide([
      Offset(0.54, 0.72),
      Offset(0.58, 0.84),
      Offset(0.56, 0.96),
    ]),
    spine: PozeLimbGuide([
      Offset(0.58, 0.22),
      Offset(0.52, 0.56),
    ]),
  );

  static const PozeWireframeLimbs standing = PozeWireframeLimbs(
    leftArm: PozeLimbGuide([
      Offset(0.34, 0.30),
      Offset(0.20, 0.40),
      Offset(0.24, 0.50),
    ]),
    rightArm: PozeLimbGuide([
      Offset(0.66, 0.30),
      Offset(0.80, 0.40),
      Offset(0.76, 0.50),
    ]),
    leftLeg: PozeLimbGuide([
      Offset(0.44, 0.88),
      Offset(0.40, 0.98),
    ]),
    rightLeg: PozeLimbGuide([
      Offset(0.56, 0.88),
      Offset(0.60, 0.98),
    ]),
    spine: PozeLimbGuide([
      Offset(0.50, 0.24),
      Offset(0.50, 0.88),
    ]),
  );
}