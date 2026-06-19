import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/coaching_guidance_helper.dart';
import '../../../../core/utils/pose_coaching_hint.dart';
import '../../../pose/providers/pose_coaching_provider.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../../frames/presentation/photo_frame_overlay.dart';
import '../../../frames/presentation/poze_wireframe_style.dart';
import '../../../frames/presentation/reference_ghost_overlay.dart';
import '../../../reference/providers/reference_providers.dart';
import '../../providers/live_scene_analysis_provider.dart';
import '../../providers/pose_contour_stabilizer_provider.dart';

/// Poze-style centered wireframe + matched influencer ghost for free-shoot AI.
class LiveSceneGuidanceFrameOverlay extends ConsumerWidget {
  const LiveSceneGuidanceFrameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(liveSceneAnalysisProvider).value;
    if (analysis == null) {
      return const SizedBox.shrink();
    }

    final stabilizer = ref.read(poseContourStabilizerProvider);
    final guidance = CoachingGuidanceHelper().forPozeOverlay(
      CoachingGuidanceHelper().ensureHumanSilhouette(analysis.guidance),
      stabilizer: stabilizer,
    );
    final ghostBytes = analysis.matchedReferenceImageBytes;
    final stability = ref.watch(sceneStabilityProvider);
    final coaching = ref.watch(poseCoachingResultProvider);
    final poseAligned = isPoseCoachingAligned(
      stability: stability,
      coaching: coaching,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final frameSpec = ref.read(frameGeneratorProvider).generate(
              template: guidance.frameTemplate,
              guidance: guidance,
              viewportSize: viewport,
              viewportIsCropArea: true,
            );

        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ghostBytes != null)
                ReferenceGhostOverlay(
                  imageBytes: ghostBytes,
                  frameSpec: frameSpec,
                  visible: true,
                  opacity: PozeWireframeStyle.ghostOpacity,
                ),
              PhotoFrameOverlay(
                frameSpec: frameSpec,
                templateLabel: '',
                visible: true,
                showBodyParts: false,
                minimalPozeStyle: true,
                poseAligned: poseAligned,
                alignmentScore: coaching?.poseScore,
              ),
            ],
          ),
        );
      },
    );
  }
}