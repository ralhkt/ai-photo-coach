import 'package:flutter/material.dart';

import 'ios_camera_ui_kit.dart';

/// Native Camera 3×3 rule-of-thirds grid — thin white lines on live preview.
class IosCameraGridOverlay extends StatelessWidget {
  const IosCameraGridOverlay({super.key, this.visible = true});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return const IgnorePointer(
      child: CustomPaint(
        painter: _NativeGridPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _NativeGridPainter extends CustomPainter {
  const _NativeGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IosCameraUiKit.gridLine
      ..strokeWidth = 0.85
      ..style = PaintingStyle.stroke;

    final thirdW = size.width / 3;
    final thirdH = size.height / 3;

    for (var i = 1; i <= 2; i++) {
      final x = thirdW * i;
      final y = thirdH * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NativeGridPainter oldDelegate) => false;
}