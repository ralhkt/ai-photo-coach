import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/utils/viewport_letterbox.dart';
import '../../pose/presentation/pose_skeleton_coordinate_mapper.dart';
import '../presentation/reference_photo_skeleton_painter.dart';

/// 將參考照 + 骨架渲染為 PNG（可僅骨架、可調線條粗細）。
abstract final class ReferenceSkeletonImageExporter {
  static const defaultStrokeWidth = 2.2;
  static const skeletonOnlyBackground = Color(0xFF141414);
  static const skeletonOnlyLineColor = Color(0xFFE8E8E8);
  static const skeletonOnlyGlowColor = Color(0x66FFFFFF);

  static Future<Uint8List> renderPng({
    required Uint8List imageBytes,
    required List<List<Offset>> skeletonSegments,
    required double imageAspectRatio,
    bool skeletonOnly = false,
    double strokeWidth = defaultStrokeWidth,
    int? maxLongEdge,
  }) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('無法解碼參考圖');
    }

    final aspect = imageAspectRatio > 0
        ? imageAspectRatio
        : decoded.width / decoded.height;
    var width = decoded.width;
    var height = decoded.height;

    if (maxLongEdge != null) {
      final longest = width > height ? width : height;
      if (longest > maxLongEdge) {
        final scale = maxLongEdge / longest;
        width = (width * scale).round();
        height = (height * scale).round();
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());
    final cropRect = Offset.zero & size;

    if (skeletonOnly) {
      canvas.drawRect(
        cropRect,
        Paint()..color = skeletonOnlyBackground,
      );
    } else {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(img.encodeJpg(decoded, quality: 95)),
        targetWidth: width,
        targetHeight: height,
      );
      final frame = await codec.getNextFrame();
      final dest = ViewportLetterbox.coverFitDestRect(
        cropRect: cropRect,
        imageAspectRatio: aspect,
      );
      canvas.drawImageRect(
        frame.image,
        Rect.fromLTWH(
          0,
          0,
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        ),
        dest,
        Paint(),
      );
    }

    if (skeletonSegments.isNotEmpty) {
      final mapper = PoseSkeletonCoordinateMapper(
        imageSize: Size(aspect, 1),
        previewSize: size,
        cropRect: cropRect,
      );
      ReferencePhotoSkeletonPainter(
        segments: skeletonSegments,
        mapper: mapper,
        strokeWidth: strokeWidth,
        strokeColor: skeletonOnly
            ? skeletonOnlyLineColor
            : Colors.white.withValues(alpha: 0.92),
        glowColor: skeletonOnly ? skeletonOnlyGlowColor : const Color(0x88FFD60A),
      ).paint(canvas, size);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('PNG 編碼失敗');
    }
    return bytes.buffer.asUint8List();
  }
}