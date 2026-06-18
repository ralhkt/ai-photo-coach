import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ar_platform_service.dart';
import '../services/device_attitude_service.dart';

final arPlatformServiceProvider = Provider<ArPlatformService>(
  (ref) => ArPlatformService(),
);

final deviceAttitudeServiceProvider = Provider<DeviceAttitudeService>(
  (ref) => DeviceAttitudeService(),
);

final arSessionProvider =
    AsyncNotifierProvider<ArSessionNotifier, ArPlatformStatus>(
  ArSessionNotifier.new,
);

class ArSessionNotifier extends AsyncNotifier<ArPlatformStatus> {
  StreamSubscription<ArPlatformStatus>? _subscription;

  @override
  Future<ArPlatformStatus> build() async {
    ref.onDispose(() async {
      await _subscription?.cancel();
      await ref.read(arPlatformServiceProvider).stopSession();
    });

    final service = ref.read(arPlatformServiceProvider);
    final initial = await service.checkSupport();
    return initial;
  }

  Future<void> start() async {
    final service = ref.read(arPlatformServiceProvider);
    await service.startSession();
    await _subscription?.cancel();
    _subscription = service.watchStatus().listen((status) {
      state = AsyncData(status);
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await ref.read(arPlatformServiceProvider).stopSession();
    state = AsyncData(await ref.read(arPlatformServiceProvider).checkSupport());
  }
}

final deviceAttitudeProvider = StreamProvider<DeviceAttitude>((ref) {
  return ref.watch(deviceAttitudeServiceProvider).watchAttitude();
});

final arOverlayVisibleProvider = StateProvider<bool>((ref) => true);