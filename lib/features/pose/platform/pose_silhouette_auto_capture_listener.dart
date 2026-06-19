import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/providers/camera_capture_provider.dart';
import '../../camera/providers/camera_providers.dart';
import '../../camera/providers/camera_settings_provider.dart';
import '../providers/pose_silhouette_provider.dart';
import 'pose_silhouette_platform_service.dart';

/// Triggers guided auto-shutter when native state machine reports a match.
class PoseSilhouetteAutoCaptureListener extends ConsumerStatefulWidget {
  const PoseSilhouetteAutoCaptureListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PoseSilhouetteAutoCaptureListener> createState() =>
      _PoseSilhouetteAutoCaptureListenerState();
}

class _PoseSilhouetteAutoCaptureListenerState
    extends ConsumerState<PoseSilhouetteAutoCaptureListener> {
  DateTime _lastCaptureAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    final supported =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull ?? false;
    final autoEnabled = ref.watch(poseSilhouetteAutoCaptureEnabledProvider);

    if (supported && autoEnabled) {
      ref.listen<AsyncValue<PoseSilhouetteAlignmentEvent>>(
        poseSilhouetteAlignmentStreamProvider,
        (previous, next) {
          final event = next.valueOrNull;
          if (event == null ||
              !event.autoCaptureRequested ||
              !event.enabled) {
            return;
          }
          _triggerAutoCapture();
        },
      );
    }

    return widget.child;
  }

  Future<void> _triggerAutoCapture() async {
    final now = DateTime.now();
    if (now.difference(_lastCaptureAt) < const Duration(seconds: 2)) {
      return;
    }

    final isCapturing = ref.read(isCapturingProvider);
    final isBursting = ref.read(isBurstingProvider);
    if (isCapturing || isBursting) {
      return;
    }

    _lastCaptureAt = now;
    await ref.read(cameraControllerProvider.notifier).captureWithTimer();
  }
}

final poseSilhouetteAlignmentStreamProvider =
    StreamProvider<PoseSilhouetteAlignmentEvent>((ref) {
  return ref.watch(poseSilhouetteServiceProvider).watchAlignment();
});