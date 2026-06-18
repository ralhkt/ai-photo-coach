import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class IosCameraTopBar extends StatelessWidget {
  const IosCameraTopBar({
    super.key,
    required this.flashMode,
    required this.onClose,
    required this.onFlashTap,
    this.onGridTap,
    this.onFrameTap,
    this.gridEnabled = false,
    this.frameEnabled = false,
    this.showGridButton = true,
    this.showFrameButton = false,
    this.centerLabel,
    this.hdrEnabled = false,
    this.aeAfLocked = false,
    this.aeAfLockLabel,
    this.showAiAnalyzeButton = false,
    this.aiAnalyzing = false,
    this.onAiAnalyzeTap,
    this.aiAnalyzeTooltip,
    this.showAspectRatioButton = false,
    this.aspectRatioLabel,
    this.onAspectRatioTap,
  });

  final FlashMode flashMode;
  final VoidCallback onClose;
  final VoidCallback onFlashTap;
  final VoidCallback? onGridTap;
  final VoidCallback? onFrameTap;
  final bool gridEnabled;
  final bool frameEnabled;
  final bool showGridButton;
  final bool showFrameButton;
  final String? centerLabel;
  final bool hdrEnabled;
  final bool aeAfLocked;
  final String? aeAfLockLabel;
  final bool showAiAnalyzeButton;
  final bool aiAnalyzing;
  final VoidCallback? onAiAnalyzeTap;
  final String? aiAnalyzeTooltip;
  final bool showAspectRatioButton;
  final String? aspectRatioLabel;
  final VoidCallback? onAspectRatioTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  _TopIconButton(
                    icon: Icons.close_rounded,
                    onTap: onClose,
                  ),
                  _FlashButton(
                    flashMode: flashMode,
                    onTap: onFlashTap,
                  ),
                  Expanded(
                    child: Center(
                      child: centerLabel != null
                          ? Text(
                              centerLabel!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            )
                          : showAspectRatioButton &&
                                  aspectRatioLabel != null &&
                                  onAspectRatioTap != null
                              ? _AspectRatioChip(
                                  label: aspectRatioLabel!,
                                  onTap: onAspectRatioTap!,
                                )
                              : const SizedBox.shrink(),
                    ),
                  ),
                  if (showFrameButton)
                    _TopIconButton(
                      icon: Icons.crop_free_rounded,
                      onTap: onFrameTap,
                      isActive: frameEnabled,
                    )
                  else if (showAiAnalyzeButton)
                    _AiAnalyzeButton(
                      analyzing: aiAnalyzing,
                      onTap: onAiAnalyzeTap,
                      tooltip: aiAnalyzeTooltip,
                    )
                  else
                    const SizedBox(width: 44),
                  if (showGridButton)
                    _TopIconButton(
                      icon: gridEnabled
                          ? Icons.grid_on_rounded
                          : Icons.grid_off_rounded,
                      onTap: onGridTap,
                      isActive: gridEnabled,
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),
            if (hdrEnabled || aeAfLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hdrEnabled)
                      const _StatusBadge(label: 'HDR'),
                    if (hdrEnabled && aeAfLocked) const SizedBox(width: 8),
                    if (aeAfLocked && aeAfLockLabel != null)
                      _StatusBadge(label: aeAfLockLabel!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x33FFD60A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFFD60A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
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
    final label = switch (flashMode) {
      FlashMode.off => 'OFF',
      FlashMode.auto => 'AUTO',
      FlashMode.always => 'ON',
      FlashMode.torch => 'TORCH',
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              flashMode == FlashMode.torch
                  ? Icons.flashlight_on_rounded
                  : Icons.flash_on_rounded,
              color: flashMode == FlashMode.off
                  ? Colors.white54
                  : const Color(0xFFFFD60A),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: flashMode == FlashMode.off
                    ? Colors.white54
                    : const Color(0xFFFFD60A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAnalyzeButton extends StatelessWidget {
  const _AiAnalyzeButton({
    required this.analyzing,
    required this.onTap,
    this.tooltip,
  });

  final bool analyzing;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: analyzing ? null : onTap,
        tooltip: tooltip,
        icon: analyzing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFFD60A),
                ),
              )
            : const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFD60A),
                size: 22,
              ),
      ),
    );
  }
}

class _AspectRatioChip extends StatelessWidget {
  const _AspectRatioChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white38),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.aspect_ratio_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: isActive ? const Color(0xFFFFD60A) : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}