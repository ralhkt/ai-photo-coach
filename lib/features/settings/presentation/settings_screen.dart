import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../../models/app_settings.dart';
import '../../diagnostics/presentation/performance_diagnostics_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: l10n.settingsLanguageSection),
              _LocaleTile(
                selected: settings.localeOption,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setLocaleOption(value);
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: l10n.settingsGuidanceSection),
              SwitchListTile(
                title: Text(l10n.settingsVoiceGuidance),
                subtitle: Text(l10n.settingsVoiceGuidanceSubtitle),
                value: settings.voiceGuidanceEnabled,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setVoiceGuidance(value);
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsPromptStrength,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<PromptStrength>(
                segments: [
                  ButtonSegment(
                    value: PromptStrength.low,
                    label: Text(l10n.promptStrengthLow),
                  ),
                  ButtonSegment(
                    value: PromptStrength.medium,
                    label: Text(l10n.promptStrengthMedium),
                  ),
                  ButtonSegment(
                    value: PromptStrength.high,
                    label: Text(l10n.promptStrengthHigh),
                  ),
                ],
                selected: {settings.promptStrength},
                onSelectionChanged: (selection) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setPromptStrength(selection.first);
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settingsPromptStrengthHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
              SwitchListTile(
                title: Text(l10n.settingsAutoLiveSceneAnalysis),
                subtitle: Text(l10n.settingsAutoLiveSceneAnalysisSubtitle),
                value: settings.autoLiveSceneAnalysis,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setAutoLiveSceneAnalysis(value);
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: l10n.settingsPerformanceSection),
              SwitchListTile(
                title: Text(l10n.settingsPowerSave),
                subtitle: Text(l10n.settingsPowerSaveSubtitle),
                value: settings.powerSaveEnabled,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setPowerSave(value);
                },
              ),
              ListTile(
                title: Text(l10n.diagnosticsTitle),
                subtitle: Text(l10n.diagnosticsEntrySubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PerformanceDiagnosticsScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.selected,
    required this.onChanged,
  });

  final AppLocaleOption selected;
  final ValueChanged<AppLocaleOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        RadioListTile<AppLocaleOption>(
          title: Text(l10n.localeZhTw),
          value: AppLocaleOption.zhTw,
          groupValue: selected,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
        RadioListTile<AppLocaleOption>(
          title: Text(l10n.localeZhCn),
          value: AppLocaleOption.zhCn,
          groupValue: selected,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
        RadioListTile<AppLocaleOption>(
          title: Text(l10n.localeEn),
          value: AppLocaleOption.en,
          groupValue: selected,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}