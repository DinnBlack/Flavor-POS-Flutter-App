import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../order/model/order_detail_model.dart';
import '../../../order/model/order_model.dart';
import '../../model/invoice_model.dart';

class InvoiceDetail extends StatelessWidget {
  const InvoiceDetail({super.key});

  @override
  Widget build(BuildContext context) {
    const invoice = InvoiceModel(
      id: '1',
      invoiceCode: 'HD001',
      total: 65000,
      amountGiven: 70000,
      changeAmount: 5000,
      paymentMethod: 'Tiền mặt',
      cashierName: 'Nguyễn Văn B',
      createdAt: '09/04/2025 14:30',
      order: OrderModel(
        id: 'order001',
        tableNumber: 5,
        status: 'Hoàn tất',
        total: 65000,
        createdAt: '09/04/2025 14:15',
        orderItems: [
          OrderDetailModel(
            quantity: 2,
            dishName: 'Cà phê sữa',
            dishPrice: 20000,
            note: 'Ít đá',
          ),
          OrderDetailModel(
            quantity: 1,
            dishName: 'Trà đào',
            dishPrice: 25000,
            note: '',
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Hóa đơn mẫu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final pdf = await generatePdf(invoice);
              await Printing.sharePdf(
                  bytes: pdf, filename: 'invoice_${invoice.invoiceCode}.pdf');
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdf = await generatePdf(invoice);
              await Printing.layoutPdf(onLayout: (_) => pdf);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => generatePdf(invoice),
      ),
    );
  }

  Future<Uint8List> generatePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    // Load Roboto font hỗ trợ tiếng Việt
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'HÓA ĐƠN BÁN HÀNG',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: boldFont),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Mã hóa đơn: ${invoice.invoiceCode}',
                  style: pw.TextStyle(font: font)),
              pw.Text('Ngày tạo: ${invoice.createdAt}',
                  style: pw.TextStyle(font: font)),
              pw.Text('Thu ngân: ${invoice.cashierName}',
                  style: pw.TextStyle(font: font)),
              pw.Text('Phương thức thanh toán: ${invoice.paymentMethod}',
                  style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 16),
              pw.Text(
                'Chi tiết đơn hàng:',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Món', 'SL', 'Đơn giá', 'Ghi chú', 'Thành tiền'],
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, font: boldFont),
                cellStyle: pw.TextStyle(font: font),
                data: invoice.order.orderItems.map((item) {
                  return [
                    item.dishName,
                    item.quantity.toString(),
                    '${item.dishPrice.toStringAsFixed(0)}đ',
                    item.note.isEmpty ? '-' : item.note,
                    '${(item.dishPrice * item.quantity).toStringAsFixed(0)}đ',
                  ];
                }).toList(),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Tổng tiền: ${invoice.total}đ',
                        style: pw.TextStyle(font: font)),
                    pw.Text('Tiền khách đưa: ${invoice.amountGiven}đ',
                        style: pw.TextStyle(font: font)),
                    pw.Text('Tiền thối lại: ${invoice.changeAmount}đ',
                        style: pw.TextStyle(font: font)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text(
                  'Cảm ơn quý khách!',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontStyle: pw.FontStyle.italic,
                      font: italicFont),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
