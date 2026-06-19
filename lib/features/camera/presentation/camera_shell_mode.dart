import '../../../models/shoot_session.dart';

/// Shell modes exposed in the native Camera mode carousel.
enum CameraShellMode {
  video,
  photo,
  guided;

  /// Carousel order: 錄影 (0) · 影相 (1) · 引導 (2).
  int get carouselIndex => switch (this) {
        CameraShellMode.video => 0,
        CameraShellMode.photo => 1,
        CameraShellMode.guided => 2,
      };

  static CameraShellMode fromCarouselIndex(int index) {
    return switch (index) {
      0 => CameraShellMode.video,
      1 => CameraShellMode.photo,
      _ => CameraShellMode.guided,
    };
  }

  static CameraShellMode fromShootSession(ShootSessionMode? mode) {
    return mode == ShootSessionMode.guided
        ? CameraShellMode.guided
        : CameraShellMode.photo;
  }
}