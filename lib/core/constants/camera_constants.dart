import 'package:camera/camera.dart';

abstract final class CameraConstants {
  static const Duration initTimeout = Duration(seconds: 10);

  /// Balanced preview — veryHigh + takePicture polling caused visible preview hitches.
  static const ResolutionPreset previewResolution = ResolutionPreset.high;

  static const double overlayStrokeWidth = 0.5;
  static const double overlayAccentStrokeWidth = 1.6;
  static const double goldenRatio = 1.61803398875;
}