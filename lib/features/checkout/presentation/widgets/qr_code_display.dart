import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Renders a scannable QR code from raw payload data (e.g. EMVCo QPay string).
class QrCodeDisplay extends StatelessWidget {
  const QrCodeDisplay({
    super.key,
    required this.data,
    this.size = 240,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.qr_code_2_rounded,
          size: size * 0.4,
          color: Colors.grey.shade400,
        ),
      );
    }

    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      final qrImage = QrImage(qrCode);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _QrPainter(qrImage),
        ),
      );
    } catch (_) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'QR unavailable',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.qrImage);

  final QrImage qrImage;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final moduleCount = qrImage.moduleCount;
    if (moduleCount <= 0) return;

    final moduleSize = size.width / moduleCount;
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * moduleSize,
              row * moduleSize,
              moduleSize,
              moduleSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.qrImage != qrImage;
}
