import 'package:ai_photo_coach/features/pose/services/alignment_overlay_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phase thresholds follow 50 / 85 boundaries', () {
    expect(
      AlignmentOverlayState.phaseForScore(30),
      AlignmentOverlayPhase.noMatch,
    );
    expect(
      AlignmentOverlayState.phaseForScore(60),
      AlignmentOverlayPhase.aligning,
    );
    expect(
      AlignmentOverlayState.phaseForScore(90),
      AlignmentOverlayPhase.matched,
    );
  });

  test('stroke colors differ per phase', () {
    final white = AlignmentOverlayState.strokeColorForPhase(
      AlignmentOverlayPhase.noMatch,
    );
    final yellow = AlignmentOverlayState.strokeColorForPhase(
      AlignmentOverlayPhase.aligning,
    );
    final green = AlignmentOverlayState.strokeColorForPhase(
      AlignmentOverlayPhase.matched,
    );
    expect(white, isNot(equals(yellow)));
    expect(yellow, isNot(equals(green)));
  });
}