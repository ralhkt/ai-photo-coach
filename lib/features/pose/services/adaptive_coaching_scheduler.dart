import '../models/pose_coaching_result.dart';
import 'pose_aesthetic_analyzer.dart';

/// Dynamically adjusts preview capture rate based on coaching state.
class AdaptiveCoachingScheduler {
  AdaptiveCoachingScheduler({
    this.searchingInterval = const Duration(milliseconds: 500),
    this.adjustingInterval = const Duration(milliseconds: 650),
    this.matchedInterval = const Duration(milliseconds: 1000),
    this.powerSaveInterval = const Duration(milliseconds: 1100),
  });

  final Duration searchingInterval;
  final Duration adjustingInterval;
  final Duration matchedInterval;
  final Duration powerSaveInterval;

  int _stableMatchedFrames = 0;
  int _lastScore = 0;

  Duration nextInterval({
    PoseCoachingResult? lastResult,
    bool powerSave = false,
  }) {
    if (powerSave) {
      return powerSaveInterval;
    }

    if (lastResult == null) {
      _stableMatchedFrames = 0;
      return searchingInterval;
    }

    final score = lastResult.poseScore ?? 0;
    final delta = (score - _lastScore).abs();
    _lastScore = score;

    if (score >= PoseAestheticAnalyzer.posePassScore && delta < 4) {
      _stableMatchedFrames++;
      if (_stableMatchedFrames >= 4) {
        return matchedInterval;
      }
      return adjustingInterval;
    }

    _stableMatchedFrames = 0;
    if (score < 55) {
      return searchingInterval;
    }
    return adjustingInterval;
  }

  bool shouldCapture(DateTime lastCapture, Duration interval, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return timestamp.difference(lastCapture) >= interval;
  }

  void reset() {
    _stableMatchedFrames = 0;
    _lastScore = 0;
  }
}