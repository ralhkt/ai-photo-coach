import 'package:ai_photo_coach/core/constants/camera_constants.dart';
import 'package:ai_photo_coach/features/camera/services/camera_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraService.resolutionFor', () {
    test('front camera uses medium preset for faster lens swap', () {
      expect(
        CameraService.resolutionFor(
          const CameraDescription(
            name: 'front',
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 270,
          ),
        ),
        CameraConstants.frontPreviewResolution,
      );
    });

    test('back camera keeps high preset', () {
      expect(
        CameraService.resolutionFor(
          const CameraDescription(
            name: 'back',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ),
        CameraConstants.previewResolution,
      );
    });
  });
}