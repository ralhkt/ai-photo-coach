import 'package:flutter/material.dart';

import 'pose_aesthetic_analyzer.dart';

/// Poze-style overlay color state driven by alignment score.
enum AlignmentOverlayPhase {
  noMatch,
  aligning,
  matched,
}

abstract final class AlignmentOverlayState {
  static AlignmentOverlayPhase phaseForScore(int score) {
    if (score >= PoseAestheticAnalyzer.posePassScore) {
      return AlignmentOverlayPhase.matched;
    }
    if (score >= 50) {
      return AlignmentOverlayPhase.aligning;
    }
    return AlignmentOverlayPhase.noMatch;
  }

  static Color strokeColorForPhase(AlignmentOverlayPhase phase) {
    return switch (phase) {
      AlignmentOverlayPhase.noMatch => const Color(0xCCFFFFFF),
      AlignmentOverlayPhase.aligning => const Color(0xCCFFD60A),
      AlignmentOverlayPhase.matched => const Color(0xCC30D158),
    };
  }

  static Color glowColorForPhase(AlignmentOverlayPhase phase) {
    return switch (phase) {
      AlignmentOverlayPhase.noMatch => const Color(0x1AFFFFFF),
      AlignmentOverlayPhase.aligning => const Color(0x26FFD60A),
      AlignmentOverlayPhase.matched => const Color(0x3330D158),
    };
  }

  static String toastForPhase(AlignmentOverlayPhase phase) {
    return switch (phase) {
      AlignmentOverlayPhase.noMatch => '請站入輪廓中央',
      AlignmentOverlayPhase.aligning => '肢體對齊中…請將身體套入輪廓',
      AlignmentOverlayPhase.matched => '完美對齊！可以拍了',
    };
  }
}