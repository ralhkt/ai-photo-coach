import 'package:flutter/material.dart';

/// Simplified exposure reference bar inspired by pro camera apps.
class IosHistogramOverlay extends StatelessWidget {
  const IosHistogramOverlay({
    super.key,
    required this.brightness,
  });

  final double brightness;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 130,
      right: 12,
      child: IgnorePointer(
        child: Container(
          width: 88,
          height: 48,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: CustomPaint(
            painter: _HistogramPainter(brightness: brightness),
          ),
        ),
      ),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  _HistogramPainter({required this.brightness});

  final double brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = Colors.white38;
    final highlightPaint = Paint()..color = const Color(0xFFFFD60A);

    for (var i = 0; i < 12; i++) {
      final x = i * (size.width / 12);
      final normalized = i / 11;
      final height = size.height *
          (0.2 + (1 - (normalized - brightness).abs()) * 0.8).clamp(0.15, 1.0);
      final rect = Rect.fromLTWH(x + 1, size.height - height, 4, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        (normalized - brightness).abs() < 0.12 ? highlightPaint : barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HistogramPainter oldDelegate) {
    return oldDelegate.brightness != brightness;
  }
}