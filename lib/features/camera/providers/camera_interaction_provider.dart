import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timestamp of the last heavy camera action (shutter / flip / burst).
final cameraUiInteractionProvider = StateProvider<DateTime?>((ref) => null);

const cameraUiInteractionPause = Duration(seconds: 2);

/// Last guided-mode UI tap — ML yields until this cools down.
final guidedUserActivityProvider = StateProvider<DateTime?>((ref) => null);

const guidedMlIdleAfterInteraction = Duration(milliseconds: 2500);

/// Brief UI-busy gate — pauses background ML while chrome is tapped.
final cameraChromeBusyProvider =
    NotifierProvider<CameraChromeBusyNotifier, bool>(
  CameraChromeBusyNotifier.new,
);

class CameraChromeBusyNotifier extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  void bump({Duration hold = const Duration(milliseconds: 500)}) {
    state = true;
    _timer?.cancel();
    _timer = Timer(hold, () => state = false);
  }
}

/// Guided chrome tap — blocks ML only, never touches the camera session.
void markGuidedUserActivity(WidgetRef ref) {
  ref.read(guidedUserActivityProvider.notifier).state = DateTime.now();
}

bool isGuidedUserRecentlyActive(DateTime? last) {
  if (last == null) {
    return false;
  }
  return DateTime.now().difference(last) < guidedMlIdleAfterInteraction;
}

/// Heavy capture paths — pauses preview sampling longer.
void markHeavyCameraInteraction(WidgetRef ref) {
  markGuidedUserActivity(ref);
  ref.read(cameraUiInteractionProvider.notifier).state = DateTime.now();
  ref.read(cameraChromeBusyProvider.notifier).bump(
        hold: cameraUiInteractionPause,
      );
}

/// Lightweight chrome taps — short ML pause only.
void markCameraChromeTap(WidgetRef ref) {
  markGuidedUserActivity(ref);
  ref.read(cameraChromeBusyProvider.notifier).bump();
}

@Deprecated('Use markHeavyCameraInteraction or markCameraChromeTap')
void markCameraUiInteraction(WidgetRef ref) {
  markHeavyCameraInteraction(ref);
}

/// True while background capture should yield to heavy camera interaction.
final isCameraUiInteractionPausedProvider = Provider<bool>((ref) {
  final last = ref.watch(cameraUiInteractionProvider);
  if (last == null) {
    return false;
  }
  return DateTime.now().difference(last) < cameraUiInteractionPause;
});