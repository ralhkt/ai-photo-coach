import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../models/shoot_session.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_settings_provider.dart';
import '../providers/camera_shell_provider.dart';
import '../providers/pose_contour_stabilizer_provider.dart';
import 'camera_shell_mode.dart';
import 'widgets/camera_error_view.dart';
import 'widgets/camera_mode_scope.dart';
import 'widgets/camera_session_lifecycle.dart';
import 'widgets/guided_mode_camera_host.dart';
import 'widgets/ios_camera_scaffold.dart';

/// Single camera route — mode carousel swaps overlays without [Navigator] replacement.
class IosCameraShellScreen extends ConsumerStatefulWidget {
  const IosCameraShellScreen({
    super.key,
    this.initialMode = CameraShellMode.photo,
  });

  final CameraShellMode initialMode;

  @override
  ConsumerState<IosCameraShellScreen> createState() =>
      _IosCameraShellScreenState();
}

class _IosCameraShellScreenState extends ConsumerState<IosCameraShellScreen> {
  bool _guidanceApplied = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cameraShellModeProvider.notifier).state = widget.initialMode;
    });
  }

  Future<void> _applyAnalysisGuidance() async {
    final analysis = ref.read(referenceAnalysisProvider).value;
    if (analysis == null || _guidanceApplied) {
      return;
    }

    _guidanceApplied = true;
    ref.read(overlayTypeProvider.notifier).state = analysis.guidance.overlayType;
    await ref.read(cameraControllerProvider.notifier).applyGuidanceSettings(
          analysis.guidance,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shellMode = ref.watch(cameraShellModeProvider);
    final isGuided = shellMode == CameraShellMode.guided;
    // Rebuild guided host only when reference photo changes — not on template toggle.
    if (isGuided) {
      ref.watch(
        referenceAnalysisProvider.select(
          (async) => async.value?.imageBytes.length,
        ),
      );
    }
    final analysis = ref.read(referenceAnalysisProvider).value;
    final cameraState = ref.watch(cameraControllerProvider);

    if (isGuided && analysis == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(l10n.noReferenceLoaded)),
      );
    }

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
          if (controller == null || !controller.value.isInitialized) {
            return CameraErrorView(
              message: l10n.noCameraFound,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(cameraControllerProvider.notifier).retry(),
            );
          }

          if (isGuided && analysis != null) {
            return GuidedModeCameraHost(
              key: ValueKey(analysis.imageBytes.hashCode),
              controller: controller,
              analysis: analysis,
              shellMode: shellMode,
              onApplyGuidance: _applyAnalysisGuidance,
            );
          }

          final overlayVisible = ref.watch(overlayVisibleProvider);
          return CameraModeScope(
            mode: CameraUiMode.free,
            child: CameraSessionLifecycle(
              controller: controller,
              enableAr: true,
              shootSessionMode: ShootSessionMode.free,
              child: IosCameraScaffold(
                controller: controller,
                enablePhase2: true,
                shootSessionMode: ShootSessionMode.free,
                modeLabel: _modeLabel(l10n, shellMode),
                gridEnabled: overlayVisible,
                overlay: const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _modeLabel(AppLocalizations l10n, CameraShellMode mode) {
    return switch (mode) {
      CameraShellMode.video => l10n.cameraModeVideo,
      CameraShellMode.photo => l10n.cameraModePhoto,
      CameraShellMode.guided => l10n.cameraModeGuided,
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