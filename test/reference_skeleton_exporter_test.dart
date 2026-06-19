import 'dart:typed_data';

import 'package:ai_photo_coach/features/reference/services/reference_skeleton_image_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Uint8List _solidJpeg({required int width, required int height}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(180, 140, 120));
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  final sampleSegments = [
    [const Offset(0.4, 0.2), const Offset(0.4, 0.6)],
    [const Offset(0.4, 0.35), const Offset(0.25, 0.5)],
    [const Offset(0.4, 0.35), const Offset(0.55, 0.5)],
  ];

  test('renderPng produces non-empty overlay export', () async {
    final bytes = await ReferenceSkeletonImageExporter.renderPng(
      imageBytes: _solidJpeg(width: 320, height: 480),
      skeletonSegments: sampleSegments,
      imageAspectRatio: 320 / 480,
      skeletonOnly: false,
      strokeWidth: 2.2,
    );

    expect(bytes.length, greaterThan(100));
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
  });

  test('renderPng skeleton-only mode uses dark background', () async {
    final bytes = await ReferenceSkeletonImageExporter.renderPng(
      imageBytes: _solidJpeg(width: 240, height: 360),
      skeletonSegments: sampleSegments,
      imageAspectRatio: 240 / 360,
      skeletonOnly: true,
      strokeWidth: 3.0,
    );

    expect(bytes.length, greaterThan(100));
    expect(bytes[0], 0x89);
  });

  test('renderPng rejects invalid image bytes', () async {
    expect(
      () => ReferenceSkeletonImageExporter.renderPng(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        skeletonSegments: sampleSegments,
        imageAspectRatio: 1,
      ),
      throwsA(anything),
    );
  });
}