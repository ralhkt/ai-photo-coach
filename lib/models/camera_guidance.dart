import 'dart:ui';

import 'body_part_guides.dart';
import 'composition_overlay_type.dart';
import 'photo_frame_template.dart';
import 'subject_shape_kind.dart';

class CameraGuidance {
  const CameraGuidance({
    required this.frameTemplate,
    required this.overlayType,
    required this.subjectTargetRect,
    required this.suggestedZoom,
    required this.angleDegrees,
    required this.exposureEv,
    required this.framingHintKey,
    required this.exposureHintKey,
    required this.distanceHintKey,
    required this.angleHintKey,
    this.subjectShape = SubjectShapeKind.rectangle,
    this.subjectSilhouettePoints,
    this.bodyPartGuides,
  });

  final PhotoFrameTemplate frameTemplate;
  final CompositionOverlayType overlayType;
  final Rect subjectTargetRect;
  final double suggestedZoom;
  final double angleDegrees;
  final double exposureEv;
  final String framingHintKey;
  final String exposureHintKey;
  final String distanceHintKey;
  final String angleHintKey;
  final SubjectShapeKind subjectShape;
  final List<Offset>? subjectSilhouettePoints;
  final BodyPartGuides? bodyPartGuides;
}