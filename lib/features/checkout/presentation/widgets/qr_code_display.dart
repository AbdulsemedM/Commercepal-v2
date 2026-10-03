import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import 'package:commercepal/core/design_system.dart';
import 'package:commercepal/services/localization_service.dart';

/// Renders a scannable QR code from raw payload data (e.g. EMVCo QPay string).
///
/// The code is always painted dark-on-white inside a white quiet zone, in
/// both light and dark themes, so every banking-app scanner can read it.
class QrCodeDisplay extends StatelessWidget {
  const QrCodeDisplay({
    super.key,
    required this.data,
    this.size = 240,
  });

  final String data;
  final double size;

  /// Scanners need a light quiet zone; never theme this.
  static const Color _quietZone = Colors.white;
  static const Color _module = Colors.black;

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return _Placeholder(
        size: size,
        child: Icon(
          Icons.qr_code_2_rounded,
          size: size * 0.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      final qrImage = QrImage(qrCode);

      return Semantics(
        image: true,
        label: context.tr('checkout.qpay.qrSemantics'),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: _quietZone,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.commerce.border),
          ),
          child: CustomPaint(
            size: Size(size, size),
            painter: _QrPainter(qrImage),
          ),
        ),
      );
    } catch (_) {
      final ThemeData theme = Theme.of(context);
      return _Placeholder(
        size: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.qr_code_2_rounded,
              size: size * 0.25,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              context.tr('checkout.qpay.qrUnavailable'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}

/// Same footprint as a rendered code so the layout does not jump.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + Spacing.md * 2,
      height: size + Spacing.md * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.commerce.border),
      ),
      child: child,
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.qrImage);

  final QrImage qrImage;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = QrCodeDisplay._module;
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
