import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../pose/presentation/pose_skeleton_coordinate_mapper.dart';
import '../services/reference_skeleton_image_exporter.dart';
import 'reference_photo_skeleton_painter.dart';

/// 參考照 + 美術生骨架線（可僅骨架、可調線條粗細）。
class ReferencePhotoSkeletonPreview extends StatelessWidget {
  const ReferencePhotoSkeletonPreview({
    super.key,
    required this.imageBytes,
    required this.skeletonSegments,
    required this.imageAspectRatio,
    this.height = 260,
    this.showJoints = true,
    this.skeletonOnly = false,
    this.strokeWidth = ReferenceSkeletonImageExporter.defaultStrokeWidth,
  });

  final Uint8List imageBytes;
  final List<List<Offset>> skeletonSegments;
  final double imageAspectRatio;
  final double height;
  final bool showJoints;
  final bool skeletonOnly;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final previewSize = Size(width, height);
        final mapper = PoseSkeletonCoordinateMapper(
          imageSize: Size(
            imageAspectRatio > 0 ? imageAspectRatio : 1,
            1,
          ),
          previewSize: previewSize,
        );

        final lineColor = skeletonOnly
            ? ReferenceSkeletonImageExporter.skeletonOnlyLineColor
            : Colors.white.withValues(alpha: 0.92);
        final glowColor = skeletonOnly
            ? ReferenceSkeletonImageExporter.skeletonOnlyGlowColor
            : const Color(0x88FFD60A);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (skeletonOnly)
                  const ColoredBox(
                    color: ReferenceSkeletonImageExporter.skeletonOnlyBackground,
                  )
                else
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                if (skeletonSegments.isNotEmpty)
                  CustomPaint(
                    painter: ReferencePhotoSkeletonPainter(
                      segments: skeletonSegments,
                      mapper: mapper,
                      strokeWidth: strokeWidth,
                      strokeColor: lineColor,
                      glowColor: glowColor,
                      drawJoints: showJoints,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}