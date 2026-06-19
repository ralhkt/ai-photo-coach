import 'package:ai_photo_coach/core/constants/camera_constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preview uses high resolution to balance sharpness and capture load', () {
    expect(CameraConstants.previewResolution, ResolutionPreset.high);
  });
}