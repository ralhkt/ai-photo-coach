import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const _onboardingKey = 'onboarding_completed';
  static const _voiceKey = 'voice_guidance_enabled';
  static const _promptKey = 'prompt_strength';
  static const _localeKey = 'locale_option';
  static const _powerSaveKey = 'power_save_enabled';
  static const _autoLiveSceneKey = 'auto_live_scene_analysis';
  static const _liveSceneCoachKey = 'live_scene_coach_dismissed';
  static const _cameraModeCoachKey = 'camera_mode_coach_dismissed';
  static const _skeletonStrokeWidthKey = 'skeleton_stroke_width';
  static const _skeletonOnlyPreviewKey = 'skeleton_only_preview';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      onboardingCompleted: prefs.getBool(_onboardingKey) ?? false,
      voiceGuidanceEnabled: prefs.getBool(_voiceKey) ?? false,
      promptStrength: _parsePromptStrength(prefs.getString(_promptKey)),
      localeOption: _parseLocaleOption(prefs.getString(_localeKey)),
      powerSaveEnabled: prefs.getBool(_powerSaveKey) ?? false,
      autoLiveSceneAnalysis: prefs.getBool(_autoLiveSceneKey) ?? false,
      liveSceneCoachDismissed: prefs.getBool(_liveSceneCoachKey) ?? false,
      cameraModeCoachDismissed: prefs.getBool(_cameraModeCoachKey) ?? false,
    );
  }

  Future<double> loadSkeletonStrokeWidth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_skeletonStrokeWidthKey) ?? 2.2;
  }

  Future<void> saveSkeletonStrokeWidth(double width) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_skeletonStrokeWidthKey, width);
  }

  Future<bool> loadSkeletonOnlyPreview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skeletonOnlyPreviewKey) ?? false;
  }

  Future<void> saveSkeletonOnlyPreview(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skeletonOnlyPreviewKey, value);
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, settings.onboardingCompleted);
    await prefs.setBool(_voiceKey, settings.voiceGuidanceEnabled);
    await prefs.setString(_promptKey, settings.promptStrength.name);
    await prefs.setString(_localeKey, settings.localeOption.name);
    await prefs.setBool(_powerSaveKey, settings.powerSaveEnabled);
    await prefs.setBool(_autoLiveSceneKey, settings.autoLiveSceneAnalysis);
    await prefs.setBool(_liveSceneCoachKey, settings.liveSceneCoachDismissed);
    await prefs.setBool(_cameraModeCoachKey, settings.cameraModeCoachDismissed);
  }

  PromptStrength _parsePromptStrength(String? value) {
    return PromptStrength.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PromptStrength.medium,
    );
  }

  AppLocaleOption _parseLocaleOption(String? value) {
    return AppLocaleOption.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppLocaleOption.zhTw,
    );
  }
}