import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

/// 將骨架 PNG 儲存至系統相簿。
abstract final class ReferenceSkeletonGallerySaver {
  static Future<void> savePng(Uint8List pngBytes, {String? name}) async {
    if (kIsWeb) {
      throw UnsupportedError('網頁版暫不支援儲存至相簿');
    }

    final granted = await _ensureGalleryAccess();
    if (!granted) {
      throw StateError('未取得相簿寫入權限');
    }

    final fileName =
        name ?? 'pose_skeleton_${DateTime.now().millisecondsSinceEpoch}.png';
    await Gal.putImageBytes(pngBytes, name: fileName);
  }

  static Future<bool> _ensureGalleryAccess() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final addOnly = await Permission.photosAddOnly.request();
      if (addOnly.isGranted || addOnly.isLimited) {
        return true;
      }
      final photos = await Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) {
        return true;
      }
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    return true;
  }
}