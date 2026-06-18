import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;

class MlInputImageHelper {
  static InputImage fromDecodedImage(img.Image image) {
    final rgba = image.convert(numChannels: 4);
    final bytes = Uint8List(rgba.width * rgba.height * 4);

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

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(rgba.width.toDouble(), rgba.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: rgba.width * 4,
      ),
    );
  }
}