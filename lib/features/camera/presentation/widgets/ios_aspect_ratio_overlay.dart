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
    final ratio = aspectRatio.targetRatio;
    if (ratio == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          final crop = _cropRect(ratio, viewport);
          final paint = Paint()
            ..color = Colors.white.withOpacity(0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          return CustomPaint(
            size: viewport,
            painter: _AspectRatioPainter(cropRect: crop, borderPaint: paint),
          );
        },
      ),
    );
  }

  Rect _cropRect(double targetRatio, Size viewport) {
    final viewRatio = viewport.width / viewport.height;
    if (viewRatio > targetRatio) {
      final width = viewport.height * targetRatio;
      final left = (viewport.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, viewport.height);
    }
    final height = viewport.width / targetRatio;
    final top = (viewport.height - height) / 2;
    return Rect.fromLTWH(0, top, viewport.width, height);
  }
}

class _AspectRatioPainter extends CustomPainter {
  _AspectRatioPainter({required this.cropRect, required this.borderPaint});

  final Rect cropRect;
  final Paint borderPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(cropRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AspectRatioPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}