import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_tokens.dart';

/// Apple Camera app (iOS 18–26) visual language — layout, chrome, and motion.
abstract final class IosCameraUiKit {
  // ── Chrome dimensions ─────────────────────────────────────────────
  static const double topBarHeight = 44;
  static const double zoomRowHeight = 44;
  static const double bottomChromeHeight = 196;
  static const double bottomControlRowHeight = 82;
  static const double modeCarouselHeight = 40;
  static const double modeStripMinHeight = 40;
  static const double quickControlsMaxHeight = 120;

  // ── Shutter (Photo mode) ──────────────────────────────────────────
  static const double shutterOuterDiameter = 82;
  static const double shutterRingWidth = 4;
  static const double shutterInnerDiameter = 68;
  static const double shutterBurstInner = 32;
  static const double shutterBurstRadius = 8;

  // ── Side controls ─────────────────────────────────────────────────
  static const double gallerySize = 44;
  static const double galleryRadius = 6;
  static const double galleryBorderWidth = 2;
  static const double flipDiameter = 44;

  // ── Colors (Camera.app) ───────────────────────────────────────────
  static const Color accentYellow = AppDesignTokens.accentPrimary;
  static const Color chromeBlack = Color(0xFF000000);
  static const Color flipFill = Color(0x4D3A3A3C);
  static const Color galleryFill = Color(0x4D2C2C2E);
  static const Color pillFill = Color(0x33282828);
  static const Color pillFillActive = Color(0x33FFD60A);
  static const Color gridLine = Color(0xCCFFFFFF);

  static const Color textActive = accentYellow;
  static const Color textPrimary = AppDesignTokens.textPrimary;
  static const Color textSecondary = AppDesignTokens.textSecondary;
  static const Color textTertiary = AppDesignTokens.textTertiary;

  // ── Gradients (high transparency — iOS 26 Camera) ───────────────
  static LinearGradient topScrim({double opacity = 0.2}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: opacity),
        Colors.black.withValues(alpha: opacity * 0.4),
        Colors.black.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient bottomScrim() {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.black.withValues(alpha: 0.28),
        Colors.black.withValues(alpha: 0.12),
        Colors.black.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.42, 1.0],
    );
  }

  // ── Typography ────────────────────────────────────────────────────
  static const TextStyle modeSelected = TextStyle(
    color: textActive,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    height: 1.1,
  );

  static const TextStyle modeUnselected = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.1,
  );

  static const TextStyle flashLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle formatBadge = TextStyle(
    color: textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const TextStyle statusBadge = TextStyle(
    color: accentYellow,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle optionChip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle zoomActive = TextStyle(
    color: accentYellow,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle zoomInactive = TextStyle(
    color: textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const Duration pressAnimation = Duration(milliseconds: 80);
  static const Duration morphAnimation = Duration(milliseconds: 180);
  static const double pressScale = 0.92;
}

enum IosCameraChromeEdge { top, bottom }

/// Frosted translucent chrome bar matching iOS 26 Camera top/bottom overlays.
class IosCameraChromeBar extends StatelessWidget {
  const IosCameraChromeBar({
    super.key,
    required this.edge,
    required this.child,
  });

  final IosCameraChromeEdge edge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradient = edge == IosCameraChromeEdge.top
        ? IosCameraUiKit.topScrim()
        : IosCameraUiKit.bottomScrim();

    // Gradient only — BackdropFilter over live camera preview tanks UI FPS.
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// Frosted glass container matching iOS 26 Camera quick-control pills.
class IosCameraGlassPill extends StatelessWidget {
  const IosCameraGlassPill({
    super.key,
    required this.child,
    this.active = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    this.onTap,
  });

  final Widget child;
  final bool active;
  final bool enabled;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = active && enabled
        ? IosCameraUiKit.accentYellow
        : Colors.white.withValues(alpha: 0.18);
    final fillColor = active && enabled
        ? IosCameraUiKit.pillFillActive
        : IosCameraUiKit.pillFill;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Circular translucent icon control used in the native Camera top bar.
class IosCameraTopIconButton extends StatelessWidget {
  const IosCameraTopIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: active ? IosCameraUiKit.accentYellow : IosCameraUiKit.textPrimary,
          size: size,
        ),
      ),
    );
  }
}

/// 44×44 translucent icon control (grid, frame, analyze).
class IosCameraIconButton extends StatelessWidget {
  const IosCameraIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 22,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDesignTokens.minTapTarget,
      height: AppDesignTokens.minTapTarget,
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: active ? IosCameraUiKit.accentYellow : IosCameraUiKit.textPrimary,
          size: size,
        ),
      ),
    );
  }
}

/// Yellow HDR / AE-AF lock capsule below top bar.
class IosCameraStatusBadge extends StatelessWidget {
  const IosCameraStatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: IosCameraUiKit.pillFillActive,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: IosCameraUiKit.statusBadge),
    );
  }
}