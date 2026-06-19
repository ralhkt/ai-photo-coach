import 'dart:typed_data';
import 'dart:ui' as ui;

final referenceImageCache = <String, ui.Image>{};

Future<ui.Image?> decodeReferenceImage(
  Uint8List bytes, {
  int targetWidth = 540,
}) async {
  final key = '$targetWidth:${bytes.length}:${bytes.hashCode}';
  final cached = referenceImageCache[key];
  if (cached != null) {
    return cached;
  }

  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: targetWidth,
  );
  final frame = await codec.getNextFrame();
  referenceImageCache[key] = frame.image;
  return frame.image;
}