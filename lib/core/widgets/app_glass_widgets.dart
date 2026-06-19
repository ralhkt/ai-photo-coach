import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';
import '../theme/app_theme.dart';

/// Frosted vibrancy surface for camera overlays (iOS material style).
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma = 24,
    this.tintOpacity = 0.45,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double tintOpacity;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDesignTokens.radiusPill);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: tintOpacity),
            borderRadius: radius,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Solid coaching pill for camera overlays — no backdrop blur (GPU friendly).
class AppCoachPillLite extends StatelessWidget {
  const AppCoachPillLite({
    super.key,
    required this.message,
    this.icon = Icons.lightbulb_outline_rounded,
    this.maxLines = 1,
  });

  final String message;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.coach, size: 16),
            const SizedBox(width: AppDesignTokens.spaceSm),
            Expanded(
              child: Text(
                message,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppDesignTokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-line coaching hint pill (teal accent, not yellow).
class AppCoachPill extends StatelessWidget {
  const AppCoachPill({
    super.key,
    required this.message,
    this.icon = Icons.lightbulb_outline_rounded,
    this.maxLines = 1,
  });

  final String message;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.coach, size: 16),
          const SizedBox(width: AppDesignTokens.spaceSm),
          Expanded(
            child: Text(
              message,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppDesignTokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large-radius sheet container for in-camera advice panels.
class AppSheetPanel extends StatelessWidget {
  const AppSheetPanel({
    super.key,
    required this.child,
    this.showHandle = true,
  });

  final Widget child;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppDesignTokens.sheetRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surfaceGrouped.withValues(alpha: 0.92),
            borderRadius: AppDesignTokens.sheetRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppDesignTokens.textQuaternary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular camera tool button — instant press scale, no backdrop blur.
class AppCameraToolButton extends StatefulWidget {
  const AppCameraToolButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  @override
  State<AppCameraToolButton> createState() => _AppCameraToolButtonState();
}

class _AppCameraToolButtonState extends State<AppCameraToolButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        child: Container(
          width: AppDesignTokens.minTapTarget,
          height: AppDesignTokens.minTapTarget,
          decoration: BoxDecoration(
            color: widget.active
                ? AppTheme.accent.withValues(alpha: 0.22)
                : AppDesignTokens.fillPrimary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color:
                widget.active ? AppTheme.accent : AppDesignTokens.textPrimary,
            size: 20,
          ),
        ),
      ),
    );

    if (widget.tooltip == null) {
      return button;
    }
    return Tooltip(message: widget.tooltip!, child: button);
  }
}