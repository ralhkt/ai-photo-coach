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
                AppDesignTokens.spaceSm,
                AppDesignTokens.screenPadding,
                AppDesignTokens.space2xl,
              ),
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: AppDesignTokens.spaceSm),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyLarge,
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
                if (hasAnalysis)
                  AppHeroCard(
                    badge: l10n.homeFlowStepShoot,
                    title: l10n.homeContinueGuided,
                    subtitle: l10n.homeContinueGuidedSubtitle,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GuidedCameraScreen(),
                        ),
                      );
                    },
                  ),
                if (hasAnalysis)
                  const SizedBox(height: AppDesignTokens.spaceLg),
                AppGroupedSection(
                  header: l10n.homeSubtitle,
                  children: [
                    AppGroupedRow(
                      icon: Icons.photo_library_outlined,
                      title: l10n.uploadReferenceTitle,
                      subtitle: l10n.uploadReferenceSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReferenceUploadScreen(),
                          ),
                        );
                      },
                    ),
                    AppGroupedRow(
                      icon: Icons.photo_camera_outlined,
                      title: l10n.openCameraTitle,
                      subtitle: l10n.openCameraSubtitle,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CameraScreen(),
                          ),
                        );
                      },
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReferenceUploadScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}