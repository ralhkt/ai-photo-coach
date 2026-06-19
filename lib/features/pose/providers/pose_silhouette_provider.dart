import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/pose_silhouette_platform_service.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../reference/providers/reference_providers.dart';

final poseSilhouetteServiceProvider = Provider<PoseSilhouettePlatformService>(
  (ref) => PoseSilhouettePlatformService(),
);

final poseSilhouetteNativeSupportedProvider = FutureProvider<bool>((ref) async {
  return ref.read(poseSilhouetteServiceProvider).isSupported();
});

/// Pushes guide contour + live alignment score to native Metal overlay.
final poseSilhouetteSyncProvider = Provider<void>((ref) {
  final service = ref.watch(poseSilhouetteServiceProvider);
  final supported = ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull;
  if (supported != true) {
    return;
  }

  final analysis = ref.watch(referenceAnalysisProvider).value;
  final coaching = ref.watch(poseCoachingResultProvider);
  final points = analysis?.guidance.subjectSilhouettePoints;

  if (points != null && points.length >= 4) {
    service.setGuideContour(points);
    service.setEnabled(true);
  } else {
    service.setEnabled(false);
  }

  service.setAlignmentScore(coaching?.poseScore ?? 0);
});