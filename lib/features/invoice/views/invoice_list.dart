import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/core/utils/constants.dart';
import 'package:order_management_flutter_app/features/invoice/views/widgets/invoice_list_item.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/id_formatter.dart';
import '../../order/views/order_detail.dart';
import '../model/invoice_model.dart';
import 'invoice_detail.dart';

class InvoiceList extends StatelessWidget {
  final List<InvoiceModel> invoices;

  const InvoiceList({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool isMobile = Responsive.isMobile(context);
    print(invoices);

    if (invoices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isMobile ? colors.background : colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/4076/4076549.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có hóa đơn nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vui lòng tạo hóa mới để hiển thị ở đây.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? colors.background : colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isMobile ? _buildMobileList() : _buildDataTable(context, colors),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        return InvoiceListItem(invoice: invoices[index]);
      },
    );
  }

  void _showPopupMenu(
      BuildContext context, InvoiceModel invoice, Offset position) async {
    final colors = Theme.of(context).colorScheme;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem<String>(
          value: 'view',
          child: Text(
            "Xem chi tiết hóa đơn",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
    ).then((selectedValue) {
      // Handle the selected value
      if (selectedValue != null) {
        switch (selectedValue) {
          case 'view':
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: InvoiceDetail(
                        invoice: invoice,
                      )),
                );
              },
            );
            break;
        }
      }
    });
  }

  void _showInvoiceDetailDialog(
      BuildContext context, InvoiceModel invoice, OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: OrderDetail(
              order: order,
              invoice: invoice,
            ),
          ),
        );
      },
    );
  }

  String formatDateString(String input) {
    // Assuming input is a Unix timestamp in seconds (e.g., 1744731870)
    int timestamp = int.tryParse(input) ?? 0; // Convert the string to an integer
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // Convert seconds to milliseconds
    DateFormat outputFormat = DateFormat('HH:mm dd/MM/yyyy');
    return outputFormat.format(dateTime);
  }

  Widget _buildDataTable(BuildContext context, ColorScheme colors) {
    return DataTable2(
      columnSpacing: 10,
      horizontalMargin: 10,
      dataRowHeight: 60,
      dividerThickness: 0,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      columns: [
        DataColumn2(
          label: _buildColumnHeader('Thời gian tạo', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Mã hóa đơn', colors),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: _buildColumnHeader('Tổng tiền', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thanh toán', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('đơn hàng', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thao tác', colors),
          size: ColumnSize.S,
        ),
      ],
      rows: invoices.map((invoice) {
        return DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(
                  formatDateString(invoice.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            DataCell(Center(
                child: Text(
              formatIdToBase36WithPrefix(invoice.invoiceCode),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ))),
            DataCell(Center(
                child: Text(
              CurrencyFormatter.format(invoice.total),
              style: const TextStyle(fontSize: 12),
            ))),
            DataCell(
              Center(
                child: _buildStatusCell(invoice.paymentMethod),
              ),
            ),
            DataCell(Center(
                child: GestureDetector(
              onTap: () {
                _showInvoiceDetailDialog(context, invoice, invoice.order);
              },
              child: const Text(
                'Xem chi tiết',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ))),
            DataCell(
              Center(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showPopupMenu(context, invoice, details.globalPosition);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/more.svg',
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusCell(String status) {
    String displayText = '';
    Color backgroundColor = Colors.grey;

    switch (status.toUpperCase()) {
      case 'CASH':
        displayText = 'Tiền mặt';
        backgroundColor = Colors.green;
        break;
      case 'MOBILE_BANKING':
        displayText = 'Chuyển khoản';
        backgroundColor = Colors.blue;
        break;
      default:
        displayText = 'Không xác định';
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: backgroundColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildColumnHeader(String title, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colors.background,
      ),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
