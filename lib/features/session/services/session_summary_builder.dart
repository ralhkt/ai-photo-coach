import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/shoot_session.dart';
import '../../reference/providers/reference_providers.dart';
import '../../reference/services/image_analyzer_service.dart';

final sessionSummaryBuilderProvider = Provider<SessionSummaryBuilder>((ref) {
  return SessionSummaryBuilder(
    analyzer: ref.watch(imageAnalyzerProvider),
  );
});

class SessionSummaryBuilder {
  SessionSummaryBuilder({required this.analyzer});

  final ImageAnalyzerService analyzer;

  Future<SessionSummary> build(ShootSession session) async {
    final insights = <SessionPhotoInsight>[];
    var aestheticTotal = 0.0;
    var aestheticCount = 0;
    int? bestIndex;
    double? bestScore;

    for (var i = 0; i < session.captures.length; i++) {
      final capture = session.captures[i];
      final analysis = await analyzer.analyze(capture.photo.bytes);
      final score = analysis.mlDetection?.aestheticScore;
      insights.add(
        SessionPhotoInsight(
          index: i,
          brightness: analysis.brightness,
          aestheticScore: score,
          thumbnailBytes: capture.photo.bytes,
        ),
      );

      if (score != null) {
        aestheticTotal += score;
        aestheticCount++;
        if (bestScore == null || score > bestScore) {
          bestScore = score;
          bestIndex = i;
        }
      }
    }

    final average = aestheticCount > 0 ? aestheticTotal / aestheticCount : null;
    final tipKeys = _deriveTipKeys(
      session: session,
      insights: insights,
      averageScore: average,
    );

    return SessionSummary(
      session: session,
      photoInsights: insights,
      averageAestheticScore: average,
      bestPhotoIndex: bestIndex,
      feedbackTipKeys: tipKeys,
    );
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