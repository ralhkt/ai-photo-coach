import 'dart:typed_data';

import 'package:ai_photo_coach/features/reference/services/vision_request_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('bytesForVisionRequest downscales large images', () {
    final image = img.Image(width: 2400, height: 3200);
    final original = Uint8List.fromList(img.encodeJpg(image));

    final resized = bytesForVisionRequest(original, maxSide: 768);
    final decoded = img.decodeJpg(resized);

    expect(decoded, isNotNull);
    expect(
      decoded!.width > decoded.height ? decoded.width : decoded.height,
      lessThanOrEqualTo(768),
    );
  });
}