import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/app_surface_widgets.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../camera/presentation/guided_camera_screen.dart';
import '../../reference/presentation/reference_upload_screen.dart';
import '../../reference/providers/reference_providers.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openReferenceUpload(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ReferenceUploadScreen(),
      ),
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CameraScreen(),
      ),
    );
  }

  void _openGuidedCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GuidedCameraScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasAnalysis = ref.watch(referenceAnalysisProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDesignTokens.screenPadding,
                AppDesignTokens.spaceMd,
                AppDesignTokens.screenPadding,
                AppDesignTokens.space2xl,
              ),
              children: [
                Text(
                  hasAnalysis
                      ? l10n.homeHeadlineContinue
                      : l10n.homeHeadlineStart,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppDesignTokens.spaceMd),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppDesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space3xl),
                AppFlowStrip(
                  activeIndex: hasAnalysis ? 2 : 0,
                  steps: [
                    l10n.homeFlowStepReference,
                    l10n.homeFlowStepAnalyze,
                    l10n.homeFlowStepShoot,
                  ],
                ),
                const SizedBox(height: AppDesignTokens.space3xl),
                if (hasAnalysis) ...[
                  AppHeroCard(
                    badge: l10n.homeFlowStepShoot,
                    title: l10n.homeContinueGuided,
                    subtitle: l10n.homeContinueGuidedSubtitle,
                    actionLabel: l10n.homeEnterGuidedCamera,
                    onPressed: () => _openGuidedCamera(context),
                  ),
                  const SizedBox(height: AppDesignTokens.space2xl),
                  AppGroupedSection(
                    header: l10n.homeSectionStartNew,
                    children: [
                      AppGroupedRow(
                        icon: Icons.photo_library_outlined,
                        title: l10n.uploadReferenceTitle,
                        subtitle: l10n.uploadReferenceSubtitle,
                        onTap: () => _openReferenceUpload(context),
                      ),
                      AppGroupedRow(
                        icon: Icons.photo_camera_outlined,
                        title: l10n.openCameraSkipTitle,
                        subtitle: l10n.openCameraSkipSubtitle,
                        tertiary: true,
                        onTap: () => _openCamera(context),
                      ),
                    ],
                  ),
                ] else
                  AppGroupedSection(
                    header: l10n.homeSectionGetStarted,
                    children: [
                      AppGroupedRow(
                        icon: Icons.photo_library_outlined,
                        title: l10n.uploadReferenceTitle,
                        subtitle: l10n.uploadReferenceSubtitle,
                        onTap: () => _openReferenceUpload(context),
                      ),
                      AppGroupedRow(
                        icon: Icons.photo_camera_outlined,
                        title: l10n.openCameraTitle,
                        subtitle: l10n.openCameraSubtitle,
                        onTap: () => _openCamera(context),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!hasAnalysis)
            AppStickyCtaBar(
              label: l10n.uploadReferenceTitle,
              icon: Icons.photo_library_outlined,
              onPressed: () => _openReferenceUpload(context),
            ),
        ],
      ),
    );
  }
}