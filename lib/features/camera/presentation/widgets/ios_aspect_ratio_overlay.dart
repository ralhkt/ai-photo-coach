import 'package:flutter/material.dart';

import '../../../../models/camera_aspect_ratio.dart';

class IosAspectRatioOverlay extends StatelessWidget {
  const IosAspectRatioOverlay({
    super.key,
    required this.aspectRatio,
  });

  final CameraAspectRatio aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (aspectRatio == CameraAspectRatio.full) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _AspectRatioBorderPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AspectRatioBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AspectRatioBorderPainter oldDelegate) => false;
}