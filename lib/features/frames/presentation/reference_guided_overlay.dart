import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/utils/reference_cover_fit_mapper.dart';
import '../../pose/services/alignment_overlay_state.dart';
import '../../reference/services/frame_generator_service.dart';
import '../../reference/services/human_frame_shape_builder.dart';
import 'poze_wireframe_style.dart';
import 'reference_image_cache.dart';

/// Guided overlay: ghost reference photo + Photoshop-style subject outline.
///
/// Both layers decode the same [imageBytes], compute one cover-fit rect from the
/// decoded aspect ratio, and draw the selection boundary on top of the photo.
class ReferenceGuidedOverlay extends StatefulWidget {
  const ReferenceGuidedOverlay({
    super.key,
    required this.imageBytes,
    required this.frameSpec,
    required this.selectionContour,
    required this.visible,
    this.showGhost = true,
    this.showOutline = true,
    this.ghostOpacity = PozeWireframeStyle.ghostOpacity,
    this.alignmentPhase = AlignmentOverlayPhase.noMatch,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final List<Offset> selectionContour;
  final bool visible;
  final bool showGhost;
  final bool showOutline;
  final double ghostOpacity;
  final AlignmentOverlayPhase alignmentPhase;

  @override
  State<ReferenceGuidedOverlay> createState() => _ReferenceGuidedOverlayState();
}

class _ReferenceGuidedOverlayState extends State<ReferenceGuidedOverlay> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant ReferenceGuidedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBytes != widget.imageBytes) {
      _decode();
    }
  }

  Future<void> _decode() async {
    final image = await decodeReferenceImage(widget.imageBytes);
    if (mounted) {
      setState(() => _image = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || _image == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _ReferenceGuidedOverlayPainter(
          image: _image!,
          cropRect: widget.frameSpec.cropRect,
          selectionContour: widget.selectionContour,
          showGhost: widget.showGhost,
          showOutline: widget.showOutline,
          ghostOpacity: widget.ghostOpacity,
          alignmentPhase: widget.alignmentPhase,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReferenceGuidedOverlayPainter extends CustomPainter {
  _ReferenceGuidedOverlayPainter({
    required this.image,
    required this.cropRect,
    required this.selectionContour,
    required this.showGhost,
    required this.showOutline,
    required this.ghostOpacity,
    required this.alignmentPhase,
  });

  final ui.Image image;
  final Rect cropRect;
  final List<Offset> selectionContour;
  final bool showGhost;
  final bool showOutline;
  final double ghostOpacity;
  final AlignmentOverlayPhase alignmentPhase;

  static final _shapeBuilder = HumanFrameShapeBuilder();

  @override
  void paint(Canvas canvas, Size size) {
    final imageAspect = image.width / image.height;
    final dest = ReferenceCoverFitMapper.imageDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );

    canvas.save();
    canvas.clipRect(cropRect);

    if (showGhost) {
      _drawGhost(canvas, dest);
    }

    if (showOutline && selectionContour.length >= 8) {
      _drawSelectionOutline(canvas, dest);
    }

    canvas.restore();
  }

  void _drawGhost(Canvas canvas, Rect dest) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: ghostOpacity)
      ..colorFilter = const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);

    canvas.drawImageRect(image, src, dest, paint);
  }

  void _drawSelectionOutline(Canvas canvas, Rect dest) {
    final mapped = ReferenceCoverFitMapper.mapContour(selectionContour, dest);
    final path = _shapeBuilder.pointsToSmoothPath(mapped);

    final strokeColor =
        AlignmentOverlayState.strokeColorForPhase(alignmentPhase);
    final glowColor =
        AlignmentOverlayState.glowColorForPhase(alignmentPhase);

    canvas.drawPath(
      path,
      Paint()
        ..color = PozeWireframeStyle.silhouetteFillColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.glowStrokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = alignmentPhase == AlignmentOverlayPhase.matched
            ? PozeWireframeStyle.bodyStrokeWidth
            : PozeWireframeStyle.minimalBodyStrokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _ReferenceGuidedOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.selectionContour != selectionContour ||
        oldDelegate.showGhost != showGhost ||
        oldDelegate.showOutline != showOutline ||
        oldDelegate.ghostOpacity != ghostOpacity ||
        oldDelegate.alignmentPhase != alignmentPhase;
  }
}