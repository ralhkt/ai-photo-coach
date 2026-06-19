import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../models/body_part_labels.dart';
import '../../reference/services/frame_generator_service.dart' show GeneratedFrameSpec;
import 'photo_frame_painter.dart';
import 'poze_wireframe_style.dart';

class PhotoFrameOverlay extends StatefulWidget {
  const PhotoFrameOverlay({
    super.key,
    required this.frameSpec,
    required this.templateLabel,
    required this.visible,
    this.bodyPartLabels,
    this.showBodyParts = true,
    this.minimalPozeStyle = true,
    this.animateEntry = true,
    this.poseAligned = false,
    this.alignmentScore,
    this.renderHumanSilhouette = true,
    this.skeletonStrokeWidth,
  });

  final GeneratedFrameSpec frameSpec;
  final String templateLabel;
  final bool visible;
  final BodyPartLabels? bodyPartLabels;
  final bool showBodyParts;
  final bool minimalPozeStyle;
  final bool animateEntry;
  final bool poseAligned;
  final int? alignmentScore;
  final bool renderHumanSilhouette;
  final double? skeletonStrokeWidth;

  @override
  State<PhotoFrameOverlay> createState() => _PhotoFrameOverlayState();
}

class _PhotoFrameOverlayState extends State<PhotoFrameOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDesignTokens.motionMedium,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppDesignTokens.motionEaseOut,
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppDesignTokens.motionSpring),
    );
    if (widget.visible && widget.animateEntry) {
      _controller.forward();
    } else if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant PhotoFrameOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      if (widget.animateEntry) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    } else if (!widget.visible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: CustomPaint(
            painter: PhotoFramePainter(
              frameSpec: widget.frameSpec,
              templateLabel: widget.templateLabel,
              bodyPartLabels: widget.bodyPartLabels,
              showBodyParts: widget.showBodyParts,
              minimalPozeStyle: widget.minimalPozeStyle,
              poseAligned: widget.poseAligned,
              alignmentScore: widget.alignmentScore,
              renderHumanSilhouette: widget.renderHumanSilhouette,
              skeletonStrokeWidth:
                  widget.skeletonStrokeWidth ?? PozeWireframeStyle.limbStrokeWidth,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}