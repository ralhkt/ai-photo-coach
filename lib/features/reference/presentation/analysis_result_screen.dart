import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/scene_type.dart';
import '../../../models/subject_shape_kind.dart';
import '../../camera/presentation/guided_camera_screen.dart';
import '../providers/reference_providers.dart';

class AnalysisResultScreen extends ConsumerWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      analysis.imageBytes,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (analysis.userSceneType != SceneType.auto)
                    _InfoTile(
                      icon: Icons.category_outlined,
                      title: l10n.userSelectedScene,
                      value: sceneTypeChoiceLabel(l10n, analysis.userSceneType),
                    ),
                  _InfoTile(
                    icon: Icons.auto_awesome_outlined,
                    title: l10n.analysisDetectedSceneLabel,
                    value: sceneTypeLabel(l10n, analysis.sceneTypeKey),
                  ),
                  if (guidance.subjectShape == SubjectShapeKind.humanSilhouette)
                    _InfoTile(
                      icon: Icons.accessibility_new_rounded,
                      title: l10n.subjectShapeTitle,
                      value: l10n.subjectShapeHuman,
                    ),
                  if (ml != null && ml.isMlPowered) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.mlAnalysisTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _InfoTile(
                      icon: Icons.psychology_outlined,
                      title: l10n.mlAnalysisTitle,
                      value: mlAnalysisSourceLabel(l10n, ml.source),
                    ),
                    if (ml.faceCount > 0)
                      _InfoTile(
                        icon: Icons.face_retouching_natural_outlined,
                        title: l10n.mlAnalysisTitle,
                        value: l10n.mlFaceDetected(ml.faceCount),
                      ),
                    if (ml.hasPose)
                      _InfoTile(
                        icon: Icons.accessibility_new_rounded,
                        title: l10n.mlPoseDetected,
                        value: l10n.mlPoseDetected,
                      ),
                    _InfoTile(
                      icon: Icons.speed_outlined,
                      title: l10n.mlInferenceMs(ml.inferenceMs),
                      value: ml.aestheticScore == null
                          ? l10n.mlInferenceMs(ml.inferenceMs)
                          : l10n.mlAestheticScore(
                              ml.aestheticScore!.toStringAsFixed(2),
                            ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    l10n.basicGuidanceTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.crop_portrait_outlined,
                    title: l10n.recommendedFrame,
                    value: frameTemplateLabel(l10n, analysis.recommendedFrame),
                  ),
                  _InfoTile(
                    icon: Icons.grid_on_rounded,
                    title: l10n.recommendedComposition,
                    value: _overlayLabel(l10n, guidance.overlayType),
                  ),
                  _InfoTile(
                    icon: Icons.center_focus_strong_outlined,
                    title: l10n.framingGuidance,
                    value: guidanceHintLabel(l10n, guidance.framingHintKey),
                  ),
                  _InfoTile(
                    icon: Icons.exposure_outlined,
                    title: l10n.exposureGuidance,
                    value: guidanceHintLabel(l10n, guidance.exposureHintKey),
                  ),
                  _InfoTile(
                    icon: Icons.social_distance_outlined,
                    title: l10n.distanceGuidance,
                    value: guidanceHintLabel(l10n, guidance.distanceHintKey),
                  ),
                  _InfoTile(
                    icon: Icons.rotate_right_outlined,
                    title: l10n.angleGuidance,
                    value: guidanceHintLabel(l10n, guidance.angleHintKey),
                  ),
                  if (insights != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.deepAnalysisTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.deepAnalysisSubtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.thermostat_outlined,
                      title: l10n.insightColorTitle,
                      value: insightLabel(l10n, insights.colorTemperatureKey),
                    ),
                    _InfoTile(
                      icon: Icons.wb_sunny_outlined,
                      title: l10n.insightLightingTitle,
                      value: insightLabel(l10n, insights.lightingDirectionKey),
                    ),
                    _InfoTile(
                      icon: Icons.balance_outlined,
                      title: l10n.insightBalanceTitle,
                      value: insightLabel(l10n, insights.compositionBalanceKey),
                    ),
                    _InfoTile(
                      icon: Icons.mood_outlined,
                      title: l10n.insightMoodTitle,
                      value: insightLabel(l10n, insights.moodKey),
                    ),
                    _InfoTile(
                      icon: Icons.blur_on_outlined,
                      title: l10n.insightDepthTitle,
                      value: insightLabel(l10n, insights.depthHintKey),
                    ),
                    _InfoTile(
                      icon: Icons.analytics_outlined,
                      title: l10n.insightConfidenceTitle,
                      value: l10n.insightConfidenceValue(
                        (insights.confidence * 100).round(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.insightDetailedTipsTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...insights.detailedTips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.tips_and_updates_outlined,
                              size: 16,
                              color: Color(0xFFFFD60A),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insightLabel(l10n, tip),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        insights?.analysisSource == 'ml_kit_hybrid'
                            ? l10n.aiAgentNoteMl
                            : l10n.aiAgentNote,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l10n.chooseFrameTemplate,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PhotoFrameTemplate.values.map((template) {
                      final selected = analysis.recommendedFrame == template;
                      return ChoiceChip(
                        label: Text(frameTemplateLabel(l10n, template)),
                        selected: selected,
                        onSelected: (_) {
                          ref
                              .read(referenceAnalysisProvider.notifier)
                              .setFrameTemplate(template);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GuidedCameraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.startGuidedShoot),
              ),
            ),
          ],
        ),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}