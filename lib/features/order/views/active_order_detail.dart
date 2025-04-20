import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/core/widgets/dash_divider.dart';
import 'package:order_management_flutter_app/features/invoice/views/invoice_create.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';
import '../../../core/utils/id_formatter.dart';
import '../../user/model/user_model.dart';
import '../../user/services/user_service.dart';
import '../bloc/order_bloc.dart';

class ActiveOrderDetail extends StatefulWidget {
  final OrderModel order;

  const ActiveOrderDetail({super.key, required this.order});

  @override
  State<ActiveOrderDetail> createState() => _ActiveOrderDetailState();
}

class _ActiveOrderDetailState extends State<ActiveOrderDetail> {
  late String role;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user = await UserService().getProfile();
    setState(() {
      role = user.nickname;
    });
  }

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

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final orderBloc = context.read<OrderBloc>();

    switch (widget.order.status) {
      case 'PENDING':
        if (role == 'waiter') {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Xác nhận từ chối'),
                        content: const Text(
                            'Bạn có chắc chắn muốn từ chối đơn hàng này?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              orderBloc.add(
                                OrderRejectStarted(orderId: widget.order.id, isChef: false),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Xác nhận'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                label: const Text('Từ chối đơn'),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () {
                  orderBloc.add(OrderApproveStarted(orderId: widget.order.id, isChef: false));
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                label: const Text('Chấp nhận đơn'),
              ),
            ),
          ],
        );

      case 'APPROVED':
        if (role == 'waiter') {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            icon: const Icon(Icons.delivery_dining),
            onPressed: () {
              orderBloc.add(
                  OrderMarkReadyToDeliverStarted(orderId: widget.order.id, isChef: false));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            label: const Text('Sẵn sàng trả món'),
          ),
        );

      case 'READY_TO_DELIVER':
        if (role == 'chef') {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () {
              orderBloc.add(OrderMarkDeliveredStarted(
                  orderId: widget.order.id, isWaiter: false));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            label: const Text('Đã phục vụ'),
          ),
        );

      case 'DELIVERED':
        if (role == 'chef') {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    insetPadding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: InvoiceCreate(order: widget.order),
                    ),
                  );
                },
              );
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            label: const Text('Thanh toán'),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.order.status);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Responsive.isMobile(context))
            Column(
              children: [
                Text(
                  '#${formatOrderId(widget.order.id)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: statusColor),
                  alignment: Alignment.center,
                  child: Text(
                    _getStatusLabel(widget.order.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${formatOrderId(widget.order.id)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: statusColor),
                  child: Text(
                    _getStatusLabel(widget.order.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Text('Bàn số: ${widget.order.tableNumber}'),
          Text('Ngày tạo: ${widget.order.createdAt}'),
          const SizedBox(height: 10),

          /// Danh sách món
          Text('Chi tiết món', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.order.orderItems.length,
              itemBuilder: (context, index) {
                final item = widget.order.orderItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Tên + ghi chú
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.dishName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                            if (item.note.isNotEmpty)
                              Text('Ghi chú: ${item.note}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  )),
                          ],
                        ),
                      ),
                      // Số lượng + giá
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('x${item.quantity}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(CurrencyFormatter.format(
                              item.dishPrice * item.quantity)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const DashDivider(),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Tổng cộng:', style: theme.textTheme.titleMedium),
                Text(
                  CurrencyFormatter.format(widget.order.total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
