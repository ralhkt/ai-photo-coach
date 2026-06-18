import 'package:flutter_riverpod/flutter_riverpod.dart';

final performanceTrackerProvider = Provider<PerformanceTracker>((ref) {
  return PerformanceTracker();
});

class PerformanceSample {
  const PerformanceSample({
    required this.label,
    required this.durationMs,
    required this.recordedAt,
    required this.withinBudget,
  });

  final String label;
  final int durationMs;
  final DateTime recordedAt;
  final bool withinBudget;
}

class PerformanceTracker {
  final List<PerformanceSample> _samples = [];
  static const _maxSamples = 80;

  List<PerformanceSample> get samples => List.unmodifiable(_samples);

  void record(String label, int durationMs, {required int budgetMs}) {
    _samples.add(
      PerformanceSample(
        label: label,
        durationMs: durationMs,
        recordedAt: DateTime.now(),
        withinBudget: durationMs <= budgetMs,
      ),
    );
    if (_samples.length > _maxSamples) {
      _samples.removeAt(0);
    }
  }

  double averageMs(String label) {
    final matches =
        _samples.where((sample) => sample.label == label).toList();
    if (matches.isEmpty) {
      return 0;
    }
    final total = matches.fold<int>(0, (sum, item) => sum + item.durationMs);
    return total / matches.length;
  }

  int countOverBudget(String label) {
    return _samples
        .where((sample) => sample.label == label && !sample.withinBudget)
        .length;
  }

  void clear() => _samples.clear();
}