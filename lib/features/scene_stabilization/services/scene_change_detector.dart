import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import 'phash_service.dart';

class SceneChangeResult {
  const SceneChangeResult({
    required this.hash,
    required this.hammingDistance,
    required this.isStable,
    required this.usedFrameDifference,
  });

  final String hash;
  final int hammingDistance;
  final bool isStable;
  final bool usedFrameDifference;
}

class SceneChangeDetector {
  SceneChangeDetector({
    PHashService? pHashService,
    this.stableThreshold = 10,
    this.frameDifferenceThreshold = 0.045,
  }) : _pHashService = pHashService ?? PHashService();

  final PHashService _pHashService;
  final int stableThreshold;
  final double frameDifferenceThreshold;

  String? _lastHash;
  double? _lastMeanLuma;

  /// JPEG fallback for iOS where [CameraImage] stream is unavailable.
  SceneChangeResult evaluateFromJpeg(Uint8List bytes) {
    final hash = _pHashService.computeFromJpeg(bytes);
    final distance = _lastHash == null
        ? stableThreshold + 1
        : _pHashService.hammingDistance(_lastHash!, hash);

    final meanLuma = _meanLumaFromJpeg(bytes);
    final lumaDelta = _lastMeanLuma == null
        ? frameDifferenceThreshold + 1
        : (meanLuma - _lastMeanLuma!).abs();

    _lastHash = hash;
    _lastMeanLuma = meanLuma;

    final hashStable = distance <= stableThreshold;
    final frameStable = lumaDelta <= frameDifferenceThreshold;

    return SceneChangeResult(
      hash: hash,
      hammingDistance: distance,
      isStable: hashStable && frameStable,
      usedFrameDifference: !frameStable,
    );
  }

  SceneChangeResult evaluate(CameraImage image) {
    final hash = _pHashService.computeFromCameraImage(image);
    final distance = _lastHash == null
        ? stableThreshold + 1
        : _pHashService.hammingDistance(_lastHash!, hash);

    final meanLuma = _meanLuma(image);
    final lumaDelta = _lastMeanLuma == null
        ? frameDifferenceThreshold + 1
        : (meanLuma - _lastMeanLuma!).abs();

    _lastHash = hash;
    _lastMeanLuma = meanLuma;

    final hashStable = distance <= stableThreshold;
    final frameStable = lumaDelta <= frameDifferenceThreshold;

    return SceneChangeResult(
      hash: hash,
      hammingDistance: distance,
      isStable: hashStable && frameStable,
      usedFrameDifference: !frameStable,
    );
  }

  void reset() {
    _lastHash = null;
    _lastMeanLuma = null;
  }

  double _meanLumaFromJpeg(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return 0;
    }
    final sample = img.copyResize(decoded, width: 48);
    var total = 0.0;
    final count = sample.width * sample.height;
    for (var y = 0; y < sample.height; y++) {
      for (var x = 0; x < sample.width; x++) {
        final pixel = sample.getPixel(x, y);
        total += (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255;
      }
    }
    return total / count;
  }

  double _meanLuma(CameraImage image) {
    final plane = image.planes.first;
    final bytes = plane.bytes;
    if (bytes.isEmpty) {
      return 0;
    }

    var total = 0;
    final step = (bytes.length / 512).floor().clamp(1, bytes.length);
    var count = 0;
    for (var i = 0; i < bytes.length; i += step) {
      total += bytes[i];
      count++;
    }
    return total / count / 255.0;
  }
}