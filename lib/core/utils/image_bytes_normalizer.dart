import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'image_downscaler.dart';

/// Ensures image bytes are decodable JPEG before on-device analysis.
class ImageBytesNormalizer {
  const ImageBytesNormalizer._();

  static Uint8List forAnalysis(
    Uint8List bytes, {
    int maxSide = 1280,
    int jpegQuality = 85,
  }) {
    final downscaled = ImageDownscaler.downscale(
      bytes,
      maxSide: maxSide,
      jpegQuality: jpegQuality,
    );

    final decoded = _decode(downscaled) ?? _decode(bytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image');
    }

    return Uint8List.fromList(img.encodeJpg(decoded, quality: jpegQuality));
  }

  static img.Image? _decode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      return decoded;
    }

    return img.decodeJpg(bytes) ??
        img.decodePng(bytes) ??
        img.decodeBmp(bytes) ??
        img.decodeGif(bytes);
  }
}