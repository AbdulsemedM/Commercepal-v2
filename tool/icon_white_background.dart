// Run with: dart run tool/icon_white_background.dart
// Creates assets/images/Icon_ios_white.png with black/dark pixels replaced by white
// so iOS app icon shows white background when using flutter_launcher_icons.

import 'dart:io';

import 'package:image/image.dart' as img;

void main() async {
  final projectRoot = Directory.current;
  if (projectRoot.path.endsWith('tool')) {
    Directory.current = projectRoot.parent;
  }
  final inputPath = 'assets/images/Icon.png';
  final outputPath = 'assets/images/Icon_ios_white.png';
  final file = File(inputPath);
  if (!file.existsSync()) {
    print('Error: $inputPath not found');
    exit(1);
  }
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Error: could not decode $inputPath');
    exit(1);
  }
  // Replace transparent pixels and very dark (black) pixels with white
  const threshold = 30; // treat r,g,b all <= threshold as background
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final a = pixel.a.toInt();
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final isTransparent = a < 128;
      final isBlackOrDark = r <= threshold && g <= threshold && b <= threshold;
      if (isTransparent || isBlackOrDark) {
        image.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
      }
    }
  }
  final outFile = File(outputPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsBytes(img.encodePng(image));
  print('Wrote $outputPath (white background for iOS icon).');
}
