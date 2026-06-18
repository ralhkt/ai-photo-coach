import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../../models/shoot_session.dart';
import 'quick_photo_scorer.dart';

typedef SessionBuildProgress = void Function(int completed, int total);

final sessionSummaryBuilderProvider = Provider<SessionSummaryBuilder>((ref) {
  return SessionSummaryBuilder(
    quickScorer: ref.watch(quickPhotoScorerProvider),
    tracker: ref.watch(performanceTrackerProvider),
    powerSave: ref.watch(powerSaveEnabledProvider),
  );
});

class SessionSummaryBuilder {
  SessionSummaryBuilder({
    required this.quickScorer,
    required this.tracker,
    required this.powerSave,
    this.maxAnalyzedPhotos = 12,
  });

  final QuickPhotoScorer quickScorer;
  final PerformanceTracker tracker;
  final bool powerSave;
  final int maxAnalyzedPhotos;

  Future<SessionSummary> build(
    ShootSession session, {
    SessionBuildProgress? onProgress,
    int? batteryDeltaPercent,
  }) async {
    final stopwatch = Stopwatch()..start();
    final selected = _selectCaptures(session.captures);
    final insights = <SessionPhotoInsight>[];
    var aestheticTotal = 0.0;
    var aestheticCount = 0;
    int? bestIndex;
    double? bestScore;

    for (var i = 0; i < selected.length; i++) {
      final entry = selected[i];
      final scoreResult = await quickScorer.score(
        entry.capture.photo.bytes,
        powerSave: powerSave,
      );

      insights.add(
        SessionPhotoInsight(
          index: entry.originalIndex,
          brightness: scoreResult.brightness,
          aestheticScore: scoreResult.aestheticScore,
          thumbnailBytes: scoreResult.thumbnailBytes,
        ),
      );

      aestheticTotal += scoreResult.aestheticScore;
      aestheticCount++;
      if (bestScore == null || scoreResult.aestheticScore > bestScore) {
        bestScore = scoreResult.aestheticScore;
        bestIndex = entry.originalIndex;
      }

      onProgress?.call(i + 1, selected.length);
    }

    final average = aestheticCount > 0 ? aestheticTotal / aestheticCount : null;
    final elapsed = stopwatch.elapsedMilliseconds;
    tracker.record(
      'session_summary_total',
      elapsed,
      budgetMs: PerformanceBudget.sessionTotalAnalysisMs,
    );

    return SessionSummary(
      session: session,
      photoInsights: insights,
      averageAestheticScore: average,
      bestPhotoIndex: bestIndex,
      feedbackTipKeys: _deriveTipKeys(
        session: session,
        insights: insights,
        averageScore: average,
      ),
      analysisDurationMs: elapsed,
      batteryDeltaPercent: batteryDeltaPercent,
    );
  }

  List<_IndexedCapture> _selectCaptures(List<SessionCapture> captures) {
    if (captures.length <= maxAnalyzedPhotos) {
      return [
        for (var i = 0; i < captures.length; i++)
          _IndexedCapture(originalIndex: i, capture: captures[i]),
      ];
    }

    final selected = <_IndexedCapture>[];
    final step = (captures.length - 1) / (maxAnalyzedPhotos - 1);
    for (var i = 0; i < maxAnalyzedPhotos; i++) {
      final index = (i * step).round().clamp(0, captures.length - 1);
      selected.add(
        _IndexedCapture(originalIndex: index, capture: captures[index]),
      );
    }
    return selected;
  }

  List<String> _deriveTipKeys({
    required ShootSession session,
    required List<SessionPhotoInsight> insights,
    required double? averageScore,
  }) {
    final tips = <String>[];

    if (session.mode == ShootSessionMode.guided) {
      tips.add('sessionTipGuidedPractice');
    } else {
      tips.add('sessionTipTryGuided');
    }

    if (averageScore != null) {
      if (averageScore >= 0.75) {
        tips.add('sessionTipStrongComposition');
      } else if (averageScore < 0.55) {
        tips.add('sessionTipImproveLighting');
      } else {
        tips.add('sessionTipRefineFraming');
      }
    }

    if (insights.isNotEmpty) {
      final avgBrightness =
          insights.map((item) => item.brightness).reduce((a, b) => a + b) /
              insights.length;
      if (avgBrightness < 0.35) {
        tips.add('sessionTipTooDark');
      } else if (avgBrightness > 0.78) {
        tips.add('sessionTipTooBright');
      } else {
        tips.add('sessionTipBalancedExposure');
      }
    }

    if (session.captures.length >= 5) {
      tips.add('sessionTipGreatVolume');
    }

    return tips.take(4).toList();
  }
}

class _IndexedCapture {
  const _IndexedCapture({
    required this.originalIndex,
    required this.capture,
  });

  final int originalIndex;
  final SessionCapture capture;
}