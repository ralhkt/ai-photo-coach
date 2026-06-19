import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';

class IosCameraOptionsStrip extends StatelessWidget {
  const IosCameraOptionsStrip({
    super.key,
    required this.hdrEnabled,
    required this.hdrSupported,
    required this.hdrLabel,
    required this.timerDuration,
    required this.aeAfLocked,
    required this.isBursting,
    required this.burstCount,
    required this.onHdrTap,
    required this.onTimerTap,
    required this.onExposureLockTap,
    required this.onToggleExpanded,
    required this.expanded,
    this.proModeEnabled = false,
    this.onProModeTap,
    this.aspectRatio = CameraAspectRatio.ratio4x3,
    this.onAspectRatioTap,
    this.showHistogram = false,
    this.onHistogramTap,
    this.frontMirrorEnabled = true,
    this.onMirrorTap,
  });

  final bool hdrEnabled;
  final bool hdrSupported;
  final String hdrLabel;
  final CameraTimerDuration timerDuration;
  final bool aeAfLocked;
  final bool isBursting;
  final int burstCount;
  final VoidCallback onHdrTap;
  final VoidCallback onTimerTap;
  final VoidCallback onExposureLockTap;
  final VoidCallback onToggleExpanded;
  final bool expanded;
  final bool proModeEnabled;
  final VoidCallback? onProModeTap;
  final CameraAspectRatio aspectRatio;
  final VoidCallback? onAspectRatioTap;
  final bool showHistogram;
  final VoidCallback? onHistogramTap;
  final bool frontMirrorEnabled;
  final VoidCallback? onMirrorTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onToggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_rounded,
              color: Colors.white54,
              size: 22,
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                _OptionChip(
                  label: hdrLabel,
                  active: hdrSupported && hdrEnabled,
                  enabled: hdrSupported,
                  onTap: onHdrTap,
                ),
                _OptionChip(
                  label: _timerLabel(l10n, timerDuration),
                  active: timerDuration != CameraTimerDuration.off,
                  icon: Icons.timer_outlined,
                  onTap: onTimerTap,
                ),
                _OptionChip(
                  label: l10n.exposureLock,
                  active: aeAfLocked,
                  icon: Icons.lock_outline_rounded,
                  onTap: onExposureLockTap,
                ),
                if (onProModeTap != null)
                  _OptionChip(
                    label: l10n.proMode,
                    active: proModeEnabled,
                    icon: Icons.tune_rounded,
                    onTap: onProModeTap!,
                  ),
                if (onAspectRatioTap != null)
                  _OptionChip(
                    label: _aspectLabel(l10n, aspectRatio),
                    active: aspectRatio != CameraAspectRatio.full,
                    icon: Icons.aspect_ratio_rounded,
                    onTap: onAspectRatioTap!,
                  ),
                if (onHistogramTap != null)
                  _OptionChip(
                    label: l10n.histogram,
                    active: showHistogram,
                    icon: Icons.bar_chart_rounded,
                    onTap: onHistogramTap!,
                  ),
                if (onMirrorTap != null)
                  _OptionChip(
                    label: l10n.frontMirror,
                    active: frontMirrorEnabled,
                    icon: Icons.flip_rounded,
                    onTap: onMirrorTap!,
                  ),
              ],
            ),
          ),
        if (isBursting)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n.burstCapturing(burstCount),
              style: const TextStyle(
                color: Color(0xFFFFD60A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _timerLabel(AppLocalizations l10n, CameraTimerDuration duration) {
    return switch (duration) {
      CameraTimerDuration.off => l10n.timerOff,
      CameraTimerDuration.three => l10n.timer3s,
      CameraTimerDuration.ten => l10n.timer10s,
    };
  }

  String _aspectLabel(AppLocalizations l10n, CameraAspectRatio ratio) {
    return switch (ratio) {
      CameraAspectRatio.ratio4x3 => l10n.aspectRatio4x3,
      CameraAspectRatio.ratio16x9 => l10n.aspectRatio16x9,
      CameraAspectRatio.ratio1x1 => l10n.aspectRatio1x1,
      CameraAspectRatio.full => l10n.aspectRatioFull,
    };
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? const Color(0xFFFFD60A) : Colors.white38;
    final textColor = enabled
        ? (active ? const Color(0xFFFFD60A) : Colors.white)
        : Colors.white38;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: active && enabled
                ? const Color(0x33FFD60A)
                : const Color(0x33282828),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active && enabled ? accent : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: active && enabled ? accent : Colors.white70,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}