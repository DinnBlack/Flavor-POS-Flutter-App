import 'package:flutter/material.dart';

import '../../../core/utils/id_formatter.dart';
import '../../../core/widgets/dash_divider.dart';
import '../model/order_model.dart';

class OrderDetail extends StatelessWidget {
  final OrderModel order;

  const OrderDetail({super.key, required this.order});

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}₫';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusRow(String status) {
    String statusText;
    Color backgroundColor;
    Color textColor;

    // Determine the status text and colors
    switch (status) {
      case 'PENDING':
        statusText = 'Chờ xử lý';
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'READY_TO_DELIVER':
        statusText = 'Sẵn sàng giao hàng';
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'DELIVERED':
        statusText = 'Đã giao';
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'APPROVED':
        statusText = 'Đã duyệt';
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      default:
        statusText = 'Chưa rõ';
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _comboItemsTile() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        'Tiền mặt hàng, combo',
        style: TextStyle(fontSize: 16),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
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
      case 'REJECTION':
        displayText = 'Đã hủy';
        backgroundColor = Colors.red;
        break;
      case 'APPROVED':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.orange;
        break;
      case 'READY_TO_DELIVER':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.orange;
        break;
      case 'DELIVERED':
        displayText = 'Hoàn thành';
        backgroundColor = Colors.green;
        break;
      case 'PENDING':
        displayText = 'Chờ xác nhận';
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

  Widget _paymentInfoTile() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text(
        'Thông tin thanh toán',
        style: TextStyle(fontSize: 16),
      ),
      trailing: Text(
        _formatCurrency(order.total),
        style: const TextStyle(fontSize: 16),
      ),
      children: [
        const DashDivider(),
        _infoRow('Hình thức thanh toán','Tiền mặt'),
        _infoRow('Tiền khách đưa', '0đ'),
        _infoRow('Tiền trả khách', '0đ'),
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
            _sectionTitle('Thông tin đơn hàng'),
            _comboItemsTile(),
            _paymentInfoTile(),
            _sectionTitle('Thông tin giao dịch'),
            _infoRow('Mã tham chiếu:', formatIdToBase36Short(order.id)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trạng thái đơn hàng:'),
                _buildStatusCell(order.status),
              ],
            ),
            _infoRow('Hình thức phục vụ:', 'Ăn tại bàn (Bàn ${order.tableNumber})'),
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
            )
          ],
        ),
      ),
    );
  }
}
