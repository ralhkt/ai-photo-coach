import 'dart:ui';

import 'package:ai_photo_coach/features/pose/platform/pose_silhouette_skeleton_builder.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds skeleton segments from body guides', () {
    const guides = BodyPartGuides(
      headOval: Rect.fromLTWH(0.42, 0.12, 0.16, 0.14),
      shoulders: Rect.fromLTWH(0.36, 0.28, 0.28, 0.08),
      torso: Rect.fromLTWH(0.38, 0.36, 0.24, 0.22),
      hips: Rect.fromLTWH(0.37, 0.58, 0.26, 0.12),
    );

    final segments = PoseSilhouetteSkeletonBuilder.fromBodyGuides(guides);

    expect(segments, isNotEmpty);
    expect(segments.every((segment) => segment.length >= 2), isTrue);
  });
}