import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../reference/presentation/reference_upload_screen.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_shell_provider.dart';
import 'camera_shell_mode.dart';

/// Updates shell mode in-place — no [Navigator] replacement (avoids camera re-init lag).
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

  ref.read(cameraShellModeProvider.notifier).state = target;
  final settingsNotifier = ref.read(cameraModeSettingsProvider.notifier);
  final uiMode = target == CameraShellMode.guided
      ? CameraUiMode.guided
      : CameraUiMode.free;
  await settingsNotifier.activateMode(uiMode, applyHardware: false);
  unawaited(settingsNotifier.applyActiveHardwareInBackground());
}