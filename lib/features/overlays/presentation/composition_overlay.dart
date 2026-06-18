import 'package:flutter/material.dart';

import '../../../models/composition_overlay_type.dart';
import 'composition_overlay_painter.dart';

class CompositionOverlay extends StatelessWidget {
  const CompositionOverlay({
    super.key,
    required this.type,
    required this.visible,
  });

  final CompositionOverlayType type;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: CompositionOverlayPainter(type: type),
        child: const SizedBox.expand(),
      ),
    );
  }
}