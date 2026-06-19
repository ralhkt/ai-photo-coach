import 'package:flutter/material.dart';

/// Apple HIG–aligned semantic tokens for spacing, color, radii, and motion.
abstract final class AppDesignTokens {
  // ── Spacing (8pt grid) ──────────────────────────────────────────────
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double space2xl = 24;
  static const double space3xl = 32;
  static const double space4xl = 48;

  // ── Radii ─────────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusSheet = 38;
  static const double radiusPill = 999;

  static const double minTapTarget = 44;
  static const double screenPadding = 20;
  static const double hairline = 0.33;

  // ── Labels (iOS opacity ladder) ───────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x8FFFFFFF); // 55%
  static const Color textQuaternary = Color(0x59FFFFFF); // 35%

  // ── Surfaces ──────────────────────────────────────────────────────
  static const Color separator = Color(0x33FFFFFF); // 20%
  static const Color fillPrimary = Color(0x3D787880); // tertiary fill
  static const Color fillSecondary = Color(0x29787880); // quaternary fill
  static const Color fillTertiary = Color(0x1FFFFFFF);
  static const Color fillQuaternary = Color(0x14FFFFFF);

  // ── Semantic accents ──────────────────────────────────────────────
  static const Color accentPrimary = Color(0xFFFFD60A); // system yellow
  static const Color accentCoach = Color(0xFF64D2FF); // system teal
  static const Color accentSuccess = Color(0xFF30D158); // system green

  static BorderRadius get cardRadius => BorderRadius.circular(radiusLg);
  static BorderRadius get chipRadius => BorderRadius.circular(radiusSm);
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(radiusSheet));

  // ── Motion ────────────────────────────────────────────────────────
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSheet = Duration(milliseconds: 380);
  static const Curve motionEaseOut = Curves.easeOutCubic;
  static const Curve motionSpring = Curves.easeOutBack;
}