import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';

import '../bloc/order_bloc.dart';
import 'order_filter.dart';
import 'order_list.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<OrderModel> _filteredOrders = [];
  List<OrderModel> _allOrders = [];

  final List<Map<String, dynamic>> filterOptions = [
    {'icon': Icons.list, 'title': 'Tất cả đơn hàng'},
    {
      'icon': Icons.check_circle,
      'title': 'Đơn hoàn thành',
      'status': 'DELIVERED'
    },
    {
      'icon': Icons.pending,
      'title': 'Đang hoạt động',
      'status': ['APPROVED', 'READY_TO_DELIVER'],
    },
    {'icon': Icons.cancel, 'title': 'Đơn bị hủy', 'status': 'REJECTION'},
    {
      'icon': Icons.attach_money,
      'title': 'Đã thanh toán',
      'paymentStatus': 'paid'
    },
    {
      'icon': Icons.money_off,
      'title': 'Chưa thanh toán',
      'paymentStatus': 'unpaid'
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderFetchStarted());
  }

  void _filterOrders(DateTime startDate, TimeOfDay startTime, DateTime endDate,
      TimeOfDay endTime,
      {String? filter}) {
    DateTime startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    setState(() {
      _filteredOrders = _allOrders.where((order) {
        DateTime orderTime = DateTime.now();
        bool isWithinTimeRange =
            orderTime.isAfter(startDateTime) && orderTime.isBefore(endDateTime);

        if (filter != null && filter != 'Tất cả đơn hàng') {
          final selectedOption = filterOptions.firstWhere(
            (option) => option['title'] == filter,
            orElse: () => {},
          );

          if (selectedOption.containsKey('status')) {
            final statusList = selectedOption['status'];
            if (statusList is List) {
              if (!statusList.contains(order.status)) {
                return false;
              }
            } else {
              if (order.status != statusList) {
                return false;
              }
            }
          }
          if (selectedOption.containsKey('paymentStatus') &&
              order.status != selectedOption['paymentStatus']) {
            return false;
          }
        }

        return isWithinTimeRange;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderFetchSuccess) {
          // Ensure widget is still mounted before calling setState
          if (mounted) {
            setState(() {
              _allOrders = state.orders;
              _filteredOrders = List.from(_allOrders);
            });
          }
        }
      },
      child: Column(
        children: [
          OrderFilter(
            filterOptions: filterOptions,
            onFilterChanged: (startDate, startTime, endDate, endTime, filter) {
              _filterOrders(startDate, startTime, endDate, endTime,
                  filter: filter);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OrderList(orders: _filteredOrders),
          )),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
