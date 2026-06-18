import 'package:camera/camera.dart';

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