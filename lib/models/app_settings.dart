import 'package:flutter/material.dart';

enum PromptStrength { low, medium, high }

enum AppLocaleOption { zhTw, zhCn, en }

class AppSettings {
  const AppSettings({
    this.onboardingCompleted = false,
    this.voiceGuidanceEnabled = false,
    this.promptStrength = PromptStrength.medium,
    this.localeOption = AppLocaleOption.zhTw,
    this.powerSaveEnabled = false,
    this.autoLiveSceneAnalysis = false,
    this.liveSceneCoachDismissed = false,
    this.cameraModeCoachDismissed = false,
  });

  final bool onboardingCompleted;
  final bool voiceGuidanceEnabled;
  final PromptStrength promptStrength;
  final AppLocaleOption localeOption;
  final bool powerSaveEnabled;
  final bool autoLiveSceneAnalysis;
  final bool liveSceneCoachDismissed;
  final bool cameraModeCoachDismissed;

  Locale get locale => switch (localeOption) {
        AppLocaleOption.zhTw => const Locale('zh', 'TW'),
        AppLocaleOption.zhCn => const Locale('zh'),
        AppLocaleOption.en => const Locale('en'),
      };

  AppSettings copyWith({
    bool? onboardingCompleted,
    bool? voiceGuidanceEnabled,
    PromptStrength? promptStrength,
    AppLocaleOption? localeOption,
    bool? powerSaveEnabled,
    bool? autoLiveSceneAnalysis,
    bool? liveSceneCoachDismissed,
    bool? cameraModeCoachDismissed,
  }) {
    return AppSettings(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      promptStrength: promptStrength ?? this.promptStrength,
      localeOption: localeOption ?? this.localeOption,
      powerSaveEnabled: powerSaveEnabled ?? this.powerSaveEnabled,
      autoLiveSceneAnalysis:
          autoLiveSceneAnalysis ?? this.autoLiveSceneAnalysis,
      liveSceneCoachDismissed:
          liveSceneCoachDismissed ?? this.liveSceneCoachDismissed,
      cameraModeCoachDismissed:
          cameraModeCoachDismissed ?? this.cameraModeCoachDismissed,
    );
  }
}