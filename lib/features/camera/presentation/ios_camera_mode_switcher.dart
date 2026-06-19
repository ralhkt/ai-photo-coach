import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../reference/presentation/reference_upload_screen.dart';
import '../../reference/providers/reference_providers.dart';
import 'camera_screen.dart';
import 'camera_shell_mode.dart';
import 'guided_camera_screen.dart';

/// Cross-fades between free [CameraScreen] and [GuidedCameraScreen].
Future<void> switchIosCameraShellMode({
  required BuildContext context,
  required WidgetRef ref,
  required CameraShellMode current,
  required CameraShellMode target,
}) async {
  if (target == current) {
    return;
  }

  final l10n = AppLocalizations.of(context)!;

  if (target == CameraShellMode.video) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(l10n.cameraModeVideoComingSoon),
      ),
    );
    return;
  }

  if (target == CameraShellMode.guided) {
    final analysis = ref.read(referenceAnalysisProvider).value;
    if (analysis == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.cameraModeSwitchNeedReference),
          action: SnackBarAction(
            label: l10n.cameraModeUploadReference,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ReferenceUploadScreen(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
  }

  final next = switch (target) {
    CameraShellMode.photo => const CameraScreen(),
    CameraShellMode.guided => const GuidedCameraScreen(),
    CameraShellMode.video => const CameraScreen(),
  };

  await Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => next,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}