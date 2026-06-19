import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timestamp of the last camera chrome tap — pauses background [takePicture] polling.
final cameraUiInteractionProvider = StateProvider<DateTime?>((ref) => null);

const cameraUiInteractionPause = Duration(seconds: 4);

void markCameraUiInteraction(WidgetRef ref) {
  ref.read(cameraUiInteractionProvider.notifier).state = DateTime.now();
}

/// True while background capture should yield to UI interaction.
final isCameraUiInteractionPausedProvider = Provider<bool>((ref) {
  final last = ref.watch(cameraUiInteractionProvider);
  if (last == null) {
    return false;
  }
  return DateTime.now().difference(last) < cameraUiInteractionPause;
});