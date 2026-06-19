import 'package:camera/camera.dart';

abstract final class CameraConstants {
  static const Duration initTimeout = Duration(seconds: 10);

  /// High resolution preview — native iOS layer stays sharp; lower capture cost for ML sampling.
  static const ResolutionPreset previewResolution = ResolutionPreset.veryHigh;

  static const double overlayStrokeWidth = 0.5;
  static const double overlayAccentStrokeWidth = 1.6;
  static const double goldenRatio = 1.61803398875;
}