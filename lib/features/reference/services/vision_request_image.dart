import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Downscales image bytes before sending to cloud vision APIs.
Uint8List bytesForVisionRequest(
  Uint8List bytes, {
  int maxSide = 768,
  int jpegQuality = 80,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return bytes;
  }

  final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
  if (longest <= maxSide) {
    return Uint8List.fromList(img.encodeJpg(decoded, quality: jpegQuality));
  }

  final scale = maxSide / longest;
  final resized = img.copyResize(
    decoded,
    width: (decoded.width * scale).round(),
    height: (decoded.height * scale).round(),
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
}