import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/captured_photo.dart';

final lastCaptureProvider = StateProvider<CapturedPhoto?>((ref) => null);

/// Small JPEG for the gallery chip — avoids decoding full captures on every rebuild.
final lastCaptureThumbnailProvider = StateProvider<Uint8List?>((ref) => null);

final flashModeProvider = StateProvider<FlashMode>((ref) => FlashMode.auto);

final isCapturingProvider = StateProvider<bool>((ref) => false);

/// True while grabbing a silent preview frame for ML — does not flash camera UI.
final isPreviewSamplingProvider = StateProvider<bool>((ref) => false);

final cameraSwitchingProvider = StateProvider<bool>((ref) => false);

final captureFlashProvider = StateProvider<bool>((ref) => false);