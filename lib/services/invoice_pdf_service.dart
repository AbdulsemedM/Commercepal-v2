import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr/qr.dart';
import 'package:commercepal/core/config/env.dart';
import 'package:commercepal/features/orders/data/models/order.dart';
import 'package:commercepal/features/orders/data/models/delivery_address.dart';

/// Generates a downloadable PDF invoice for an order with logo, line items,
/// payment info, and a QR code linking to order tracking.
class InvoicePdfService {
  InvoicePdfService._();

  static const String _logoAssetPath = 'assets/images/logo.png';

  /// Base URL for order tracking (QR code target). Trailing slash optional;
  /// order number will be appended as query or path.
  static String get _trackingBaseUrl {
    try {
      final base = Env.current.baseUrl;
      if (base.isEmpty) return 'https://commercepal.com/order-tracking?orderNumber=';
      if (base.endsWith('/')) return '${base}order-tracking?orderNumber=';
      return '$base/order-tracking?orderNumber=';
    } catch (_) {
      return 'https://commercepal.com/order-tracking?orderNumber=';
    }
  }

  /// Builds the PDF document as bytes.
  static Future<Uint8List> buildPdf({
    required Order order,
    String? paymentReference,
    String? paymentMethodName,
  }) async {
    final pdf = pw.Document();
    final logoBytes = await _loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          _header(logoBytes, order.orderNumber, order.orderDate),
          pw.SizedBox(height: 16),
          _paymentSection(
            paymentReference: paymentReference ?? order.paymentReference,
            paymentMethodName: paymentMethodName,
            paymentStatus: order.paymentStatusLabel,
          ),
          pw.SizedBox(height: 16),
          _itemsTable(order),
          pw.SizedBox(height: 16),
          _totalsSection(order),
          pw.SizedBox(height: 16),
          _deliverySection(order.deliveryAddress),
          pw.SizedBox(height: 20),
          _qrSection(order.orderNumber),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List?> _loadLogo() async {
    try {
      final data = await rootBundle.load(_logoAssetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _header(Uint8List? logoBytes, String orderNumber, String orderDate) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoBytes != null && logoBytes.isNotEmpty)
          pw.Image(
            pw.MemoryImage(logoBytes),
            width: 120,
            height: 48,
            fit: pw.BoxFit.contain,
          )
        else
          pw.Text(
            'CommercePal',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Order #$orderNumber', style: const pw.TextStyle(fontSize: 12)),
            pw.Text(orderDate, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _paymentSection({
    required String? paymentReference,
    required String? paymentMethodName,
    required String paymentStatus,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment details',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (paymentReference != null && paymentReference.isNotEmpty)
            _infoRow('Payment reference', paymentReference),
          if (paymentMethodName != null && paymentMethodName.isNotEmpty)
            _infoRow('Payment method', paymentMethodName),
          _infoRow('Payment status', paymentStatus),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _itemsTable(Order order) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Product', isHeader: true),
            _cell('Qty', isHeader: true),
            _cell('Unit price', isHeader: true),
            _cell('Subtotal', isHeader: true),
          ],
        ),
        for (final item in order.items)
          pw.TableRow(
            children: [
              _cell(
                '${item.productName}${item.productConfiguration.isNotEmpty ? '\n${item.productConfiguration}' : ''}',
              ),
              _cell('${item.quantity}'),
              _cell('${order.currency} ${item.unitPrice.toStringAsFixed(2)}'),
              _cell('${item.currency} ${item.subTotal.toStringAsFixed(2)}'),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  static pw.Widget _totalsSection(Order order) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 180,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _totalRow('Subtotal', order.currency, order.subtotal),
            _totalRow('Total', order.currency, order.totalAmount, isBold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String currency, double amount, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : null)),
          pw.Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : null),
          ),
        ],
      ),
    );
  }

  static pw.Widget _deliverySection(DeliveryAddress addr) {
    final lines = <String>[
      if (addr.fullName.isNotEmpty) addr.fullName,
      if (addr.formattedAddress.isNotEmpty)
        addr.formattedAddress
      else
        [
          addr.streetAddress,
          addr.city,
          addr.subcity,
          addr.region,
          addr.country,
          if ((addr.postalCode).isNotEmpty) addr.postalCode,
        ].where((s) => s.isNotEmpty).join(', '),
      if (addr.phoneNumber.isNotEmpty) 'Tel: ${addr.phoneNumber}',
    ].where((s) => s.isNotEmpty).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Delivery address',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          for (final line in lines)
            pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _qrSection(String orderNumber) {
    final trackingUrl = '$_trackingBaseUrl$orderNumber';
    final qrImage = _buildQrWidget(trackingUrl);

    return pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            'Scan to track your order',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (qrImage != null) qrImage,
          pw.SizedBox(height: 4),
          pw.Text(
            'Order #$orderNumber',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget? _buildQrWidget(String data) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );
      final qrImage = QrImage(qrCode);
      final count = qrImage.moduleCount;
      if (count <= 0) return null;

      const cellSize = 3.0;
      final size = count * cellSize;

      return pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          children: [
            for (int row = 0; row < count; row++)
              for (int col = 0; col < count; col++)
                if (qrImage.isDark(row, col))
                  pw.Positioned(
                    left: col * cellSize,
                    top: row * cellSize,
                    child: pw.Container(
                      width: cellSize,
                      height: cellSize,
                      color: PdfColors.black,
                    ),
                  ),
          ],
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
