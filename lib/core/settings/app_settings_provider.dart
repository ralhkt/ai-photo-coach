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
}

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