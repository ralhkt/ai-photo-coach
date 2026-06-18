import 'package:flutter/material.dart';

import '../../../../core/utils/viewport_letterbox.dart';

/// Clips [child] to a centered crop matching [cropAspectRatio].
///
/// When [cropAspectRatio] is null the child fills the viewport (no letterbox).
/// Areas outside the crop show solid black — the preview is not drawn there.
class LetterboxedCameraViewport extends StatelessWidget {
  const LetterboxedCameraViewport({
    super.key,
    required this.cropAspectRatio,
    required this.child,
  });

  final double? cropAspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (cropAspectRatio == null) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final crop = ViewportLetterbox.cropRectForRatio(
          cropAspectRatio!,
          viewport,
        );

        return ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: crop,
                child: ClipRect(child: child),
              ),
            ],
          ),
        );
      },
    );
  }
}