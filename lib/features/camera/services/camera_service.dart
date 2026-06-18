import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  static Future<List<CameraDescription>> listCameras() {
    return availableCameras();
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async {
    return Permission.camera.isGranted;
  }

  Future<CameraController> initialize(
    CameraDescription camera, {
    FlashMode flashMode = FlashMode.auto,
  }) async {
    await dispose();

    final hasAccess = await hasPermission() || await requestPermission();
    if (!hasAccess) {
      throw CameraException(
        'permission_denied',
        'Camera permission was not granted.',
      );
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    if (controller.value.isInitialized) {
      try {
        await controller.setFlashMode(flashMode);
      } catch (_) {
        await controller.setFlashMode(FlashMode.off);
      }
    }

    _controller = controller;
    return controller;
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }
}