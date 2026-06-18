import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ArPlaneState {
  unsupported,
  unavailable,
  searching,
  detected,
}

class ArPlatformStatus {
  const ArPlatformStatus({
    required this.isSupported,
    required this.planeState,
    required this.horizontalPlanes,
  });

  final bool isSupported;
  final ArPlaneState planeState;
  final int horizontalPlanes;

  static const initial = ArPlatformStatus(
    isSupported: false,
    planeState: ArPlaneState.unsupported,
    horizontalPlanes: 0,
  );
}

class ArPlatformService {
  static const _channel = MethodChannel('com.aiphotocoach.app/ar');
  static const _eventChannel = EventChannel('com.aiphotocoach.app/ar_events');

  Stream<ArPlatformStatus>? _statusStream;

  Future<ArPlatformStatus> checkSupport() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('checkSupport');
      return _parseStatus(result);
    } on PlatformException catch (error) {
      debugPrint('AR checkSupport failed: ${error.message}');
      return ArPlatformStatus.initial;
    }
  }

  Future<void> startSession() async {
    try {
      await _channel.invokeMethod<void>('startSession');
    } on PlatformException catch (error) {
      debugPrint('AR startSession failed: ${error.message}');
    }
  }

  Future<void> stopSession() async {
    try {
      await _channel.invokeMethod<void>('stopSession');
    } on PlatformException catch (error) {
      debugPrint('AR stopSession failed: ${error.message}');
    }
  }

  Stream<ArPlatformStatus> watchStatus() {
    _statusStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => _parseStatus(event as Map<dynamic, dynamic>?))
        .handleError((Object error) {
      debugPrint('AR event stream error: $error');
      return ArPlatformStatus.initial;
    });
    return _statusStream!;
  }

  ArPlatformStatus _parseStatus(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return ArPlatformStatus.initial;
    }

    final stateName = map['planeState'] as String? ?? 'unsupported';
    final state = ArPlaneState.values.firstWhere(
      (value) => value.name == stateName,
      orElse: () => ArPlaneState.unsupported,
    );

    return ArPlatformStatus(
      isSupported: map['isSupported'] as bool? ?? false,
      planeState: state,
      horizontalPlanes: map['horizontalPlanes'] as int? ?? 0,
    );
  }
}