import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/human_frame_shape_builder.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('silhouette from body guides stays within anatomical bounds', () {
    const guides = BodyPartGuides(
      headOval: Rect.fromLTWH(0.38, 0.12, 0.24, 0.18),
      shoulders: Rect.fromLTWH(0.30, 0.28, 0.40, 0.12),
      torso: Rect.fromLTWH(0.34, 0.38, 0.32, 0.28),
      hips: Rect.fromLTWH(0.34, 0.64, 0.32, 0.14),
    );

    final builder = HumanFrameShapeBuilder();
    final points = builder.silhouetteFromBodyGuides(guides);
    final path = builder.pointsToSmoothPath(points);

    expect(points.length, greaterThan(18));
    expect(path.getBounds().width, greaterThan(0.2));
    expect(path.getBounds().height, greaterThan(0.45));
    expect(path.getBounds().top, lessThan(guides.headOval.top + 0.05));
  });
}