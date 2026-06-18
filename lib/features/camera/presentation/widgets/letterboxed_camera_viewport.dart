import 'package:flutter/material.dart';

/// Clips [child] to a centered crop matching [cropAspectRatio] (iPhone-style).
///
/// When [cropAspectRatio] is null the child fills the viewport (no letterbox).
class LetterboxedCameraViewport extends StatelessWidget {
  const LetterboxedCameraViewport({
    super.key,
    required this.cropAspectRatio,
    required this.child,
  });

  /// Visible region width÷height.
  final double? cropAspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (cropAspectRatio == null) {
      return child;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: cropAspectRatio!,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
  }
}