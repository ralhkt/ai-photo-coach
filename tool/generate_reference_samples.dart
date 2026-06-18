import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates bundled reference sample JPEGs for the in-app picker.
void main() {
  final outDir = Directory('assets/reference_samples');
  outDir.createSync(recursive: true);

  _writePortrait(
    path: '${outDir.path}/portrait_classic.jpg',
    width: 900,
    height: 1200,
    bg: const [32, 38, 52],
    skin: const [212, 178, 158],
    subject: const RectSpec(0.34, 0.14, 0.32, 0.72),
  );

  _writePortrait(
    path: '${outDir.path}/portrait_story.jpg',
    width: 720,
    height: 1280,
    bg: const [18, 20, 28],
    skin: const [205, 170, 150],
    subject: const RectSpec(0.30, 0.10, 0.40, 0.78),
  );

  _writePortrait(
    path: '${outDir.path}/portrait_square.jpg',
    width: 1080,
    height: 1080,
    bg: const [42, 46, 58],
    skin: const [218, 182, 162],
    subject: const RectSpec(0.32, 0.12, 0.36, 0.76),
  );

  _writeLifestyle(
    path: '${outDir.path}/lifestyle_cafe.jpg',
    width: 1200,
    height: 900,
    bg: const [48, 40, 34],
    accent: const [88, 62, 44],
    subject: const RectSpec(0.58, 0.18, 0.22, 0.55),
  );

  stdout.writeln('Generated ${outDir.path}');
}

class RectSpec {
  const RectSpec(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

void _writePortrait({
  required String path,
  required int width,
  required int height,
  required List<int> bg,
  required List<int> skin,
  required RectSpec subject,
}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(x, y, bg[0], bg[1], bg[2]);
    }
  }

  final left = (subject.left * width).round();
  final top = (subject.top * height).round();
  final sw = (subject.width * width).round();
  final sh = (subject.height * height).round();

  _fillEllipse(image, left + sw ~/ 2, top + (sh * 0.12).round(), sw ~/ 3, (sh * 0.11).round(), skin);
  _fillRoundedBody(image, left, top + (sh * 0.18).round(), sw, sh - (sh * 0.18).round(), skin);

  File(path).writeAsBytesSync(img.encodeJpg(image, quality: 92));
}

void _writeLifestyle({
  required String path,
  required int width,
  required int height,
  required List<int> bg,
  required List<int> accent,
  required RectSpec subject,
}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final warm = (x / width * 18).round();
      image.setPixelRgb(
        x,
        y,
        (bg[0] + warm).clamp(0, 255),
        (bg[1] + warm ~/ 2).clamp(0, 255),
        bg[2],
      );
    }
  }

  for (var x = 0; x < width; x++) {
    for (var y = (height * 0.62).round(); y < height; y++) {
      image.setPixelRgb(x, y, accent[0], accent[1], accent[2]);
    }
  }

  final left = (subject.left * width).round();
  final top = (subject.top * height).round();
  final sw = (subject.width * width).round();
  final sh = (subject.height * height).round();
  _fillRoundedBody(
    image,
    left,
    top,
    sw,
    sh,
    const [210, 176, 156],
  );

  File(path).writeAsBytesSync(img.encodeJpg(image, quality: 92));
}

void _fillEllipse(
  img.Image image,
  int cx,
  int cy,
  int rx,
  int ry,
  List<int> color,
) {
  for (var y = cy - ry; y <= cy + ry; y++) {
    for (var x = cx - rx; x <= cx + rx; x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) {
        continue;
      }
      final nx = (x - cx) / rx;
      final ny = (y - cy) / ry;
      if (nx * nx + ny * ny <= 1) {
        image.setPixelRgb(x, y, color[0], color[1], color[2]);
      }
    }
  }
}

void _fillRoundedBody(
  img.Image image,
  int left,
  int top,
  int width,
  int height,
  List<int> color,
) {
  for (var y = top; y < top + height && y < image.height; y++) {
    for (var x = left; x < left + width && x < image.width; x++) {
      final t = (y - top) / height;
      final taper = 1 - (t - 0.55).clamp(0.0, 1.0) * 0.35;
      final half = width * taper / 2;
      final cx = left + width / 2;
      if ((x - cx).abs() <= half) {
        image.setPixelRgb(x, y, color[0], color[1], color[2]);
      }
    }
  }
}