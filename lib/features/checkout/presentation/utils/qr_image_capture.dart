import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// Captures a [RepaintBoundary] widget as a high-resolution PNG and saves it
/// to the device photo gallery via [Gal.putImage].
Future<void> captureAndSaveQrToGallery({
  required GlobalKey boundaryKey,
  double pixelRatio = 3.0,
}) async {
  final RenderRepaintBoundary? boundary = boundaryKey.currentContext
      ?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('QR capture boundary is not ready');
  }

  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (byteData == null) {
    throw StateError('Failed to encode QR image');
  }

  final Directory tempDir = await getTemporaryDirectory();
  final String filePath =
      '${tempDir.path}/qpay_qr_${DateTime.now().millisecondsSinceEpoch}.png';
  final File file = File(filePath);
  await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

  try {
    await Gal.putImage(filePath);
  } finally {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
