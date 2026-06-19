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
/// Ghost and outline are separate [RepaintBoundary] layers so alignment color
/// updates do not re-filter the full reference image.
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
  Path? _outlinePath;
  Rect? _outlineDest;

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
    if (oldWidget.frameSpec.cropRect != widget.frameSpec.cropRect ||
        oldWidget.selectionContour != widget.selectionContour) {
      _outlinePath = null;
      _outlineDest = null;
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

    final image = _image!;
    final imageAspect = image.width / image.height;
    final outlinePath = widget.showOutline && widget.selectionContour.length >= 8
        ? _outlinePathFor(
            cropRect: widget.frameSpec.cropRect,
            imageAspect: imageAspect,
            selectionContour: widget.selectionContour,
          )
        : null;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.showGhost)
            RepaintBoundary(
              child: CustomPaint(
                painter: _GhostOverlayPainter(
                  image: image,
                  cropRect: widget.frameSpec.cropRect,
                  ghostOpacity: widget.ghostOpacity,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          if (outlinePath != null)
            RepaintBoundary(
              child: CustomPaint(
                painter: _OutlineOverlayPainter(
                  cropRect: widget.frameSpec.cropRect,
                  outlinePath: outlinePath,
                  alignmentPhase: widget.alignmentPhase,
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }

  Path _outlinePathFor({
    required Rect cropRect,
    required double imageAspect,
    required List<Offset> selectionContour,
  }) {
    final dest = ReferenceCoverFitMapper.imageDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );
    if (_outlinePath != null && _outlineDest == dest) {
      return _outlinePath!;
    }

    final mapped = ReferenceCoverFitMapper.mapContour(selectionContour, dest);
    _outlinePath = HumanFrameShapeBuilder().pointsToSmoothPath(mapped);
    _outlineDest = dest;
    return _outlinePath!;
  }
}

class _GhostOverlayPainter extends CustomPainter {
  _GhostOverlayPainter({
    required this.image,
    required this.cropRect,
    required this.ghostOpacity,
  });

  final ui.Image image;
  final Rect cropRect;
  final double ghostOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final imageAspect = image.width / image.height;
    final dest = ReferenceCoverFitMapper.imageDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );

    canvas.save();
    canvas.clipRect(cropRect);

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
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GhostOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.ghostOpacity != ghostOpacity;
  }
}

class _OutlineOverlayPainter extends CustomPainter {
  _OutlineOverlayPainter({
    required this.cropRect,
    required this.outlinePath,
    required this.alignmentPhase,
  });

  final Rect cropRect;
  final Path outlinePath;
  final AlignmentOverlayPhase alignmentPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final path = outlinePath;
    final strokeColor =
        AlignmentOverlayState.strokeColorForPhase(alignmentPhase);
    final glowColor =
        AlignmentOverlayState.glowColorForPhase(alignmentPhase);

    canvas.save();
    canvas.clipRect(cropRect);

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

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OutlineOverlayPainter oldDelegate) {
    return oldDelegate.alignmentPhase != alignmentPhase;
  }
}