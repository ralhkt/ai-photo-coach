import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/utils/viewport_letterbox.dart';
import '../../reference/services/frame_generator_service.dart';
import 'poze_wireframe_style.dart';

/// Faint reference image inside the crop area to help match pose.
class ReferenceGhostOverlay extends StatefulWidget {
  const ReferenceGhostOverlay({
    super.key,
    required this.imageBytes,
    required this.frameSpec,
    required this.visible,
    this.opacity = PozeWireframeStyle.ghostOpacity,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final bool visible;
  final double opacity;

  @override
  State<ReferenceGhostOverlay> createState() => _ReferenceGhostOverlayState();
}

final _ghostImageCache = <String, ui.Image>{};

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
    final key = '${widget.imageBytes.length}:${widget.imageBytes.hashCode}';
    final cached = _ghostImageCache[key];
    if (cached != null) {
      if (mounted) {
        setState(() => _image = cached);
      }
      return;
    }

    final codec = await ui.instantiateImageCodec(
      widget.imageBytes,
      targetWidth: 540,
    );
    final frame = await codec.getNextFrame();
    _ghostImageCache[key] = frame.image;
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
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..colorFilter = const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);

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