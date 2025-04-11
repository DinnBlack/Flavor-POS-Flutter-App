import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/features/invoice/views/widgets/invoice_create.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';

import '../../../core/utils/id_formatter.dart';
import '../../invoice/bloc/invoice_bloc.dart';
import '../bloc/order_bloc.dart';

class ActiveOrderDetail extends StatelessWidget {
  final OrderModel order;

  const ActiveOrderDetail({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'READY_TO_DELIVER':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      case 'APPROVED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'READY_TO_DELIVER':
        return 'Sẵn sàng trả món';
      case 'DELIVERED':
        return 'Đã phục vụ';
      case 'APPROVED':
        return 'Đang chuẩn bị';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${formatIdToBase36Short(order.id)}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Chip(
                label: Text(
                  _getStatusLabel(order.status),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Bàn số: ${order.tableNumber}'),
          Text('Ngày tạo: ${order.createdAt}'),
          const SizedBox(height: 16),

          // Danh sách món ăn
          Text('Chi tiết món', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...order.orderItems.map((item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(item.dishName),
                  subtitle: item.note.isNotEmpty
                      ? Text('Ghi chú: ${item.note}')
                      : null,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('x${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(CurrencyFormatter.format(
                          item.dishPrice * item.quantity)),
                    ],
                  ),
                ),
              )),

          const Divider(height: 32),

          // Tổng tiền
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tổng cộng:',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  CurrencyFormatter.format(order.total),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nút hành động
          if (order.status == 'PENDING') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Thêm logic cập nhật món
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Chức năng cập nhật món đang phát triển')),
                      );
                    },
                    child: const Text('Cập nhật món'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<OrderBloc>()
                          .add(OrderApproveStarted(orderId: order.id));
                      Navigator.pop(context);
                    },
                    child: const Text('Chấp nhận đơn hàng'),
                  ),
                ),
              ],
            ),
          ] else if (order.status == 'APPROVED') ...[
            ElevatedButton(
              onPressed: () {
                context
                    .read<OrderBloc>()
                    .add(OrderMarkReadyToDeliverStarted(orderId: order.id));
                Navigator.pop(context);
              },
              child: const Text('Sẵn sàng trả món'),
            ),
          ] else if (order.status == 'READY_TO_DELIVER') ...[
            ElevatedButton(
              onPressed: () {
                context
                    .read<OrderBloc>()
                    .add(OrderMarkDeliveredStarted(orderId: order.id));
                Navigator.pop(context);
              },
              child: const Text('Đã phục vụ'),
            ),
          ] else if (order.status == 'DELIVERED') ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      insetPadding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: InvoiceCreate(order: order),
                      ),
                    );
                  },
                );
              },
              child: const Text('Thanh toán'),
            ),
          ],
        ],
      ),
    );
  }
}
