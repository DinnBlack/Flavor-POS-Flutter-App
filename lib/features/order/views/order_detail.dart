import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/features/invoice/model/invoice_model.dart';

import '../../../core/utils/id_formatter.dart';
import '../../../core/widgets/dash_divider.dart';
import '../model/order_model.dart';

class OrderDetail extends StatelessWidget {
  final OrderModel order;
  final InvoiceModel? invoice;

  const OrderDetail({super.key, required this.order, this.invoice});

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}₫';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }


  Widget _comboItemsTile() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        'Món ăn',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${order.orderItems.length}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      children: order.orderItems
          .map((item) => Column(
                children: [
                  const DashDivider(),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity),
                    title: Text('${item.quantity} x ${item.dishName}'),
                    subtitle: item.note.isNotEmpty
                        ? Text('Ghi chú: ${item.note}')
                        : null,
                    trailing: Text(_formatCurrency(item.dishPrice)),
                  ),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildStatusCell(String status) {
    String displayText = '';
    Color backgroundColor = Colors.grey;

    switch (status.toUpperCase()) {
      case 'REJECTED':
        displayText = 'Đã hủy';
        backgroundColor = Colors.red;
        break;
      case 'APPROVED':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.blue;
        break;
      case 'READY_TO_DELIVER':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.blue;
        break;
      case 'DELIVERED':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.blue;
        break;
      case 'PENDING':
        displayText = 'Chờ xác nhận';
        backgroundColor = Colors.amber;
        break;
      case 'PAID':
        displayText = 'Hoàn thành';
        backgroundColor = Colors.green;
        break;
      default:
        displayText = 'Không xác định';
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _paymentInfoTile() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        'Thông tin thanh toán',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        _formatCurrency(order.total),
        style: const TextStyle(fontSize: 16),
      ),
      children: [
        const DashDivider(),
        if (invoice != null) ...[
          _infoRow('Hình thức thanh toán', invoice!.paymentMethod == 'CASH' ? 'Tiền mặt': 'Chuyển khoản'),
          _infoRow('Tiền khách đưa', CurrencyFormatter.format(invoice!.amountGiven)),
          _infoRow('Tiền trả khách', CurrencyFormatter.format(invoice!.changeAmount)),
        ] else ...[
          _infoRow('Hình thức thanh toán', 'Chưa thanh toán'),
          _infoRow('Tiền khách đưa', '0₫'),
          _infoRow('Tiền trả khách', '0₫'),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Thông tin đơn hàng'),
                Text('#${formatIdToBase36Short( order.id)}', style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            _comboItemsTile(),
            _paymentInfoTile(),
            _sectionTitle('Thông tin giao dịch'),
            _infoRow(
              'Mã tham chiếu:',
              invoice != null ? formatIdToBase36WithPrefix(invoice!.invoiceCode) : 'Chưa thanh toán',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trạng thái đơn hàng:'),
                _buildStatusCell(order.status),
              ],
            ),
            _infoRow(
                'Hình thức phục vụ:', 'Ăn tại bàn (Bàn ${order.tableNumber})'),
            _infoRow('Thông tin khách hàng:', 'Khách lẻ'),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(elevation: 0),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
