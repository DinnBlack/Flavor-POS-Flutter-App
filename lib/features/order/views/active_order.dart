import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import '../../floor/bloc/floor_bloc.dart';
import '../bloc/order_bloc.dart';
import '../model/order_model.dart';
import 'active_order_detail.dart';

class ActiveOrder extends StatefulWidget {
  const ActiveOrder({super.key});

  @override
  State<ActiveOrder> createState() => _ActiveOrderState();
}

class _ActiveOrderState extends State<ActiveOrder> {
  final List<String> filterStatuses = [
    'ALL',
    'PENDING',
    'APPROVED',
    'READY_TO_DELIVER',
    'DELIVERED',
  ];
  String selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    context.read<OrderBloc>().add(
          OrderFetchStarted(
            status: const ['PENDING', 'APPROVED', 'READY_TO_DELIVER', 'DELIVERED'],
          ),
        );
  }

  void _selectStatus(String status) {
    setState(() => selectedStatus = status);
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
        return 'Sẵn sàn trả món';
      case 'DELIVERED':
        return 'Đã phục vụ';
      case 'APPROVED':
        return 'Đang chuẩn bị';
      default:
        return 'Tất cả';
    }
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ActiveOrderDetail(order: order),
            ),
          ),
        );
      },
    );
  }


  int _getCrossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) return 6;
    if (Responsive.isTablet(context)) return 5;
    if (Responsive.isMobile(context)) return 3;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderFetchInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrderFetchSuccess) {
          final allOrders = state.orders;
          final filteredOrders = selectedStatus == 'ALL'
              ? allOrders
              : allOrders.where((o) => o.status == selectedStatus).toList();
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Filter Chips
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filterStatuses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final status = filterStatuses[index];
                            final isSelected = selectedStatus == status;

                            return GestureDetector(
                              onTap: () => _selectStatus(status),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary.withOpacity(0.1)
                                      : colors.secondary,
                                  border: Border.all(
                                    width: 2,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusLabel(status),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${filteredOrders.length} đơn hàng",
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Order Grid
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          itemCount: filteredOrders.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.4,
                          ),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return GestureDetector(
                              onTap: () => _showOrderDetails(order),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status)
                                      .withOpacity(0.05),
                                  border: Border.all(
                                      color: _getStatusColor(order.status),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Bàn ${order.tableNumber}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        Icon(Icons.receipt_long,
                                            size: 20,
                                            color:
                                                _getStatusColor(order.status)),
                                      ],
                                    ),
                                    Text(
                                      _getStatusLabel(order.status),
                                      style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(order.total),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
