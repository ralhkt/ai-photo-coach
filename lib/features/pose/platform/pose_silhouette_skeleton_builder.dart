import 'dart:ui';

import '../../../models/body_part_guides.dart';
/// Builds normalized skeleton polylines for native low-light degradation.
abstract final class PoseSilhouetteSkeletonBuilder {
  static List<List<Offset>> fromBodyGuides(
    BodyPartGuides guides, {
    Rect? subjectRect,
  }) {
    final segments = <List<Offset>>[
      [
        guides.headOval.center,
        guides.shoulders.topCenter,
      ],
      [
        guides.shoulders.topCenter,
        guides.torso.topCenter,
      ],
      [
        guides.torso.topCenter,
        guides.hips.topCenter,
      ],
      [
        guides.shoulders.topLeft,
        guides.shoulders.topRight,
      ],
      [
        guides.hips.bottomLeft,
        guides.hips.bottomRight,
      ],
    ];
    return segments.where((segment) => segment.length >= 2).toList(growable: false);
  }
}