import 'dart:math' as math;
import 'dart:ui';

import '../../../models/body_part_guides.dart';

/// Derives head / shoulder / torso / hip guides from subject region and silhouette.
class BodyPartGuideService {
  BodyPartGuides derive({
    required Rect subjectRect,
    List<Offset>? silhouettePoints,
  }) {
    if (silhouettePoints != null && silhouettePoints.length >= 8) {
      return _deriveFromSilhouette(subjectRect, silhouettePoints);
    }
    return _deriveFromSubjectRect(subjectRect);
  }

  BodyPartGuides _deriveFromSubjectRect(Rect subject) {
    final headHeight = subject.height * 0.24;
    final headWidth = subject.width * 0.52;

    return BodyPartGuides(
      headOval: Rect.fromCenter(
        center: Offset(
          subject.center.dx,
          subject.top + headHeight * 0.52,
        ),
        width: headWidth,
        height: headHeight,
      ),
      shoulders: Rect.fromLTWH(
        subject.left + subject.width * 0.06,
        subject.top + subject.height * 0.20,
        subject.width * 0.88,
        subject.height * 0.14,
      ),
      torso: Rect.fromLTWH(
        subject.left + subject.width * 0.14,
        subject.top + subject.height * 0.34,
        subject.width * 0.72,
        subject.height * 0.36,
      ),
      hips: Rect.fromLTWH(
        subject.left + subject.width * 0.18,
        subject.top + subject.height * 0.66,
        subject.width * 0.64,
        subject.height * 0.22,
      ),
    );
  }

  BodyPartGuides _deriveFromSilhouette(Rect subject, List<Offset> points) {
    final sorted = [...points]..sort((a, b) => a.dy.compareTo(b.dy));
    final topY = sorted.first.dy;
    final bottomY = sorted.last.dy;
    final bodyHeight = (bottomY - topY).clamp(0.15, 1.0);

    final headBottomY = topY + bodyHeight * 0.24;
    final headPoints =
        points.where((p) => p.dy <= headBottomY).toList(growable: false);

    double headLeft = subject.left;
    double headRight = subject.right;
    if (headPoints.isNotEmpty) {
      headLeft = headPoints.map((p) => p.dx).reduce(math.min);
      headRight = headPoints.map((p) => p.dx).reduce(math.max);
    }

    final headWidth =
        (headRight - headLeft).clamp(subject.width * 0.34, subject.width * 0.62);
    final headCenterX = (headLeft + headRight) / 2;
    final headHeight = bodyHeight * 0.30;
    final chinY = topY + headHeight * 0.95;
    final foreheadY = topY + headHeight * 0.08;

    final shoulderY = topY + bodyHeight * 0.28;
    final shoulderPoints = points
        .where((p) => p.dy >= shoulderY - bodyHeight * 0.04 && p.dy <= shoulderY + bodyHeight * 0.08)
        .toList();
    var shoulderLeft = subject.left + subject.width * 0.05;
    var shoulderRight = subject.right - subject.width * 0.05;
    if (shoulderPoints.isNotEmpty) {
      shoulderLeft = shoulderPoints.map((p) => p.dx).reduce(math.min);
      shoulderRight = shoulderPoints.map((p) => p.dx).reduce(math.max);
    }

    final torsoTop = topY + bodyHeight * 0.32;
    final torsoBottom = topY + bodyHeight * 0.68;
    final torsoPoints = points
        .where((p) => p.dy >= torsoTop && p.dy <= torsoBottom)
        .toList();
    var torsoLeft = subject.left + subject.width * 0.12;
    var torsoRight = subject.right - subject.width * 0.12;
    if (torsoPoints.isNotEmpty) {
      torsoLeft = torsoPoints.map((p) => p.dx).reduce(math.min);
      torsoRight = torsoPoints.map((p) => p.dx).reduce(math.max);
    }

    final hipTop = topY + bodyHeight * 0.66;
    final hipBottom = topY + bodyHeight * 0.88;
    final hipPoints =
        points.where((p) => p.dy >= hipTop && p.dy <= hipBottom).toList();
    var hipLeft = subject.left + subject.width * 0.16;
    var hipRight = subject.right - subject.width * 0.16;
    if (hipPoints.isNotEmpty) {
      hipLeft = hipPoints.map((p) => p.dx).reduce(math.min);
      hipRight = hipPoints.map((p) => p.dx).reduce(math.max);
    }

    return BodyPartGuides(
      headOval: Rect.fromLTRB(
        headCenterX - headWidth / 2,
        foreheadY,
        headCenterX + headWidth / 2,
        chinY,
      ),
      shoulders: Rect.fromLTRB(
        shoulderLeft,
        shoulderY - bodyHeight * 0.05,
        shoulderRight,
        shoulderY + bodyHeight * 0.09,
      ),
      torso: Rect.fromLTRB(
        torsoLeft,
        torsoTop,
        torsoRight,
        torsoBottom,
      ),
      hips: Rect.fromLTRB(
        hipLeft,
        hipTop,
        hipRight,
        hipBottom,
      ),
    );
  }
}