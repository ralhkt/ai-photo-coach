import 'dart:typed_data';

class CapturedPhoto {
  const CapturedPhoto({
    required this.path,
    required this.bytes,
    required this.capturedAt,
  });

  final String path;
  final Uint8List bytes;
  final DateTime capturedAt;
}