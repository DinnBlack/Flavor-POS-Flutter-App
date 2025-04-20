import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../model/invoice_model.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';

class InvoiceDetail extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetail({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrow_left.svg',
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Hóa đơn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (!Responsive.isMobile(context)) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildActionButton(
                        icon: Icons.download,
                        label: 'Tải xuống',
                        onPressed: () async {
                          final pdf = await generatePdf(invoice);
                          await Printing.sharePdf(
                            bytes: pdf,
                            filename: 'invoice_${invoice.invoiceCode}.pdf',
                          );
                        },
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.print,
                      label: 'In',
                      onPressed: () async {
                        final pdf = await generatePdf(invoice);
                        await Printing.layoutPdf(onLayout: (_) => pdf);
                      },
                    ),
                  ]
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: PdfPreview(
                      build: (format) => generatePdf(invoice),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Future<Uint8List> generatePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();
    final imageLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
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
              // Title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(imageLogo),
                  ),
                  pw.Text(
                    'HÓA ĐƠN BÁN HÀNG',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: boldFont,
                    ),
                  ),
                  pw.SizedBox(width: 80),
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mã hóa đơn: ${invoice.invoiceCode}',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text('Ngày tạo: ${invoice.createdAt}',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Thu ngân: ${invoice.cashierName}',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text('Thanh toán: ${invoice.paymentMethod}',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Order detail title
              pw.Text(
                'Chi tiết đơn hàng:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
              pw.SizedBox(height: 8),

              // Table
              pw.Table.fromTextArray(
                headers: ['Món', 'SL', 'Đơn giá', 'Ghi chú', 'Thành tiền'],
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(font: font, fontSize: 11),
                cellAlignment: pw.Alignment.centerLeft,
                data: invoice.order.orderItems.map((item) {
                  return [
                    item.dishName,
                    item.quantity.toString(),
                    CurrencyFormatter.format(item.dishPrice),
                    item.note.isEmpty ? '-' : item.note,
                    CurrencyFormatter.format(item.dishPrice * item.quantity),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),

              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _buildAmountRow(
                          'Tổng tiền',
                          CurrencyFormatter.format(invoice.total),
                          font,
                          boldFont),
                      _buildAmountRow(
                          'Tiền khách đưa',
                          CurrencyFormatter.format(invoice.amountGiven),
                          font,
                          boldFont),
                      _buildAmountRow(
                          'Tiền thối lại',
                          CurrencyFormatter.format(invoice.changeAmount),
                          font,
                          boldFont),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // Thank you
              pw.Center(
                child: pw.Text(
                  'Cảm ơn quý khách!',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    font: italicFont,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildAmountRow(
      String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
