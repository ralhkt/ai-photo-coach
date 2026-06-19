import 'package:ai_photo_coach/features/camera/presentation/camera_shell_mode.dart';
import 'package:ai_photo_coach/models/shoot_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('carousel index maps video, photo, guided', () {
    expect(CameraShellMode.video.carouselIndex, 0);
    expect(CameraShellMode.photo.carouselIndex, 1);
    expect(CameraShellMode.guided.carouselIndex, 2);
    expect(CameraShellMode.fromCarouselIndex(0), CameraShellMode.video);
    expect(CameraShellMode.fromCarouselIndex(1), CameraShellMode.photo);
    expect(CameraShellMode.fromCarouselIndex(2), CameraShellMode.guided);
  });

  test('shoot session mode maps to shell mode', () {
    expect(
      CameraShellMode.fromShootSession(ShootSessionMode.free),
      CameraShellMode.photo,
    );
    expect(
      CameraShellMode.fromShootSession(ShootSessionMode.guided),
      CameraShellMode.guided,
    );
    expect(CameraShellMode.fromShootSession(null), CameraShellMode.photo);
  });
}