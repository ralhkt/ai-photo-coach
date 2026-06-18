import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

class DeviceAttitude {
  const DeviceAttitude({
    required this.pitchDegrees,
    required this.rollDegrees,
    required this.isLevel,
  });

  final double pitchDegrees;
  final double rollDegrees;
  final bool isLevel;
}

class DeviceAttitudeService {
  Stream<DeviceAttitude> watchAttitude() {
    return accelerometerEventStream().map((event) {
      final pitch = math.atan2(event.y, event.z) * 180 / math.pi;
      final roll = math.atan2(event.x, event.z) * 180 / math.pi;
      return DeviceAttitude(
        pitchDegrees: pitch,
        rollDegrees: roll,
        isLevel: pitch.abs() < 4 && roll.abs() < 4,
      );
    });
  }
}