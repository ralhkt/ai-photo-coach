import 'dart:typed_data';

import 'package:flutter/material.dart';

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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: thumbnailBytes != null
            ? Image.memory(thumbnailBytes!, fit: BoxFit.cover)
            : Icon(
                Icons.photo_outlined,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
      ),
    );
  }
}