import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS-only tap of the shared AVCaptureSession video output (no takePicture).
class NativePreviewFrameService {
  NativePreviewFrameService._();

  static final NativePreviewFrameService instance = NativePreviewFrameService._();

  static const _channel = MethodChannel('com.aiphotocoach.app/preview_frame_sampler');

  bool? _supported;

  bool get isSupported {
    if (kIsWeb || !Platform.isIOS) {
      return false;
    }
    return true;
  }

  Future<void> attach() async {
    if (!isSupported) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('attach');
      _supported = true;
    } catch (error) {
      debugPrint('NativePreviewFrameService.attach failed: $error');
      _supported = false;
    }
  }

  Future<void> detach() async {
    if (!isSupported) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('detach');
    } catch (error) {
      debugPrint('NativePreviewFrameService.detach failed: $error');
    }
  }

  Future<Uint8List?> latestJpeg() async {
    if (!isSupported || _supported == false) {
      return null;
    }
    try {
      final data = await _channel.invokeMethod<Uint8List>('latestJpeg');
      if (data == null || data.isEmpty) {
        return null;
      }
      return data;
    } catch (error) {
      debugPrint('NativePreviewFrameService.latestJpeg failed: $error');
      return null;
    }
  }
}