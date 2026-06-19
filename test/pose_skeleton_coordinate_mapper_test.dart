import 'dart:ui';

import 'package:ai_photo_coach/features/pose/presentation/pose_skeleton_coordinate_mapper.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

void main() {
  test('cover-fit maps image center to crop center', () {
    const mapper = PoseSkeletonCoordinateMapper(
      imageSize: Size(480, 640),
      previewSize: Size(390, 520),
      cropRect: Rect.fromLTWH(0, 40, 390, 440),
    );

    final mapped = mapper.mapNormalized(const Offset(0.5, 0.5));
    expect(mapped.dx, closeTo(195, 1));
    expect(mapped.dy, closeTo(260, 1));
  });

  test('front camera mirror flips horizontal axis', () {
    const mapper = PoseSkeletonCoordinateMapper(
      imageSize: Size(480, 640),
      previewSize: Size(300, 400),
      isFrontCamera: true,
      mirrorFront: true,
    );

    final left = mapper.mapNormalized(const Offset(0.2, 0.5));
    final right = mapper.mapNormalized(const Offset(0.8, 0.5));
    expect(left.dx, greaterThan(right.dx));
  });

  test('rotation90deg maps landscape-normalized point into portrait preview', () {
    const mapper = PoseSkeletonCoordinateMapper(
      imageSize: Size(640, 480),
      previewSize: Size(300, 400),
      rotation: InputImageRotation.rotation90deg,
    );

    final mapped = mapper.mapNormalized(const Offset(0.5, 0.2));
    expect(mapped.dx, inInclusiveRange(0, 300));
    expect(mapped.dy, inInclusiveRange(0, 400));
  });

  test('fromCamera wires lens direction into mirroring', () {
    final mapper = PoseSkeletonCoordinateMapper.fromCamera(
      imageSize: const Size(480, 640),
      previewSize: const Size(300, 400),
      lensDirection: CameraLensDirection.front,
      mirrorFront: false,
    );

    final a = mapper.mapNormalized(const Offset(0.25, 0.5));
    final b = mapper.mapNormalized(const Offset(0.75, 0.5));
    expect(a.dx, lessThan(b.dx));
  });
}