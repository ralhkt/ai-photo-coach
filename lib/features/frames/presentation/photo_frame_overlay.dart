import 'package:flutter/material.dart';

import '../../../models/body_part_labels.dart';
import '../../reference/services/frame_generator_service.dart' show GeneratedFrameSpec;
import 'photo_frame_painter.dart';

class PhotoFrameOverlay extends StatelessWidget {
  const PhotoFrameOverlay({
    super.key,
    required this.frameSpec,
    required this.templateLabel,
    required this.visible,
    this.bodyPartLabels,
    this.showBodyParts = true,
  });

  final GeneratedFrameSpec frameSpec;
  final String templateLabel;
  final bool visible;
  final BodyPartLabels? bodyPartLabels;
  final bool showBodyParts;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: PhotoFramePainter(
          frameSpec: frameSpec,
          templateLabel: templateLabel,
          bodyPartLabels: bodyPartLabels,
          showBodyParts: showBodyParts,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}