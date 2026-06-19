import 'dart:math' as math;
import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../core/utils/contour_smoother.dart';

/// Extracts a smooth portrait silhouette from reference image pixels (PR-1 MVP).
///
/// Uses contrast masking inside [subjectRect], Moore boundary tracing, RDP
/// simplification, and arc-length resampling for Bézier-ready polylines.
class PortraitContourExtractor {
  const PortraitContourExtractor({
    this.foregroundThreshold = 42,
    this.rdpEpsilon = 0.004,
    this.minBoundaryPoints = 16,
    this.outputPointCount = 56,
    this.maxBoundaryPoints = 512,
  });

  final double foregroundThreshold;
  final double rdpEpsilon;
  final int minBoundaryPoints;
  final int outputPointCount;
  final int maxBoundaryPoints;

  /// Returns normalized contour points, or null when extraction fails.
  List<Offset>? extract(
    img.Image image,
    Rect subjectRect,
  ) {
    if (image.width <= 0 || image.height <= 0 || subjectRect.isEmpty) {
      return null;
    }

    final left = (subjectRect.left * image.width).floor().clamp(0, image.width - 1);
    final top = (subjectRect.top * image.height).floor().clamp(0, image.height - 1);
    final right = (subjectRect.right * image.width).ceil().clamp(left + 1, image.width);
    final bottom = (subjectRect.bottom * image.height).ceil().clamp(top + 1, image.height);

    final roiW = right - left;
    final roiH = bottom - top;
    if (roiW < 24 || roiH < 24) {
      return null;
    }

    final bgColor = _estimateBackgroundColor(image, left, top, roiW, roiH);
    final fgColor = _estimateForegroundColor(image, left, top, roiW, roiH);
    final thresholds = <double>[
      foregroundThreshold,
      foregroundThreshold * 0.75,
      foregroundThreshold * 1.25,
      foregroundThreshold * 1.6,
    ];

    List<Offset>? bestBoundary;
    var bestScore = -1.0;

    for (final threshold in thresholds) {
      final mask = List.generate(roiH, (_) => List<bool>.filled(roiW, false));
      for (var y = 0; y < roiH; y++) {
        for (var x = 0; x < roiW; x++) {
          final pixel = image.getPixel(left + x, top + y);
          final distBg = _colorDistance(pixel, bgColor);
          final distFg = _colorDistance(pixel, fgColor);
          mask[y][x] = distBg > threshold && distFg < threshold * 1.35;
        }
      }

      _fillSmallHoles(mask, roiW, roiH);
      final boundary = _traceBoundary(mask, roiW, roiH);
      if (boundary.length < minBoundaryPoints) {
        continue;
      }

      final score = _scoreBoundary(boundary, roiW, roiH);
      if (score > bestScore) {
        bestScore = score;
        bestBoundary = boundary;
      }
    }

    var boundary = bestBoundary ?? const <Offset>[];
    if (boundary.length < minBoundaryPoints) {
      return null;
    }

    if (boundary.length > maxBoundaryPoints) {
      boundary = _decimateContour(boundary, maxBoundaryPoints);
    }

    final normalized = boundary
        .map(
          (p) => Offset(
            ((left + p.dx) / image.width).clamp(0.0, 1.0),
            ((top + p.dy) / image.height).clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);

    final simplified = ContourSmoother.douglasPeucker(
      normalized,
      epsilon: rdpEpsilon,
    );

    if (simplified.length < 4) {
      return null;
    }

    final targetCount = math.max(outputPointCount, 8);
    if (simplified.length < targetCount) {
      return ContourSmoother.resampleClosedContour(
        simplified,
        targetCount: targetCount,
      );
    }
    return simplified;
  }

  double _scoreBoundary(List<Offset> boundary, int roiW, int roiH) {
    if (boundary.isEmpty) {
      return 0;
    }

    var minX = boundary.first.dx;
    var maxX = boundary.first.dx;
    var minY = boundary.first.dy;
    var maxY = boundary.first.dy;
    for (final point in boundary) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    final width = (maxX - minX).clamp(1.0, roiW.toDouble());
    final height = (maxY - minY).clamp(1.0, roiH.toDouble());
    final areaRatio = (width * height) / (roiW * roiH);
    final aspect = height / width;

    var score = boundary.length.clamp(0, 400).toDouble();
    if (areaRatio >= 0.22 && areaRatio <= 0.82) {
      score += 80;
    }
    if (aspect >= 1.15 && aspect <= 3.8) {
      score += 60;
    }
    return score;
  }

  img.ColorRgb8 _estimateBackgroundColor(
    img.Image image,
    int left,
    int top,
    int roiW,
    int roiH,
  ) {
    var r = 0.0;
    var g = 0.0;
    var b = 0.0;
    var count = 0;

    void sample(int x, int y) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) {
        return;
      }
      final pixel = image.getPixel(x, y);
      r += pixel.r;
      g += pixel.g;
      b += pixel.b;
      count++;
    }

    for (var x = left; x < left + roiW; x++) {
      sample(x, top);
      sample(x, top + roiH - 1);
    }
    for (var y = top; y < top + roiH; y++) {
      sample(left, y);
      sample(left + roiW - 1, y);
    }

    if (count == 0) {
      return img.ColorRgb8(32, 36, 44);
    }

    return img.ColorRgb8(
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
    );
  }

  img.ColorRgb8 _estimateForegroundColor(
    img.Image image,
    int left,
    int top,
    int roiW,
    int roiH,
  ) {
    final cx = left + (roiW * 0.5).floor();
    final cy = top + (roiH * 0.38).floor();
    final rx = (roiW * 0.22).floor().clamp(4, roiW ~/ 2);
    final ry = (roiH * 0.18).floor().clamp(4, roiH ~/ 2);

    var r = 0.0;
    var g = 0.0;
    var b = 0.0;
    var count = 0;

    for (var y = cy - ry; y <= cy + ry; y++) {
      if (y < top || y >= top + roiH) {
        continue;
      }
      for (var x = cx - rx; x <= cx + rx; x++) {
        if (x < left || x >= left + roiW) {
          continue;
        }
        final pixel = image.getPixel(x, y);
        r += pixel.r;
        g += pixel.g;
        b += pixel.b;
        count++;
      }
    }

    if (count == 0) {
      final center = image.getPixel(cx.clamp(0, image.width - 1), cy.clamp(0, image.height - 1));
      return img.ColorRgb8(center.r.toInt(), center.g.toInt(), center.b.toInt());
    }

    return img.ColorRgb8(
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
    );
  }

  double _colorDistance(img.Pixel pixel, img.ColorRgb8 ref) {
    final dr = pixel.r - ref.r;
    final dg = pixel.g - ref.g;
    final db = pixel.b - ref.b;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  void _fillSmallHoles(List<List<bool>> mask, int w, int h) {
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        if (mask[y][x]) {
          continue;
        }
        var neighbors = 0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (mask[y + dy][x + dx]) {
              neighbors++;
            }
          }
        }
        if (neighbors >= 7) {
          mask[y][x] = true;
        }
      }
    }
  }

  List<Offset> _traceBoundary(List<List<bool>> mask, int w, int h) {
    var startX = -1;
    var startY = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (mask[y][x]) {
          startX = x;
          startY = y;
          y = h;
          break;
        }
      }
    }
    if (startX < 0) {
      return const [];
    }

    const dirs = <(int, int)>[
      (1, 0),
      (1, -1),
      (0, -1),
      (-1, -1),
      (-1, 0),
      (-1, 1),
      (0, 1),
      (1, 1),
    ];

    final contour = <Offset>[];
    var x = startX;
    var y = startY;
    var dir = 7;

    do {
      contour.add(Offset(x.toDouble(), y.toDouble()));
      final search = (dir + 5) % 8;
      var found = false;
      for (var i = 0; i < 8; i++) {
        final d = (search + i) % 8;
        final (dx, dy) = dirs[d];
        final nx = x + dx;
        final ny = y + dy;
        if (nx >= 0 && nx < w && ny >= 0 && ny < h && mask[ny][nx]) {
          x = nx;
          y = ny;
          dir = d;
          found = true;
          break;
        }
      }
      if (!found) {
        break;
      }
    } while (x != startX || y != startY || contour.length == 1);

    if (contour.length > 1 && contour.first == contour.last) {
      contour.removeLast();
    }
    return contour;
  }

  List<Offset> _decimateContour(List<Offset> points, int maxPoints) {
    if (points.length <= maxPoints) {
      return points;
    }
    final step = points.length / maxPoints;
    return [
      for (var i = 0; i < maxPoints; i++) points[(i * step).floor()],
    ];
  }
}