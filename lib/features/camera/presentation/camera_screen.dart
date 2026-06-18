import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/shoot_session.dart';
import '../../overlays/presentation/composition_overlay.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_mode_settings_provider.dart';
import 'widgets/camera_error_view.dart';
import 'widgets/camera_mode_scope.dart';
import 'widgets/camera_session_lifecycle.dart';
import 'widgets/ios_camera_scaffold.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cameraState = ref.watch(cameraControllerProvider);
    final overlayVisible = ref.watch(overlayVisibleProvider);
    final overlayType = ref.watch(overlayTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraState.when(
        loading: () => _LoadingView(message: l10n.initializingCamera),
        error: (error, _) => CameraErrorView(
          message: l10n.cameraError,
          detail: error.toString(),
          retryLabel: l10n.retry,
          onRetry: () => ref.read(cameraControllerProvider.notifier).retry(),
        ),
        data: (controller) {
          if (controller == null) {
            return CameraErrorView(
              message: l10n.noCameraFound,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(cameraControllerProvider.notifier).retry(),
            );
          }

          if (!controller.value.isInitialized) {
            return _LoadingView(message: l10n.initializingCamera);
          }

          return CameraModeScope(
            mode: CameraUiMode.free,
            child: CameraSessionLifecycle(
            controller: controller,
            enableAr: true,
            shootSessionMode: ShootSessionMode.free,
            child: IosCameraScaffold(
              shootSessionMode: ShootSessionMode.free,
              controller: controller,
              modeLabel: l10n.cameraModePhoto,
              gridEnabled: overlayVisible,
              showGridButton: true,
              onGridTap: () {
                ref.read(overlayVisibleProvider.notifier).state = !overlayVisible;
              },
              croppedOverlay: CompositionOverlay(
                type: overlayType,
                visible: overlayVisible,
              ),
              overlay: Stack(
                fit: StackFit.expand,
                children: [
                  if (overlayVisible)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 190,
                      child: _CompositionModeStrip(
                        overlayType: overlayType,
                        onCycle: () {
                          ref.read(overlayTypeProvider.notifier).state =
                              overlayType.next;
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}

class _CompositionModeStrip extends StatelessWidget {
  const _CompositionModeStrip({
    required this.overlayType,
    required this.onCycle,
  });

  final CompositionOverlayType overlayType;
  final VoidCallback onCycle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: GestureDetector(
        onTap: onCycle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.grid_on_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _label(l10n, overlayType),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more_rounded, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n, CompositionOverlayType type) {
    return switch (type) {
      CompositionOverlayType.ruleOfThirds => l10n.overlayRuleOfThirds,
      CompositionOverlayType.goldenRatio => l10n.overlayGoldenRatio,
      CompositionOverlayType.center => l10n.overlayCenter,
      CompositionOverlayType.diagonal => l10n.overlayDiagonal,
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

