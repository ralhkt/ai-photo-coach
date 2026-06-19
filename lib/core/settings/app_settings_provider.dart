import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import 'settings_repository.dart';

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> saveSettings(AppSettings settings) async {
    state = AsyncData(settings);
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  Future<void> completeOnboarding() async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(onboardingCompleted: true));
  }

  Future<void> setVoiceGuidance(bool enabled) async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(voiceGuidanceEnabled: enabled));
  }

  Future<void> setPromptStrength(PromptStrength strength) async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(promptStrength: strength));
  }

  Future<void> setLocaleOption(AppLocaleOption option) async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(localeOption: option));
  }

  Future<void> setPowerSave(bool enabled) async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(powerSaveEnabled: enabled));
  }

  Future<void> setAutoLiveSceneAnalysis(bool enabled) async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(autoLiveSceneAnalysis: enabled));
  }

  Future<void> dismissLiveSceneCoach() async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(liveSceneCoachDismissed: true));
  }

  Future<void> dismissCameraModeCoach() async {
    final current = state.requireValue;
    await saveSettings(current.copyWith(cameraModeCoachDismissed: true));
  }
}

final liveSceneCoachDismissedProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings.liveSceneCoachDismissed,
        orElse: () => false,
      );
});

final powerSaveEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings.powerSaveEnabled,
        orElse: () => false,
      );
});

final promptStrengthProvider = Provider<PromptStrength>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings.promptStrength,
        orElse: () => PromptStrength.medium,
      );
});

final voiceGuidanceEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings.voiceGuidanceEnabled,
        orElse: () => false,
      );
});