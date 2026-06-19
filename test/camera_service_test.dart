import 'package:ai_photo_coach/core/constants/camera_constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preview uses max resolution for native-like sharpness', () {
    expect(CameraConstants.previewResolution, ResolutionPreset.max);
  });
}