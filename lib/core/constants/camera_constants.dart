import 'package:camera/camera.dart';

abstract final class CameraConstants {
  static const Duration initTimeout = Duration(seconds: 10);

  /// Full sensor resolution — matches native Camera app sharpness on iOS.
  /// ML pose coaching downscales snapshots internally (480px) so preview can stay crisp.
  static const ResolutionPreset previewResolution = ResolutionPreset.max;

  static const double overlayStrokeWidth = 0.5;
  static const double overlayAccentStrokeWidth = 1.6;
  static const double goldenRatio = 1.61803398875;
}