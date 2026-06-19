import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/pose_contour_stabilizer.dart';

final poseContourStabilizerProvider = Provider<PoseContourStabilizer>((ref) {
  final stabilizer = PoseContourStabilizer();
  ref.onDispose(stabilizer.reset);
  return stabilizer;
});