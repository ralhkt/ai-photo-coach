import 'dart:typed_data';

import '../../../core/services/photo_gallery_saver.dart';

/// Saves skeleton PNG exports to the system photo library.
abstract final class ReferenceSkeletonGallerySaver {
  static Future<void> savePng(Uint8List pngBytes, {String? name}) async {
    final fileName =
        name ?? 'pose_skeleton_${DateTime.now().millisecondsSinceEpoch}.png';
    await PhotoGallerySaver.savePngBytes(pngBytes, name: fileName);
  }
}