import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'ios_camera_ui_kit.dart';

class IosCameraTopBar extends StatelessWidget {
  const IosCameraTopBar({
    super.key,
    required this.flashMode,
    required this.onClose,
    required this.onFlashTap,
    this.onNightModeTap,
    this.onSettingsTap,
    this.onFormatTap,
    this.nightModeEnabled = false,
    this.nightModeSupported = true,
    this.formatLabel = 'JPEG',
    this.megapixelLabel,
    this.centerLabel,
    this.hdrEnabled = false,
    this.aeAfLocked = false,
    this.aeAfLockLabel,
  });

  final FlashMode flashMode;
  final VoidCallback onClose;
  final VoidCallback onFlashTap;
  final VoidCallback? onNightModeTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onFormatTap;
  final bool nightModeEnabled;
  final bool nightModeSupported;
  final String formatLabel;
  final String? megapixelLabel;
  final String? centerLabel;
  final bool hdrEnabled;
  final bool aeAfLocked;
  final String? aeAfLockLabel;

  @override
  Widget build(BuildContext context) {
    return IosCameraChromeBar(
      edge: IosCameraChromeEdge.top,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: IosCameraUiKit.topBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IosCameraTopIconButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: onClose,
                      size: 26,
                    ),
                    const SizedBox(width: 2),
                    _FormatBadge(
                      formatLabel: formatLabel,
                      megapixelLabel: megapixelLabel,
                      onTap: onFormatTap,
                    ),
                    if (centerLabel != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          centerLabel!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: IosCameraUiKit.textPrimary.withValues(
                              alpha: 0.9,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    _FlashButton(
                      flashMode: flashMode,
                      onTap: onFlashTap,
                    ),
                    IosCameraTopIconButton(
                      icon: nightModeEnabled
                          ? Icons.nightlight_round
                          : Icons.nightlight_outlined,
                      onTap: nightModeSupported ? onNightModeTap : null,
                      active: nightModeEnabled,
                    ),
                    IosCameraTopIconButton(
                      icon: Icons.settings_rounded,
                      onTap: onSettingsTap,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
            if (hdrEnabled || aeAfLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hdrEnabled) const IosCameraStatusBadge(label: 'HDR'),
                    if (hdrEnabled && aeAfLocked) const SizedBox(width: 8),
                    if (aeAfLocked && aeAfLockLabel != null)
                      IosCameraStatusBadge(label: aeAfLockLabel!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({
    required this.formatLabel,
    required this.megapixelLabel,
    this.onTap,
  });

  final String formatLabel;
  final String? megapixelLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mp = megapixelLabel;
    final label = mp == null ? formatLabel : '$formatLabel $mp';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(
          label,
          style: IosCameraUiKit.formatBadge.copyWith(
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _FlashButton extends StatelessWidget {
  const _FlashButton({
    required this.flashMode,
    required this.onTap,
  });

  final FlashMode flashMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = flashMode != FlashMode.off;
    final icon = switch (flashMode) {
      FlashMode.torch => Icons.flashlight_on_rounded,
      FlashMode.auto => Icons.flash_auto_rounded,
      FlashMode.always => Icons.flash_on_rounded,
      FlashMode.off => Icons.flash_off_rounded,
    };

    return IosCameraTopIconButton(
      icon: icon,
      onTap: onTap,
      active: active,
      size: 21,
    );
  }
}