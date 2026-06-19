import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/widgets/app_surface_widgets.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/scene_type.dart';
import '../../../models/subject_shape_kind.dart';
import '../../camera/presentation/guided_camera_screen.dart';
import '../providers/reference_providers.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis = ref.watch(referenceAnalysisProvider).value;
    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.analysisResultTitle)),
        body: Center(child: Text(l10n.analysisFailed)),
      );
    }

    final guidance = analysis.guidance;
    final insights = analysis.deepInsights;
    final ml = analysis.mlDetection;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analysisResultTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignTokens.screenPadding),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                  child: Image.memory(
                    analysis.imageBytes,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppDesignTokens.spaceXl),
                AppFlowStrip(
                  activeIndex: 1,
                  steps: [
                    l10n.homeFlowStepReference,
                    l10n.homeFlowStepAnalyze,
                    l10n.homeFlowStepShoot,
                  ],
                ),
                const SizedBox(height: AppDesignTokens.spaceXl),
                AppSummaryCard(
                  leading: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.coach,
                    size: 28,
                  ),
                  title: l10n.basicGuidanceTitle,
                  subtitle: guidanceHintLabel(l10n, guidance.framingHintKey),
                  chips: [
                    sceneTypeLabel(l10n, analysis.sceneTypeKey),
                    frameTemplateLabel(l10n, analysis.recommendedFrame),
                    _overlayLabel(l10n, guidance.overlayType),
                  ],
                ),
                const SizedBox(height: AppDesignTokens.spaceXl),
                AppGroupedSection(
                  header: l10n.basicGuidanceTitle,
                  children: [
                    AppGroupedRow(
                      icon: Icons.center_focus_strong_outlined,
                      title: l10n.framingGuidance,
                      subtitle: guidanceHintLabel(l10n, guidance.framingHintKey),
                      showChevron: false,
                    ),
                    AppGroupedRow(
                      icon: Icons.social_distance_outlined,
                      title: l10n.distanceGuidance,
                      subtitle: guidanceHintLabel(l10n, guidance.distanceHintKey),
                      showChevron: false,
                    ),
                    if (guidance.subjectShape == SubjectShapeKind.humanSilhouette)
                      AppGroupedRow(
                        icon: Icons.accessibility_new_rounded,
                        title: l10n.subjectShapeTitle,
                        subtitle: l10n.subjectShapeHuman,
                        showChevron: false,
                      ),
                  ],
                ),
                const SizedBox(height: AppDesignTokens.spaceLg),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
                  label: Text(
                    _showDetails
                        ? l10n.analysisCollapseDetails
                        : l10n.analysisExpandDetails,
                  ),
                ),
                if (_showDetails) ...[
                  const SizedBox(height: AppDesignTokens.spaceLg),
                  AppGroupedSection(
                    header: l10n.deepAnalysisTitle,
                    children: [
                      if (analysis.userSceneType != SceneType.auto)
                        AppGroupedRow(
                          icon: Icons.category_outlined,
                          title: l10n.userSelectedScene,
                          subtitle:
                              sceneTypeChoiceLabel(l10n, analysis.userSceneType),
                          showChevron: false,
                        ),
                      AppGroupedRow(
                        icon: Icons.exposure_outlined,
                        title: l10n.exposureGuidance,
                        subtitle:
                            guidanceHintLabel(l10n, guidance.exposureHintKey),
                        showChevron: false,
                      ),
                      AppGroupedRow(
                        icon: Icons.rotate_right_outlined,
                        title: l10n.angleGuidance,
                        subtitle:
                            guidanceHintLabel(l10n, guidance.angleHintKey),
                        showChevron: false,
                      ),
                      if (ml != null && ml.isMlPowered) ...[
                        AppGroupedRow(
                          icon: Icons.psychology_outlined,
                          title: l10n.mlSourceLabel,
                          subtitle: mlAnalysisSourceLabel(l10n, ml.source),
                          showChevron: false,
                        ),
                        if (ml.faceCount > 0)
                          AppGroupedRow(
                            icon: Icons.face_retouching_natural_outlined,
                            title: l10n.mlFaceCountLabel,
                            subtitle: l10n.mlFaceDetected(ml.faceCount),
                            showChevron: false,
                          ),
                      ],
                      if (insights != null) ...[
                        AppGroupedRow(
                          icon: Icons.thermostat_outlined,
                          title: l10n.insightColorTitle,
                          subtitle:
                              insightLabel(l10n, insights.colorTemperatureKey),
                          showChevron: false,
                        ),
                        AppGroupedRow(
                          icon: Icons.wb_sunny_outlined,
                          title: l10n.insightLightingTitle,
                          subtitle:
                              insightLabel(l10n, insights.lightingDirectionKey),
                          showChevron: false,
                        ),
                      ],
                    ],
                  ),
                  if (insights != null && insights.detailedTips.isNotEmpty) ...[
                    const SizedBox(height: AppDesignTokens.spaceLg),
                    ...insights.detailedTips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDesignTokens.spaceSm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.tips_and_updates_outlined,
                              size: 16,
                              color: AppTheme.coach,
                            ),
                            const SizedBox(width: AppDesignTokens.spaceSm),
                            Expanded(
                              child: Text(
                                insightLabel(l10n, tip),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDesignTokens.spaceLg),
                  AppSectionHeader(title: l10n.chooseFrameTemplate),
                  const SizedBox(height: AppDesignTokens.spaceSm),
                  AppSegmentedPicker<PhotoFrameTemplate>(
                    items: PhotoFrameTemplate.values,
                    selected: analysis.recommendedFrame,
                    labelBuilder: (t) => frameTemplateLabel(l10n, t),
                    onSelected: (template) {
                      ref
                          .read(referenceAnalysisProvider.notifier)
                          .setFrameTemplate(template);
                    },
                  ),
                ],
              ],
            ),
          ),
          AppStickyCtaBar(
            label: l10n.startGuidedShoot,
            icon: Icons.camera_alt_outlined,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GuidedCameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _overlayLabel(AppLocalizations l10n, CompositionOverlayType type) {
    return switch (type) {
      CompositionOverlayType.ruleOfThirds => l10n.overlayRuleOfThirds,
      CompositionOverlayType.goldenRatio => l10n.overlayGoldenRatio,
      CompositionOverlayType.center => l10n.overlayCenter,
      CompositionOverlayType.diagonal => l10n.overlayDiagonal,
    };
  }
}