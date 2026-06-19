import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageDownscaler {
  const ImageDownscaler._();

  static Uint8List downscale(
    Uint8List bytes, {
    int maxSide = 512,
    int jpegQuality = 82,
  }) {
    return _downscaleOnMain(bytes, maxSide: maxSide, jpegQuality: jpegQuality);
  }

  static Future<Uint8List> downscaleAsync(
    Uint8List bytes, {
    int maxSide = 512,
    int jpegQuality = 82,
  }) {
    return compute(
      _downscaleIsolate,
      _DownscaleParams(bytes, maxSide, jpegQuality),
    );
  }

  static Uint8List _downscaleOnMain(
    Uint8List bytes, {
    required int maxSide,
    required int jpegQuality,
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

class _DownscaleParams {
  const _DownscaleParams(this.bytes, this.maxSide, this.jpegQuality);

  final Uint8List bytes;
  final int maxSide;
  final int jpegQuality;
}

Uint8List _downscaleIsolate(_DownscaleParams params) {
  return ImageDownscaler._downscaleOnMain(
    params.bytes,
    maxSide: params.maxSide,
    jpegQuality: params.jpegQuality,
  );
}