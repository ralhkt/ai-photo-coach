import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../../core/utils/prompt_strength.dart';
import '../../../../core/widgets/app_glass_widgets.dart';
import '../../../../models/composition_overlay_type.dart';
import '../../../../models/photo_analysis_result.dart';

class LiveSceneAdvicePanel extends ConsumerWidget {
  const LiveSceneAdvicePanel({
    super.key,
    required this.analysis,
    required this.onDismiss,
    required this.onReanalyze,
    this.isAnalyzing = false,
  });

  final PhotoAnalysisResult analysis;
  final VoidCallback onDismiss;
  final VoidCallback? onReanalyze;
  final bool isAnalyzing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final guidance = analysis.guidance;
    final ml = analysis.mlDetection;
    final promptFilter =
        PromptStrengthFilter(ref.watch(promptStrengthProvider));

    return AnimatedSlide(
      offset: Offset.zero,
      duration: AppDesignTokens.motionSheet,
      curve: AppDesignTokens.motionEaseOut,
      child: AppSheetPanel(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDesignTokens.spaceLg,
            AppDesignTokens.spaceSm,
            AppDesignTokens.spaceLg,
            AppDesignTokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.coach,
                    size: 18,
                  ),
                  const SizedBox(width: AppDesignTokens.spaceSm),
                  Expanded(
                    child: Text(
                      l10n.liveSceneAdviceTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppDesignTokens.textTertiary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignTokens.spaceSm),
              Text(
                analysis.matchedReferenceTitleKey != null
                    ? l10n.liveSceneMatchedReference(
                        referenceSampleTitle(
                          l10n,
                          analysis.matchedReferenceTitleKey!,
                        ),
                      )
                    : sceneTypeLabel(l10n, analysis.sceneTypeKey),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.coach,
                ),
              ),
              const SizedBox(height: AppDesignTokens.spaceMd),
              _AdviceLine(
                icon: Icons.center_focus_strong_outlined,
                text: guidanceHintLabel(l10n, guidance.framingHintKey),
              ),
              if (promptFilter.showSecondaryHints)
                _AdviceLine(
                  icon: Icons.social_distance_outlined,
                  text: guidanceHintLabel(l10n, guidance.distanceHintKey),
                ),
              if (promptFilter.showExposureHints)
                _AdviceLine(
                  icon: Icons.wb_sunny_outlined,
                  text: guidanceHintLabel(l10n, guidance.exposureHintKey),
                ),
              if (promptFilter.showSecondaryHints)
                _AdviceLine(
                  icon: Icons.swap_vert_rounded,
                  text: guidanceHintLabel(l10n, guidance.angleHintKey),
                ),
              _AdviceLine(
                icon: Icons.grid_on_rounded,
                text: l10n.liveSceneOverlayApplied(
                  _overlayLabel(l10n, guidance.overlayType),
                ),
              ),
              if (ml != null && ml.isMlPowered) ...[
                const SizedBox(height: AppDesignTokens.spaceXs),
                Text(
                  ml.aestheticScore == null
                      ? mlAnalysisSourceLabel(l10n, ml.source)
                      : l10n.liveSceneMlSummary(
                          mlAnalysisSourceLabel(l10n, ml.source),
                          ml.aestheticScore!.toStringAsFixed(2),
                        ),
                  style: theme.textTheme.labelSmall,
                ),
              ],
              const SizedBox(height: AppDesignTokens.spaceSm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isAnalyzing ? null : onReanalyze,
                  child: Text(
                    isAnalyzing
                        ? l10n.liveSceneAnalyzing
                        : l10n.liveSceneReanalyze,
                  ),
                ),
              ),
            ],
          ),
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

class _AdviceLine extends StatelessWidget {
  const _AdviceLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignTokens.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppDesignTokens.textTertiary),
          const SizedBox(width: AppDesignTokens.spaceSm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppDesignTokens.textPrimary,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}