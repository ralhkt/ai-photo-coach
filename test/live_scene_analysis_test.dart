import 'dart:typed_data';

import 'package:ai_photo_coach/core/l10n/generated/app_localizations.dart';
import 'package:ai_photo_coach/core/utils/prompt_strength.dart';
import 'package:ai_photo_coach/features/camera/presentation/widgets/live_scene_advice_panel.dart';
import 'package:ai_photo_coach/features/camera/providers/live_scene_analysis_provider.dart';
import 'package:ai_photo_coach/models/app_settings.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/ml_detection_result.dart';
import 'package:ai_photo_coach/models/photo_analysis_result.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_photo_coach/core/settings/app_settings_provider.dart';

void main() {
  testWidgets('live scene advice panel shows framing hint', (tester) async {
    final analysis = PhotoAnalysisResult(
      sourceAspectRatio: 0.75,
      brightness: 0.5,
      subjectFillRatio: 0.3,
      recommendedFrame: PhotoFrameTemplate.portraitPost,
      guidance: const CameraGuidance(
        frameTemplate: PhotoFrameTemplate.portraitPost,
        overlayType: CompositionOverlayType.ruleOfThirds,
        subjectTargetRect: Rect.fromLTWH(0.2, 0.2, 0.6, 0.6),
        suggestedZoom: 1,
        angleDegrees: 0,
        exposureEv: 0,
        framingHintKey: 'hintFramingCenter',
        exposureHintKey: 'hintExposureBalanced',
        distanceHintKey: 'hintDistanceGood',
        angleHintKey: 'hintAngleLevel',
        subjectShape: SubjectShapeKind.rectangle,
      ),
      sceneTypeKey: 'scenePortrait',
      imageBytes: Uint8List(0),
      mlDetection: const MlDetectionResult(
        source: 'heuristic_fallback',
        inferenceMs: 12,
        aestheticScore: 0.72,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(() => _TestSettingsNotifier()),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'TW'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: LiveSceneAdvicePanel(
              analysis: analysis,
              onDismiss: () {},
              onReanalyze: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 拍攝建議'), findsOneWidget);
    expect(find.textContaining('構圖'), findsWidgets);
  });

  test('live scene failure enum covers busy and capture cases', () {
    expect(
      LiveSceneAnalysisException(LiveSceneAnalysisFailure.cameraBusy).reason,
      LiveSceneAnalysisFailure.cameraBusy,
    );
    expect(
      LiveSceneAnalysisException(LiveSceneAnalysisFailure.captureFailed).reason,
      LiveSceneAnalysisFailure.captureFailed,
    );
  });

  test('prompt filter controls live advice detail tiers', () {
    const low = PromptStrengthFilter(PromptStrength.low);
    const high = PromptStrengthFilter(PromptStrength.high);
    expect(low.showSecondaryHints, isFalse);
    expect(high.showExposureHints, isTrue);
  });
}

class _TestSettingsNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async {
    return const AppSettings(onboardingCompleted: true);
  }
}