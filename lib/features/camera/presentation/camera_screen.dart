import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../models/shoot_session.dart';
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
              enableAr: false,
              shootSessionMode: ShootSessionMode.free,
              child: IosCameraScaffold(
                shootSessionMode: ShootSessionMode.free,
                controller: controller,
                modeLabel: l10n.cameraModePhoto,
                gridEnabled: overlayVisible,
                showGridButton: false,
                croppedOverlay: null,
                overlay: const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
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