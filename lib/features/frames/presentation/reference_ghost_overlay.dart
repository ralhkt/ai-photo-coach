import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/utils/viewport_letterbox.dart';
import '../../reference/services/frame_generator_service.dart';

/// Faint reference image inside the crop area to help match pose.
class ReferenceGhostOverlay extends StatefulWidget {
  const ReferenceGhostOverlay({
    super.key,
    required this.imageBytes,
    required this.frameSpec,
    required this.visible,
    this.opacity = 0.22,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final bool visible;
  final double opacity;

  @override
  State<ReferenceGhostOverlay> createState() => _ReferenceGhostOverlayState();
}

class _ReferenceGhostOverlayState extends State<ReferenceGhostOverlay> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant ReferenceGhostOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBytes != widget.imageBytes) {
      _decode();
    }
  }

  Future<void> _decode() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() => _image = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || _image == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _ReferenceGhostPainter(
          image: _image!,
          cropRect: widget.frameSpec.cropRect,
          opacity: widget.opacity,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReferenceGhostPainter extends CustomPainter {
  _ReferenceGhostPainter({
    required this.image,
    required this.cropRect,
    required this.opacity,
  });

  final ui.Image image;
  final Rect cropRect;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final imageAspect = image.width / image.height;
    final dest = ViewportLetterbox.coverFitDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );
    final paint = Paint()..color = Colors.white.withOpacity(opacity);

    canvas.save();
    canvas.clipRect(cropRect);
    canvas.drawImageRect(image, src, dest, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ReferenceGhostPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.opacity != opacity;
  }
}