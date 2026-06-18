import 'dart:ui';

enum CameraAspectRatio {
  ratio4x3,
  ratio16x9,
  ratio1x1,
  full,
}

extension CameraAspectRatioX on CameraAspectRatio {
  /// Photo width÷height in landscape terms (4:3 → 4/3).
  double? get photoWidthOverHeight => switch (this) {
        CameraAspectRatio.ratio4x3 => 4 / 3,
        CameraAspectRatio.ratio16x9 => 16 / 9,
        CameraAspectRatio.ratio1x1 => 1,
        CameraAspectRatio.full => null,
      };

  /// Width÷height of the centered on-screen crop (iPhone-style).
  double? displayCropRatio(Size viewport) {
    final photo = photoWidthOverHeight;
    if (photo == null) {
      return null;
    }
    final portrait = viewport.height >= viewport.width;
    return portrait ? 1 / photo : photo;
  }

  String get l10nKey => switch (this) {
        CameraAspectRatio.ratio4x3 => 'aspectRatio4x3',
        CameraAspectRatio.ratio16x9 => 'aspectRatio16x9',
        CameraAspectRatio.ratio1x1 => 'aspectRatio1x1',
        CameraAspectRatio.full => 'aspectRatioFull',
      };

  CameraAspectRatio get next => switch (this) {
        CameraAspectRatio.ratio4x3 => CameraAspectRatio.ratio16x9,
        CameraAspectRatio.ratio16x9 => CameraAspectRatio.ratio1x1,
        CameraAspectRatio.ratio1x1 => CameraAspectRatio.full,
        CameraAspectRatio.full => CameraAspectRatio.ratio4x3,
      };
}