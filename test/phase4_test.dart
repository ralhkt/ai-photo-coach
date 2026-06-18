import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ai_photo_coach/core/settings/settings_repository.dart';
import 'package:ai_photo_coach/core/utils/prompt_strength.dart';
import 'package:ai_photo_coach/features/session/providers/shoot_session_provider.dart';
import 'package:ai_photo_coach/models/app_settings.dart';
import 'package:ai_photo_coach/models/captured_photo.dart';
import 'package:ai_photo_coach/models/shoot_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromptStrengthFilter', () {
    test('low strength hides secondary and exposure hints', () {
      const filter = PromptStrengthFilter(PromptStrength.low);
      expect(filter.showBodyPartSteps, isFalse);
      expect(filter.showSecondaryHints, isFalse);
      expect(filter.showExposureHints, isFalse);
      expect(filter.bodyPartStepCount, 1);
    });

    test('high strength shows all hint tiers', () {
      const filter = PromptStrengthFilter(PromptStrength.high);
      expect(filter.showBodyPartSteps, isTrue);
      expect(filter.showSecondaryHints, isTrue);
      expect(filter.showExposureHints, isTrue);
      expect(filter.bodyPartStepCount, 4);
    });
  });

  group('SettingsRepository', () {
    test('persists onboarding and locale options', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SettingsRepository();

      await repository.save(
        const AppSettings(
          onboardingCompleted: true,
          voiceGuidanceEnabled: true,
          promptStrength: PromptStrength.high,
          localeOption: AppLocaleOption.en,
        ),
      );

      final loaded = await repository.load();
      expect(loaded.onboardingCompleted, isTrue);
      expect(loaded.voiceGuidanceEnabled, isTrue);
      expect(loaded.promptStrength, PromptStrength.high);
      expect(loaded.localeOption, AppLocaleOption.en);
      expect(loaded.locale, const Locale('en'));
    });

    test('persists auto live scene analysis toggle', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SettingsRepository();

      await repository.save(
        const AppSettings(autoLiveSceneAnalysis: true),
      );

      final loaded = await repository.load();
      expect(loaded.autoLiveSceneAnalysis, isTrue);
    });
  });

  group('ShootSessionNotifier', () {
    test('records captures and ends session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(shootSessionProvider.notifier);
      notifier.startSession(ShootSessionMode.free);
      notifier.recordCapture(
        CapturedPhoto(
          path: 'a.jpg',
          bytes: Uint8List.fromList(_tinyPng),
          capturedAt: DateTime(2026),
        ),
      );

      expect(container.read(shootSessionProvider)?.captures.length, 1);

      final ended = notifier.endSession();
      expect(ended?.captures.length, 1);
      expect(container.read(shootSessionProvider), isNull);
    });
  });
}

final _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];