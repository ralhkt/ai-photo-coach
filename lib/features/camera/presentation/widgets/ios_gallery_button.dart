import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'ios_camera_ui_kit.dart';

class IosGalleryButton extends StatelessWidget {
  const IosGalleryButton({
    super.key,
    required this.thumbnailBytes,
    required this.onTap,
    this.onLongPress,
  });

  final Uint8List? thumbnailBytes;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: IosCameraUiKit.gallerySize,
        height: IosCameraUiKit.gallerySize,
        decoration: BoxDecoration(
          color: IosCameraUiKit.galleryFill,
          borderRadius: BorderRadius.circular(IosCameraUiKit.galleryRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: IosCameraUiKit.galleryBorderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: thumbnailBytes != null
            ? Image.memory(thumbnailBytes!, fit: BoxFit.cover)
            : Icon(
                Icons.photo_outlined,
                color: IosCameraUiKit.textSecondary,
                size: 24,
              ),
      ),
    );
  }
}