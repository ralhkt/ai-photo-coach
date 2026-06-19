/// Camera EXIF tags extracted from reference / upload photos.
class PhotoExifMetadata {
  const PhotoExifMetadata({
    this.iso,
    this.shutterSpeedSeconds,
    this.aperture,
    this.focalLengthMm,
    this.cameraMake,
    this.cameraModel,
    this.dateTimeOriginal,
  });

  final int? iso;
  final double? shutterSpeedSeconds;
  final double? aperture;
  final double? focalLengthMm;
  final String? cameraMake;
  final String? cameraModel;
  final String? dateTimeOriginal;

  bool get hasAny =>
      iso != null ||
      shutterSpeedSeconds != null ||
      aperture != null ||
      focalLengthMm != null ||
      (cameraMake?.isNotEmpty ?? false) ||
      (cameraModel?.isNotEmpty ?? false);

  String? get cameraLabel {
    final parts = <String>[];
    if (cameraMake != null && cameraMake!.isNotEmpty) {
      parts.add(cameraMake!);
    }
    if (cameraModel != null && cameraModel!.isNotEmpty) {
      parts.add(cameraModel!);
    }
    return parts.isEmpty ? null : parts.join(' ');
  }
}