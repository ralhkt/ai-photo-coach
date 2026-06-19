import 'package:ai_photo_coach/features/camera/providers/camera_providers.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cameras = [
    const CameraDescription(
      name: 'back_wide',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
    const CameraDescription(
      name: 'back_ultra',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
    const CameraDescription(
      name: 'front',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 270,
    ),
  ];

  group('oppositeCameraIndex', () {
    test('back switches to front', () {
      expect(
        oppositeCameraIndex(cameras: cameras, currentIndex: 0),
        2,
      );
    });

    test('front switches to first back camera', () {
      expect(
        oppositeCameraIndex(cameras: cameras, currentIndex: 2),
        0,
      );
    });

    test('does not cycle through all back lenses', () {
      expect(
        oppositeCameraIndex(cameras: cameras, currentIndex: 0),
        isNot(1),
      );
    });
  });

  group('flashModeForLens', () {
    test('torch is cleared when switching to front camera', () {
      expect(
        flashModeForLens(FlashMode.torch, CameraLensDirection.front),
        FlashMode.off,
      );
    });

    test('torch is kept on back camera', () {
      expect(
        flashModeForLens(FlashMode.torch, CameraLensDirection.back),
        FlashMode.torch,
      );
    });
  });
}