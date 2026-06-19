import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import 'ios_camera_mode_carousel.dart';
import 'ios_camera_options_strip.dart';
import 'ios_camera_ui_kit.dart';

import 'ios_focal_presets.dart';
import 'ios_gallery_button.dart';
import 'ios_shutter_button.dart';

class IosCameraBottomBar extends StatelessWidget {
  const IosCameraBottomBar({
    super.key,
    required this.modeLabel,
    required this.thumbnailBytes,
    required this.onGalleryTap,
    required this.onGalleryLongPress,
    required this.onShutterTap,
    required this.onBurstStart,
    required this.onBurstEnd,
    required this.onFlipCamera,
    required this.hdrEnabled,
    required this.hdrSupported,
    required this.hdrLabel,
    required this.timerDuration,
    required this.aeAfLocked,
    required this.isBursting,
    required this.burstCount,
    required this.optionsExpanded,
    required this.onHdrTap,
    required this.onTimerTap,
    required this.onExposureLockTap,
    required this.onToggleOptions,
    this.isCapturing = false,
    this.canFlip = true,
    this.isFlipping = false,
    this.shutterEnabled = true,
    this.proModeEnabled = false,
    this.onProModeTap,
    this.aspectRatio = CameraAspectRatio.ratio4x3,
    this.onAspectRatioTap,
    this.showHistogram = false,
    this.onHistogramTap,
    this.frontMirrorEnabled = true,
    this.onMirrorTap,
    this.proModeExposure,
    this.focalPreset = 1.0,
    this.onFocalPresetTap,
    this.compactMode = false,
    this.modeLabels = const [],
    this.selectedModeIndex = 0,
    this.onModeSelected,
    this.showZoomPresets = true,
    this.controlRow,
    this.burstLabel,
  });

  final String modeLabel;
  final List<String> modeLabels;
  final int selectedModeIndex;
  final ValueChanged<int>? onModeSelected;
  final Uint8List? thumbnailBytes;
  final VoidCallback onGalleryTap;
  final VoidCallback onGalleryLongPress;
  final VoidCallback? onShutterTap;
  final VoidCallback? onBurstStart;
  final VoidCallback? onBurstEnd;
  final VoidCallback? onFlipCamera;
  final bool hdrEnabled;
  final bool hdrSupported;
  final String hdrLabel;
  final CameraTimerDuration timerDuration;
  final bool aeAfLocked;
  final bool isBursting;
  final int burstCount;
  final bool optionsExpanded;
  final VoidCallback onHdrTap;
  final VoidCallback onTimerTap;
  final VoidCallback onExposureLockTap;
  final VoidCallback onToggleOptions;
  final bool isCapturing;
  final bool canFlip;
  final bool isFlipping;
  final bool shutterEnabled;
  final bool proModeEnabled;
  final VoidCallback? onProModeTap;
  final CameraAspectRatio aspectRatio;
  final VoidCallback? onAspectRatioTap;
  final bool showHistogram;
  final VoidCallback? onHistogramTap;
  final bool frontMirrorEnabled;
  final VoidCallback? onMirrorTap;
  final Widget? proModeExposure;
  final double focalPreset;
  final ValueChanged<double>? onFocalPresetTap;
  final bool compactMode;
  final bool showZoomPresets;
  final Widget? controlRow;
  final Widget? burstLabel;

  @override
  Widget build(BuildContext context) {
    final modes = modeLabels.isNotEmpty ? modeLabels : [modeLabel];

    return IosCameraChromeBar(
      edge: IosCameraChromeEdge.bottom,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (optionsExpanded && !compactMode) ...[
                IosCameraOptionsStrip(
                  hdrEnabled: hdrEnabled,
                  hdrSupported: hdrSupported,
                  hdrLabel: hdrLabel,
                  timerDuration: timerDuration,
                  aeAfLocked: aeAfLocked,
                  isBursting: isBursting,
                  burstCount: burstCount,
                  expanded: true,
                  onHdrTap: onHdrTap,
                  onTimerTap: onTimerTap,
                  onExposureLockTap: onExposureLockTap,
                  onToggleExpanded: onToggleOptions,
                  proModeEnabled: proModeEnabled,
                  onProModeTap: onProModeTap,
                  showHistogram: showHistogram,
                  onHistogramTap: onHistogramTap,
                  frontMirrorEnabled: frontMirrorEnabled,
                  onMirrorTap: onMirrorTap,
                  showExpandChevron: false,
                  aspectRatio: aspectRatio,
                  onAspectRatioTap: onAspectRatioTap,
                ),
                const SizedBox(height: 4),
              ],
              if (showZoomPresets && onFocalPresetTap != null) ...[
                IosFocalPresets(
                  currentZoom: focalPreset,
                  onPresetTap: onFocalPresetTap!,
                ),
                const SizedBox(height: 6),
              ],
              if (proModeEnabled && proModeExposure != null) ...[
                proModeExposure!,
                const SizedBox(height: 6),
              ],
              controlRow ??
                  SizedBox(
                    height: IosCameraUiKit.bottomControlRowHeight,
                    child: Row(
                      children: [
                        IosGalleryButton(
                          thumbnailBytes: thumbnailBytes,
                          onTap: onGalleryTap,
                          onLongPress: onGalleryLongPress,
                        ),
                        Expanded(
                          child: Center(
                            child: IosShutterButton(
                              onPressed: shutterEnabled ? onShutterTap : null,
                              onBurstStart:
                                  shutterEnabled ? onBurstStart : null,
                              onBurstEnd: shutterEnabled ? onBurstEnd : null,
                              isCapturing: isCapturing,
                              isBursting: isBursting,
                              enabled: shutterEnabled,
                            ),
                          ),
                        ),
                        IosFlipCameraButton(
                          onTap: canFlip ? onFlipCamera : null,
                          enabled: canFlip,
                          isFlipping: isFlipping,
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 4),
              IosCameraModeCarousel(
                modes: modes,
                selectedIndex: selectedModeIndex.clamp(0, modes.length - 1),
                onModeSelected: onModeSelected,
              ),
              burstLabel ??
                  (isBursting
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '×$burstCount',
                            style: const TextStyle(
                              color: IosCameraUiKit.accentYellow,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

class IosFlipCameraButton extends StatelessWidget {
  const IosFlipCameraButton({
    required this.onTap,
    required this.enabled,
    required this.isFlipping,
  });

  final VoidCallback? onTap;
  final bool enabled;
  final bool isFlipping;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: IosCameraUiKit.flipDiameter,
        height: IosCameraUiKit.flipDiameter,
        decoration: BoxDecoration(
          color: IosCameraUiKit.flipFill,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: isFlipping
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              )
            : Icon(
                Icons.cameraswitch_rounded,
                color: Colors.white.withValues(alpha: enabled ? 0.95 : 0.35),
                size: 24,
              ),
      ),
    );
  }
}