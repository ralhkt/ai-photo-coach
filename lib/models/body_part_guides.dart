import 'dart:ui';

/// Normalized (0–1 image space) body-part zones for guided portrait shooting.
class BodyPartGuides {
  const BodyPartGuides({
    required this.headOval,
    required this.shoulders,
    required this.torso,
    required this.hips,
  });

  final Rect headOval;
  final Rect shoulders;
  final Rect torso;
  final Rect hips;
}