import 'package:camera/camera.dart';

abstract final class CameraConstants {
  static const Duration initTimeout = Duration(seconds: 10);

  /// Balanced preview — veryHigh + takePicture polling caused visible preview hitches.
  static const ResolutionPreset previewResolution = ResolutionPreset.high;

  /// Front camera opens faster at medium without a visible quality loss in preview.
  static const ResolutionPreset frontPreviewResolution = ResolutionPreset.medium;

  /// Short AVFoundation gap after dispose before opening the next lens.
  static const Duration iosSessionReleaseDelay = Duration(milliseconds: 48);

  static const double overlayStrokeWidth = 0.5;
  static const double overlayAccentStrokeWidth = 1.6;
  static const double goldenRatio = 1.61803398875;
}