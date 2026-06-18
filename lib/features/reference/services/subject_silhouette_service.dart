import 'dart:math' as math;
import 'dart:ui';

import 'package:image/image.dart' as img;

import 'human_frame_shape_builder.dart';

/// Extracts a human-shaped contour from a reference portrait image.
class SubjectSilhouetteService {
  SubjectSilhouetteService({HumanFrameShapeBuilder? shapeBuilder})
      : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder();

  final HumanFrameShapeBuilder _shapeBuilder;

  List<Offset>? extractPortraitSilhouette(img.Image image, Rect subjectRect) {
    final contour = _extractContourFromImage(image, subjectRect);
    if (contour != null && contour.length >= 12) {
      return _shapeBuilder.refineContour(contour, subjectRect);
    }
    return _shapeBuilder.mapTemplateToSubject(subjectRect);
  }

  List<Offset>? _extractContourFromImage(img.Image image, Rect subjectRect) {
    final left = (subjectRect.left * image.width).floor().clamp(0, image.width - 1);
    final top = (subjectRect.top * image.height).floor().clamp(0, image.height - 1);
    final right = (subjectRect.right * image.width).ceil().clamp(left + 1, image.width);
    final bottom =
        (subjectRect.bottom * image.height).ceil().clamp(top + 1, image.height);

    final crop = img.copyCrop(
      image,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );

    final sample = img.copyResize(crop, width: 48, height: 72);
    final bg = _estimateBackground(sample);
    final mask = List.generate(
      sample.height,
      (_) => List.filled(sample.width, false),
    );

    for (var y = 0; y < sample.height; y++) {
      for (var x = 0; x < sample.width; x++) {
        final pixel = sample.getPixel(x, y);
        mask[y][x] = _isForeground(pixel, bg);
      }
    }

    final leftEdge = List<double>.filled(sample.height, sample.width.toDouble());
    final rightEdge = List<double>.filled(sample.height, 0);

    for (var y = 0; y < sample.height; y++) {
      for (var x = 0; x < sample.width; x++) {
        if (!mask[y][x]) {
          continue;
        }
        leftEdge[y] = math.min(leftEdge[y], x.toDouble());
        rightEdge[y] = math.max(rightEdge[y], x.toDouble());
      }
    }

    var validRows = 0;
    for (var y = 0; y < sample.height; y++) {
      if (rightEdge[y] > leftEdge[y]) {
        validRows++;
      }
    }
    if (validRows < sample.height ~/ 3) {
      return null;
    }

    _smoothEdges(leftEdge, rightEdge, sample.height);

    final points = <Offset>[];
    final headRows = (sample.height * 0.22).round();
    final topCenterX = sample.width / 2;

    points.add(_toNormalized(topCenterX, 0, sample, left, top, crop.width, crop.height, image));

    for (var y = 0; y < headRows; y++) {
      if (rightEdge[y] > leftEdge[y]) {
        points.add(_toNormalized(
          rightEdge[y],
          y.toDouble(),
          sample,
          left,
          top,
          crop.width,
          crop.height,
          image,
        ));
      }
    }

    for (var y = 0; y < sample.height; y++) {
      if (rightEdge[y] > leftEdge[y]) {
        points.add(_toNormalized(
          rightEdge[y],
          y.toDouble(),
          sample,
          left,
          top,
          crop.width,
          crop.height,
          image,
        ));
      }
    }

    for (var y = sample.height - 1; y >= 0; y--) {
      if (rightEdge[y] > leftEdge[y]) {
        points.add(_toNormalized(
          leftEdge[y],
          y.toDouble(),
          sample,
          left,
          top,
          crop.width,
          crop.height,
          image,
        ));
      }
    }

    for (var y = headRows; y >= 0; y--) {
      if (rightEdge[y] > leftEdge[y]) {
        points.add(_toNormalized(
          leftEdge[y],
          y.toDouble(),
          sample,
          left,
          top,
          crop.width,
          crop.height,
          image,
        ));
      }
    }

    return _dedupePoints(points);
  }

  Offset _toNormalized(
    double x,
    double y,
    img.Image sample,
    int cropLeft,
    int cropTop,
    int cropWidth,
    int cropHeight,
    img.Image full,
  ) {
    final localX = x / sample.width;
    final localY = y / sample.height;
    final imageX = (cropLeft + localX * cropWidth) / full.width;
    final imageY = (cropTop + localY * cropHeight) / full.height;
    return Offset(imageX.clamp(0.0, 1.0), imageY.clamp(0.0, 1.0));
  }

  List<double> _estimateBackground(img.Image sample) {
    final samples = <List<double>>[];
    final corners = [
      sample.getPixel(0, 0),
      sample.getPixel(sample.width - 1, 0),
      sample.getPixel(0, sample.height - 1),
      sample.getPixel(sample.width - 1, sample.height - 1),
    ];
    for (final pixel in corners) {
      samples.add([pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()]);
    }
    return [
      samples.map((v) => v[0]).reduce((a, b) => a + b) / samples.length,
      samples.map((v) => v[1]).reduce((a, b) => a + b) / samples.length,
      samples.map((v) => v[2]).reduce((a, b) => a + b) / samples.length,
    ];
  }

  bool _isForeground(img.Pixel pixel, List<double> bg) {
    final r = pixel.r.toDouble();
    final g = pixel.g.toDouble();
    final b = pixel.b.toDouble();
    final distance = math.sqrt(
      math.pow(r - bg[0], 2) + math.pow(g - bg[1], 2) + math.pow(b - bg[2], 2),
    );

    final isSkin = r > 95 && g > 40 && b > 20 && r > g && r > b && (r - g) > 15;
    return distance > 28 || isSkin;
  }

  void _smoothEdges(List<double> leftEdge, List<double> rightEdge, int height) {
    for (var pass = 0; pass < 2; pass++) {
      for (var y = 1; y < height - 1; y++) {
        if (rightEdge[y] <= leftEdge[y]) {
          continue;
        }
        leftEdge[y] = (leftEdge[y - 1] + leftEdge[y] + leftEdge[y + 1]) / 3;
        rightEdge[y] = (rightEdge[y - 1] + rightEdge[y] + rightEdge[y + 1]) / 3;
      }
    }
  }

  List<Offset> _dedupePoints(List<Offset> points) {
    if (points.length < 3) {
      return points;
    }
    final result = <Offset>[points.first];
    for (var i = 1; i < points.length; i++) {
      final prev = result.last;
      final current = points[i];
      if ((current - prev).distance > 0.008) {
        result.add(current);
      }
    }
    return result;
  }
}