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

  CameraGuidance copyWith({
    PhotoFrameTemplate? frameTemplate,
    CompositionOverlayType? overlayType,
    Rect? subjectTargetRect,
    double? suggestedZoom,
    double? angleDegrees,
    double? exposureEv,
    String? framingHintKey,
    String? exposureHintKey,
    String? distanceHintKey,
    String? angleHintKey,
    SubjectShapeKind? subjectShape,
    List<Offset>? subjectSilhouettePoints,
    BodyPartGuides? bodyPartGuides,
  }) {
    return CameraGuidance(
      frameTemplate: frameTemplate ?? this.frameTemplate,
      overlayType: overlayType ?? this.overlayType,
      subjectTargetRect: subjectTargetRect ?? this.subjectTargetRect,
      suggestedZoom: suggestedZoom ?? this.suggestedZoom,
      angleDegrees: angleDegrees ?? this.angleDegrees,
      exposureEv: exposureEv ?? this.exposureEv,
      framingHintKey: framingHintKey ?? this.framingHintKey,
      exposureHintKey: exposureHintKey ?? this.exposureHintKey,
      distanceHintKey: distanceHintKey ?? this.distanceHintKey,
      angleHintKey: angleHintKey ?? this.angleHintKey,
      subjectShape: subjectShape ?? this.subjectShape,
      subjectSilhouettePoints:
          subjectSilhouettePoints ?? this.subjectSilhouettePoints,
      bodyPartGuides: bodyPartGuides ?? this.bodyPartGuides,
    );
  }
}