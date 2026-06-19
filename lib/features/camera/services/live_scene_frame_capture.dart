import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preview_capture_request.dart';
import '../platform/native_preview_frame_service.dart';
import '../providers/camera_providers.dart';

/// Captures a preview JPEG for live scene analysis.
Future<Uint8List?> captureLiveSceneFrame(
  Ref ref, {
  PreviewCaptureRequest request = const PreviewCaptureRequest(),
}) async {
  // Manual ✨ analyze: takePicture immediately — native sampler needs ~5s warmup.
  if (request.forceCapture) {
    return ref
        .read(cameraControllerProvider.notifier)
        .capturePreviewFrame(request);
  }

  if (!kIsWeb && Platform.isIOS && NativePreviewFrameService.instance.isSupported) {
    final native = await _captureViaNativeSampler();
    if (native != null && native.isNotEmpty) {
      return native;
    }
  }

  return ref
      .read(cameraControllerProvider.notifier)
      .capturePreviewFrame(request);
}

Future<Uint8List?> _captureViaNativeSampler() async {
  final service = NativePreviewFrameService.instance;
  await service.attach();

  try {
    for (var attempt = 0; attempt < 14; attempt++) {
      final bytes = await service.latestJpeg();
      if (bytes != null && bytes.isNotEmpty) {
        return bytes;
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    return null;
  } finally {
    await service.detach();
  }
}