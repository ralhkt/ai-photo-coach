import 'dart:ui';

import '../../../models/body_part_guides.dart';
import '../../frames/presentation/poze_wireframe_style.dart';

/// Builds normalized skeleton polylines for native low-light degradation.
abstract final class PoseSilhouetteSkeletonBuilder {
  static List<List<Offset>> fromBodyGuides(
    BodyPartGuides guides, {
    Rect? subjectRect,
  }) {
    final subject = subjectRect ?? _unionGuides(guides);
    if (subject.isEmpty) {
      return const [];
    }

    final limbs = PozeWireframeLimbs.seatedPhone;
    final segments = <List<Offset>>[
      for (final guide in [
        limbs.leftArm,
        limbs.rightArm,
        limbs.leftLeg,
        limbs.rightLeg,
        limbs.spine,
      ])
        _mapLimb(guide.points, subject),
      [
        guides.headOval.center,
        guides.shoulders.topCenter,
        guides.torso.topCenter,
        guides.hips.topCenter,
      ],
    ];
    return segments.where((segment) => segment.length >= 2).toList(growable: false);
  }

  static List<Offset> _mapLimb(List<Offset> points, Rect subject) {
    return [
      for (final point in points)
        Offset(
          subject.left + point.dx * subject.width,
          subject.top + point.dy * subject.height,
        ),
    ];
  }

  static Rect _unionGuides(BodyPartGuides guides) {
    return Rect.fromLTRB(
      [
        guides.headOval.left,
        guides.shoulders.left,
        guides.torso.left,
        guides.hips.left,
      ].reduce((a, b) => a < b ? a : b),
      [
        guides.headOval.top,
        guides.shoulders.top,
        guides.torso.top,
        guides.hips.top,
      ].reduce((a, b) => a < b ? a : b),
      [
        guides.headOval.right,
        guides.shoulders.right,
        guides.torso.right,
        guides.hips.right,
      ].reduce((a, b) => a > b ? a : b),
      [
        guides.headOval.bottom,
        guides.shoulders.bottom,
        guides.torso.bottom,
        guides.hips.bottom,
      ].reduce((a, b) => a > b ? a : b),
    );
  }
}