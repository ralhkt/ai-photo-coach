import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reference/providers/reference_providers.dart';
import '../providers/pose_coaching_provider.dart';
import '../providers/pose_silhouette_provider.dart';
import 'pose_silhouette_skeleton_builder.dart';

/// Async bridge that syncs coaching state to the native overlay without spamming channels.
class PoseSilhouetteBridge extends ConsumerWidget {
  const PoseSilhouetteBridge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supported =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull;
    if (supported != true) {
      return const SizedBox.shrink();
    }

    final analysis = ref.watch(referenceAnalysisProvider).value;
    final coaching = ref.watch(poseCoachingResultProvider);
    final points = analysis?.guidance.subjectSilhouettePoints;
    final guides = analysis?.guidance.bodyPartGuides;
    final score = coaching?.poseScore ?? 0;
    final enabled = points != null && points.length >= 4;
    // Keep human silhouette whenever a reference contour exists.
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(poseSilhouetteSyncControllerProvider).sync(
            service: ref.read(poseSilhouetteServiceProvider),
            supported: true,
            contour: points,
            score: score,
            enabled: enabled,
            renderMode: renderMode,
            skeletonSegments: skeletonSegments,
          );
    });

    return const SizedBox.shrink();
  }
}