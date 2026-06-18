import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Perceptual hash (pHash-style DCT) for lightweight scene-change detection.
class PHashService {
  static const int hashSize = 8;

  String computeFromJpeg(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image for pHash');
    }
    return _computeFromImage(decoded);
  }

  String computeFromCameraImage(CameraImage image) {
    final gray = _cameraImageToGray(image);
    return _computeFromGrayMatrix(gray);
  }

  int hammingDistance(String a, String b) {
    if (a.length != b.length) {
      return math.max(a.length, b.length);
    }
    var distance = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        distance++;
      }
    }
    return distance;
  }

  String _computeFromImage(img.Image image) {
    final resized = img.copyResize(image, width: 32, height: 32);
    final gray = List.generate(32, (y) {
      return List.generate(32, (x) {
        final pixel = resized.getPixel(x, y);
        return (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
      });
    });
    return _computeFromGrayMatrix(gray);
  }

  String _computeFromGrayMatrix(List<List<double>> gray) {
    final dct = _dct2d(gray);
    final values = <double>[];
    for (var y = 0; y < hashSize; y++) {
      for (var x = 0; x < hashSize; x++) {
        if (x == 0 && y == 0) {
          continue;
        }
        values.add(dct[y][x]);
      }
    }
    final median = _median(values);
    final buffer = StringBuffer();
    for (var y = 0; y < hashSize; y++) {
      for (var x = 0; x < hashSize; x++) {
        if (x == 0 && y == 0) {
          continue;
        }
        buffer.write(dct[y][x] > median ? '1' : '0');
      }
    }
    return buffer.toString();
  }

  List<List<double>> _cameraImageToGray(CameraImage image) {
    final plane = image.planes.first;
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    final sampleW = 32;
    final sampleH = 32;
    final gray = List.generate(sampleH, (_) => List.filled(sampleW, 0.0));

    for (var y = 0; y < sampleH; y++) {
      for (var x = 0; x < sampleW; x++) {
        final srcX = (x * width / sampleW).floor().clamp(0, width - 1);
        final srcY = (y * height / sampleH).floor().clamp(0, height - 1);
        final bytesPerPixel = plane.bytesPerPixel ?? 1;
        final index = srcY * plane.bytesPerRow + srcX * bytesPerPixel;
        final value = index < bytes.length ? bytes[index] : 0;
        gray[y][x] = value / 255.0;
      }
    }
    return gray;
  }

  List<List<double>> _dct2d(List<List<double>> input) {
    final n = input.length;
    final temp = List.generate(n, (i) => List.filled(n, 0.0));
    final output = List.generate(n, (i) => List.filled(n, 0.0));

    for (var y = 0; y < n; y++) {
      for (var u = 0; u < n; u++) {
        var sum = 0.0;
        for (var x = 0; x < n; x++) {
          sum += input[y][x] *
              math.cos(((2 * x + 1) * u * math.pi) / (2 * n));
        }
        temp[u][y] = sum;
      }
    }

    for (var u = 0; u < n; u++) {
      for (var v = 0; v < n; v++) {
        var sum = 0.0;
        for (var y = 0; y < n; y++) {
          sum += temp[u][y] *
              math.cos(((2 * y + 1) * v * math.pi) / (2 * n));
        }
        output[u][v] = sum;
      }
    }
    return output;
  }

  double _median(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[mid];
    }
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}