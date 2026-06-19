import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../../models/camera_timer_duration.dart';
import '../../../models/captured_photo.dart';
import '../../../models/focus_indicator_state.dart';
import '../services/camera_hdr_capability.dart';

/// HDR fusion is not exposed by the camera plugin today.
final hdrSupportedProvider = Provider<bool>((ref) => CameraHdrCapability.isSupported);

/// Off by default until [hdrSupportedProvider] is true.
final hdrEnabledProvider = StateProvider<bool>((ref) => false);

final timerDurationProvider = StateProvider<CameraTimerDuration>(
  (ref) => CameraTimerDuration.off,
);

final timerCountdownProvider = StateProvider<int?>((ref) => null);

final isBurstingProvider = StateProvider<bool>((ref) => false);

final burstPhotosProvider = StateProvider<List<CapturedPhoto>>((ref) => const []);

final aeAfLockProvider = StateProvider<bool>((ref) => false);

final focusIndicatorProvider = StateProvider<FocusIndicatorState?>(
  (ref) => null,
);

final showCameraOptionsProvider = StateProvider<bool>((ref) => true);

final proModeEnabledProvider = StateProvider<bool>((ref) => false);

final cameraAspectRatioProvider = StateProvider<CameraAspectRatio>(
  (ref) => CameraAspectRatio.ratio4x3,
);

final manualExposureOffsetProvider = StateProvider<double>((ref) => 0);

final frontMirrorEnabledProvider = StateProvider<bool>((ref) => true);

final focalPresetProvider = StateProvider<double>((ref) => 1.0);

final showHistogramProvider = StateProvider<bool>((ref) => false);