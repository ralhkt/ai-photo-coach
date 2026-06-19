import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import 'ios_camera_options_strip.dart';
import 'ios_exposure_slider.dart';
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
    this.shutterEnabled = true,
    this.proModeEnabled = false,
    this.onProModeTap,
    this.aspectRatio = CameraAspectRatio.ratio4x3,
    this.onAspectRatioTap,
    this.showHistogram = false,
    this.onHistogramTap,
    this.frontMirrorEnabled = true,
    this.onMirrorTap,
    this.manualExposure = 0,
    this.onManualExposureChanged,
    this.focalPreset = 1.0,
    this.onFocalPresetTap,
    this.compactMode = false,
  });

  final String modeLabel;
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
  final bool shutterEnabled;
  final bool proModeEnabled;
  final VoidCallback? onProModeTap;
  final CameraAspectRatio aspectRatio;
  final VoidCallback? onAspectRatioTap;
  final bool showHistogram;
  final VoidCallback? onHistogramTap;
  final bool frontMirrorEnabled;
  final VoidCallback? onMirrorTap;
  final double manualExposure;
  final ValueChanged<double>? onManualExposureChanged;
  final double focalPreset;
  final ValueChanged<double>? onFocalPresetTap;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final showOptions = !compactMode && optionsExpanded;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.82),
            Colors.black.withValues(alpha: 0.38),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showOptions) ...[
                if (proModeEnabled && onFocalPresetTap != null) ...[
                  IosFocalPresets(
                    currentZoom: focalPreset,
                    onPresetTap: onFocalPresetTap!,
                  ),
                  const SizedBox(height: 6),
                ],
                if (proModeEnabled && onManualExposureChanged != null) ...[
                  IosExposureSlider(
                    value: manualExposure,
                    onChanged: onManualExposureChanged!,
                  ),
                  const SizedBox(height: 6),
                ],
                IosCameraOptionsStrip(
                  hdrEnabled: hdrEnabled,
                  hdrSupported: hdrSupported,
                  hdrLabel: hdrLabel,
                  timerDuration: timerDuration,
                  aeAfLocked: aeAfLocked,
                  isBursting: isBursting,
                  burstCount: burstCount,
                  expanded: showOptions,
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
                ),
              ] else if (!compactMode)
                GestureDetector(
                  onTap: onToggleOptions,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
              Text(
                modeLabel,
                style: const TextStyle(
                  color: Color(0xFFFFD60A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 76,
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
                          onBurstStart: shutterEnabled ? onBurstStart : null,
                          onBurstEnd: shutterEnabled ? onBurstEnd : null,
                          isCapturing: isCapturing,
                          isBursting: isBursting,
                          enabled: shutterEnabled,
                        ),
                      ),
                    ),
                    _FlipCameraButton(
                      onTap: canFlip ? onFlipCamera : null,
                      enabled: canFlip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlipCameraButton extends StatelessWidget {
  const _FlipCameraButton({required this.onTap, required this.enabled});

  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF3A3A3C),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.cameraswitch_rounded,
          color: Colors.white.withOpacity(enabled ? 1 : 0.35),
          size: 26,
        ),
      ),
    );
  }
}