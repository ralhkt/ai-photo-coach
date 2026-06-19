import 'dart:typed_data';

import 'package:exif/exif.dart';

import '../../../models/photo_exif_metadata.dart';

/// Reads ISO / shutter / aperture / focal length from JPEG EXIF.
class ExifReaderService {
  const ExifReaderService();

  Future<PhotoExifMetadata> read(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) {
        return const PhotoExifMetadata();
      }

      return PhotoExifMetadata(
        iso: _parseIso(tags),
        shutterSpeedSeconds: _parseShutter(tags),
        aperture: _parseAperture(tags),
        focalLengthMm: _parseFocalLength(tags),
        cameraMake: tags['Image Make']?.printable,
        cameraModel: tags['Image Model']?.printable,
        dateTimeOriginal: tags['EXIF DateTimeOriginal']?.printable ??
            tags['Image DateTime']?.printable,
      );
    } catch (_) {
      return const PhotoExifMetadata();
    }
  }

  int? _parseIso(Map<String, IfdTag> tags) {
    final raw = tags['EXIF ISOSpeedRatings']?.printable ??
        tags['EXIF PhotographicSensitivity']?.printable;
    if (raw == null) {
      return null;
    }
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  double? _parseShutter(Map<String, IfdTag> tags) {
    final exposure = tags['EXIF ExposureTime']?.printable;
    if (exposure == null) {
      return null;
    }
    if (exposure.contains('/')) {
      final parts = exposure.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
    }
    return double.tryParse(exposure);
  }

  double? _parseAperture(Map<String, IfdTag> tags) {
    final raw = tags['EXIF FNumber']?.printable ??
        tags['EXIF ApertureValue']?.printable;
    if (raw == null) {
      return null;
    }
    if (raw.contains('/')) {
      final parts = raw.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
    }
    return double.tryParse(raw);
  }

  double? _parseFocalLength(Map<String, IfdTag> tags) {
    final raw = tags['EXIF FocalLength']?.printable;
    if (raw == null) {
      return null;
    }
    if (raw.contains('/')) {
      final parts = raw.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
    }
    return double.tryParse(raw);
  }
}