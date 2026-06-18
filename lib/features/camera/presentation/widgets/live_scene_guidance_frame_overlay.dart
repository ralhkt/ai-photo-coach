import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../frames/presentation/photo_frame_overlay.dart';
import '../../../reference/providers/reference_providers.dart';
import '../../providers/live_scene_analysis_provider.dart';

/// Human-silhouette guided frame for free-shoot live scene analysis.
class LiveSceneGuidanceFrameOverlay extends ConsumerWidget {
  const LiveSceneGuidanceFrameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(liveSceneAnalysisProvider).value;
    if (analysis == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final guidance = analysis.guidance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSpec = ref.read(frameGeneratorProvider).generate(
              template: guidance.frameTemplate,
              guidance: guidance,
              viewportSize: Size(
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            );

        return PhotoFrameOverlay(
          frameSpec: frameSpec,
          templateLabel: frameTemplateLabel(l10n, guidance.frameTemplate),
          visible: true,
          bodyPartLabels: bodyPartLabels(l10n),
          showBodyParts: guidance.bodyPartGuides != null,
        );
      },
    );
  }
}