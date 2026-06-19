import 'package:flutter/material.dart';

import '../../../models/composition_overlay_type.dart';
import 'composition_overlay_painter.dart';

class CompositionOverlay extends StatelessWidget {
  const CompositionOverlay({
    super.key,
    required this.type,
    required this.visible,
    this.nativeGrid = false,
  });

  final CompositionOverlayType type;
  final bool visible;
  final bool nativeGrid;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: CompositionOverlayPainter(
            type: type,
            nativeGrid: nativeGrid,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}