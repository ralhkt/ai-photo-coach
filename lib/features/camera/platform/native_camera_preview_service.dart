import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native iOS `AVCaptureVideoPreviewLayer` preview (PR-6).
///
/// Pauses the Flutter texture preview and renders via PlatformView for
/// native Camera-app sharpness.
class NativeCameraPreviewService {
  NativeCameraPreviewService._();

  static final NativeCameraPreviewService instance =
      NativeCameraPreviewService._();

  static const platformViewType = 'com.aiphotocoach.app/native_camera_preview';

  static const _channel = MethodChannel('com.aiphotocoach.app/native_camera_preview');

  bool? _supported;

  Future<bool> isSupported() async {
    if (!kIsWeb && Platform.isIOS) {
      _supported ??= await _channel.invokeMethod<bool>('isSupported') ?? false;
      return _supported!;
    }
    return false;
  }

  Future<void> updateSettings({
    required bool mirrorFront,
    required String lensDirection,
  }) async {
    if (!await isSupported()) {
      return;
    }
    await _channel.invokeMethod<void>('updateSettings', {
      'mirrorFront': mirrorFront,
      'lensDirection': lensDirection,
    });
  }
}