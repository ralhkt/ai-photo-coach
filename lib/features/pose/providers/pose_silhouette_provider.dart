import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/pose_silhouette_platform_service.dart';
import '../platform/pose_silhouette_sync_controller.dart';
final poseSilhouetteServiceProvider = Provider<PoseSilhouettePlatformService>(
  (ref) => PoseSilhouettePlatformService(),
);

final poseSilhouetteSyncControllerProvider = Provider<PoseSilhouetteSyncController>(
  (ref) => PoseSilhouetteSyncController(),
);

final poseSilhouetteNativeSupportedProvider = FutureProvider<bool>((ref) async {
  return ref.read(poseSilhouetteServiceProvider).isSupported();
});

final poseSilhouetteAutoCaptureEnabledProvider = StateProvider<bool>(
  (ref) => true,
);

