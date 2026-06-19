import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/providers/camera_interaction_provider.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/pose_coaching_provider.dart';
import '../providers/pose_silhouette_provider.dart';
import 'pose_silhouette_skeleton_builder.dart';

/// Syncs coaching state to the native overlay only when inputs change.
class PoseSilhouetteBridge extends ConsumerStatefulWidget {
  const PoseSilhouetteBridge({super.key});

  @override
  ConsumerState<PoseSilhouetteBridge> createState() =>
      _PoseSilhouetteBridgeState();
}

class _PoseSilhouetteBridgeState extends ConsumerState<PoseSilhouetteBridge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    if (ref.read(isCameraUiInteractionPausedProvider)) {
      return;
    }

    final supported =
        ref.read(poseSilhouetteNativeSupportedProvider).valueOrNull;
    if (supported != true) {
      return;
    }

    final analysis = ref.read(referenceAnalysisProvider).value;
    final coaching = ref.read(poseCoachingResultProvider);
    final points = analysis?.guidance.subjectSilhouettePoints;
    final guides = analysis?.guidance.bodyPartGuides;
    final score = coaching?.poseScore ?? 0;
    final enabled = points != null && points.length >= 4;
    final renderMode = enabled ? 'silhouette' : 'skeleton';
    final referenceSkeleton = analysis?.guidance.subjectPoseSkeleton;
    final skeletonSegments = referenceSkeleton != null &&
            referenceSkeleton.isNotEmpty
        ? referenceSkeleton
        : guides == null
            ? const <List<Offset>>[]
            : PoseSilhouetteSkeletonBuilder.fromBodyGuides(
                guides,
                subjectRect: analysis?.guidance.subjectTargetRect,
              );

    unawaited(
      ref.read(poseSilhouetteSyncControllerProvider).sync(
            service: ref.read(poseSilhouetteServiceProvider),
            supported: true,
            contour: points,
            score: score,
            enabled: enabled,
            renderMode: renderMode,
            skeletonSegments: skeletonSegments,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(poseCoachingResultProvider, (_, __) => _sync());
    ref.listen(referenceAnalysisProvider, (_, __) => _sync());
    ref.listen(poseSilhouetteNativeSupportedProvider, (previous, next) {
      if (previous?.valueOrNull != true && next.valueOrNull == true) {
        _sync();
      }
    });

    return const SizedBox.shrink();
  }
}