import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageDownscaler {
  const ImageDownscaler._();

  static Uint8List downscale(
    Uint8List bytes, {
    int maxSide = 512,
    int jpegQuality = 82,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    final longest = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    if (longest <= maxSide) {
      return bytes;
    }

    final scale = maxSide / longest;
    final resized = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
  }
}