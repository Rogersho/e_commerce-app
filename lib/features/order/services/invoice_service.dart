import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ecommerce_poco/features/order/domain/order.dart'
    as order_domain; // Ensure Order model exists and is exported
import 'package:ecommerce_poco/features/auth/domain/profile.dart'; // Ensure Profile model exists

class InvoiceService {
  Future<Uint8List> generateInvoice(
    order_domain.Order order,
    Profile? profile,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(order),
              pw.SizedBox(height: 20),
              _buildCustomerInfo(order, profile),
              pw.SizedBox(height: 20),
              _buildOrderTable(order),
              pw.Divider(),
              _buildTotal(order),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(order_domain.Order order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Order #${order.id}'),
            pw.Text('Date: ${order.createdAt.toString().split(' ')[0]}'),
            pw.Text('Status: ${order.status.toUpperCase()}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerInfo(order_domain.Order order, Profile? profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bill To:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(profile?.fullName ?? 'Customer'),
        pw.Text(profile?.address ?? 'No Address'),
        if (order.phoneNumber != null) pw.Text('Phone: ${order.phoneNumber}'),
        if (order.shippingAddress != null)
          pw.Text('Shipping Address: ${order.shippingAddress.toString()}'),
      ],
    );
  }

  pw.Widget _buildOrderTable(order_domain.Order order) {
    // Note: Assuming `order.items` is populated. If OrderModel doesn't have items directly, we might need to adjust.
    // For now, I'll assume we pass a robust Order object or fetch items separately.
    // If OrderModel doesn't have items, we'll need to fetch them.
    // Let's assume for this step that we simply list what we have.

    // Header
    final headers = ['Product', 'Qty', 'Price', 'Total'];

    // Data
    final data =
        order.items?.map((item) {
          return [
            item.product?.name ?? 'Product ${item.productId}',
            '${item.quantity}',
            '\$${item.price.toStringAsFixed(2)}',
            '\$${(item.quantity * item.price).toStringAsFixed(2)}',
          ];
        }).toList() ??
        [];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotal(order_domain.Order order) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            'TOTAL AMOUNT:  ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '\$${order.totalAmount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Text(
        'Thank you for shopping with ShopSphere!',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
      ),
    );
  }
}
