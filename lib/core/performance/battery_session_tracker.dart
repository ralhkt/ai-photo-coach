import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final batterySessionTrackerProvider = Provider<BatterySessionTracker>((ref) {
  return BatterySessionTracker();
});

final lastBatteryReportProvider = StateProvider<BatterySessionReport?>((ref) {
  return null;
});

class BatterySessionReport {
  const BatterySessionReport({
    required this.startPercent,
    required this.endPercent,
    required this.duration,
    required this.recordedAt,
  });

  final int startPercent;
  final int endPercent;
  final Duration duration;
  final DateTime recordedAt;

  int get deltaPercent => (startPercent - endPercent).clamp(0, 100);

  double get drainPer10Minutes {
    if (duration.inSeconds <= 0) {
      return 0;
    }
    return deltaPercent * 600 / duration.inSeconds;
  }

  bool get withinMvpBudget =>
      drainPer10Minutes <= 7.0 || duration.inMinutes < 3;
}

class BatterySessionTracker {
  BatterySessionTracker({Battery? battery}) : _battery = battery ?? Battery();

  final Battery _battery;
  int? _startPercent;
  DateTime? _startedAt;

  Future<void> begin() async {
    _startPercent = await _safeLevel();
    _startedAt = DateTime.now();
  }

  Future<BatterySessionReport?> end() async {
    final start = _startPercent;
    final startedAt = _startedAt;
    _startPercent = null;
    _startedAt = null;

    if (start == null || startedAt == null) {
      return null;
    }

    final endPercent = await _safeLevel();
    return BatterySessionReport(
      startPercent: start,
      endPercent: endPercent,
      duration: DateTime.now().difference(startedAt),
      recordedAt: DateTime.now(),
    );
  }

  Future<int> _safeLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return -1;
    }
  }
}