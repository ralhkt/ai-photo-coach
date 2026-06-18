import 'package:flutter/material.dart';

import '../../../../core/utils/viewport_letterbox.dart';
import '../../../../models/camera_aspect_ratio.dart';

class IosAspectRatioOverlay extends StatelessWidget {
  const IosAspectRatioOverlay({
    super.key,
    required this.aspectRatio,
  });

  final CameraAspectRatio aspectRatio;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final ratio = aspectRatio.displayCropRatio(viewport);
          if (ratio == null) {
            return const SizedBox.shrink();
          }
          final crop = ViewportLetterbox.cropRectForRatio(ratio, viewport);

          return CustomPaint(
            size: viewport,
            painter: _AspectRatioLetterboxPainter(cropRect: crop),
          );
        },
      ),
    );
  }
}

class _AspectRatioLetterboxPainter extends CustomPainter {
  _AspectRatioLetterboxPainter({required this.cropRect});

  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(cropRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AspectRatioLetterboxPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}