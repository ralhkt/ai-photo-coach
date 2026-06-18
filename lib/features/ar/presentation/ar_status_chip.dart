import 'package:flutter/material.dart';

import '../../scene_stabilization/providers/scene_stability_provider.dart';
import '../services/ar_platform_service.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class ArStatusChip extends StatelessWidget {
  const ArStatusChip({
    super.key,
    required this.arStatus,
    required this.sceneStatus,
  });

  final ArPlatformStatus arStatus;
  final SceneStabilityStatus sceneStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _arIcon(arStatus.planeState),
            size: 14,
            color: _arColor(arStatus.planeState),
          ),
          const SizedBox(width: 6),
          Text(
            _arLabel(l10n, arStatus),
            style: TextStyle(
              color: _arColor(arStatus.planeState),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            sceneStatus.state == SceneStabilityState.stable
                ? Icons.lock_clock_rounded
                : Icons.motion_photos_on_outlined,
            size: 14,
            color: sceneStatus.state == SceneStabilityState.stable
                ? const Color(0xFF80CBC4)
                : Colors.white54,
          ),
          const SizedBox(width: 4),
          Text(
            _sceneLabel(l10n, sceneStatus),
            style: TextStyle(
              color: sceneStatus.state == SceneStabilityState.stable
                  ? const Color(0xFF80CBC4)
                  : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _arIcon(ArPlaneState state) {
    return switch (state) {
      ArPlaneState.detected => Icons.view_in_ar_rounded,
      ArPlaneState.searching => Icons.radar_rounded,
      ArPlaneState.unavailable => Icons.block_rounded,
      ArPlaneState.unsupported => Icons.view_in_ar_outlined,
    };
  }

  Color _arColor(ArPlaneState state) {
    return switch (state) {
      ArPlaneState.detected => const Color(0xFFFFD60A),
      ArPlaneState.searching => Colors.white70,
      _ => Colors.white38,
    };
  }

  String _arLabel(AppLocalizations l10n, ArPlatformStatus status) {
    return switch (status.planeState) {
      ArPlaneState.detected => l10n.arPlaneDetected(status.horizontalPlanes),
      ArPlaneState.searching => l10n.arPlaneSearching,
      ArPlaneState.unavailable => l10n.arUnavailable,
      ArPlaneState.unsupported => l10n.arUnsupported,
    };
  }

  String _sceneLabel(AppLocalizations l10n, SceneStabilityStatus status) {
    return switch (status.state) {
      SceneStabilityState.stable => l10n.sceneStable,
      SceneStabilityState.changed => l10n.sceneChanged,
      SceneStabilityState.monitoring => l10n.sceneMonitoring,
      SceneStabilityState.idle => l10n.sceneIdle,
    };
  }
}