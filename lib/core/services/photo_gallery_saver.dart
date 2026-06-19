import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

import '../../models/captured_photo.dart';

/// Saves captures and exports into the system photo library (iOS Photos / Android Gallery).
abstract final class PhotoGallerySaver {
  static Future<void> saveCapturedPhoto(CapturedPhoto photo) async {
    await _ensureAlbumAccess();

    if (!kIsWeb && photo.path.isNotEmpty) {
      final file = File(photo.path);
      if (await file.exists()) {
        await Gal.putImage(photo.path);
        return;
      }
    }

    await saveJpegBytes(photo.bytes);
  }

  static Future<void> saveJpegBytes(
    Uint8List bytes, {
    String? name,
  }) async {
    await _ensureAlbumAccess();
    final fileName =
        name ?? 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Gal.putImageBytes(bytes, name: fileName);
  }

  static Future<void> savePngBytes(
    Uint8List bytes, {
    String? name,
  }) async {
    await _ensureAlbumAccess();
    final fileName =
        name ?? 'export_${DateTime.now().millisecondsSinceEpoch}.png';
    await Gal.putImageBytes(bytes, name: fileName);
  }

  static Future<void> _ensureAlbumAccess() async {
    if (kIsWeb) {
      throw UnsupportedError('Saving to the photo library is not supported on web.');
    }

    var hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      hasAccess = await Gal.requestAccess(toAlbum: true);
    }
    if (!hasAccess) {
      throw StateError('Photo library access was not granted.');
    }
  }
}