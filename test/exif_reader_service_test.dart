import 'dart:typed_data';

import 'package:ai_photo_coach/features/reference/services/exif_reader_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns empty metadata for non-jpeg bytes', () async {
    const service = ExifReaderService();
    final meta = await service.read(Uint8List.fromList([1, 2, 3]));
    expect(meta.hasAny, isFalse);
  });
}