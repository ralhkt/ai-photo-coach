import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Payload for ML Kit after JPEG decode + downscale off the UI isolate.
class PreparedMlFrame {
  const PreparedMlFrame({
    required this.width,
    required this.height,
    required this.bgraBytes,
  });

  final int width;
  final int height;
  final Uint8List bgraBytes;
}

const _maxMlSide = 480;

/// Top-level entry for [compute] — must not capture closures.
PreparedMlFrame? preparePreviewFrameForMl(Uint8List jpegBytes) {
  final decoded = img.decodeImage(jpegBytes);
  if (decoded == null) {
    return null;
  }

  final mlImage = _downscaleForMl(decoded);
  final rgba = mlImage.convert(numChannels: 4);
  final byteLength = rgba.width * rgba.height * 4;
  final bytes = Uint8List(byteLength);

  var index = 0;
  for (var y = 0; y < rgba.height; y++) {
    for (var x = 0; x < rgba.width; x++) {
      final pixel = rgba.getPixel(x, y);
      bytes[index++] = pixel.b.toInt();
      bytes[index++] = pixel.g.toInt();
      bytes[index++] = pixel.r.toInt();
      bytes[index++] = pixel.a.toInt();
    }
  }

  return PreparedMlFrame(
    width: rgba.width,
    height: rgba.height,
    bgraBytes: bytes,
  );
}

img.Image _downscaleForMl(img.Image image) {
  final longest = image.width > image.height ? image.width : image.height;
  if (longest <= _maxMlSide) {
    return image;
  }

  final scale = _maxMlSide / longest;
  return img.copyResize(
    image,
    width: (image.width * scale).round(),
    height: (image.height * scale).round(),
    interpolation: img.Interpolation.average,
  );
}