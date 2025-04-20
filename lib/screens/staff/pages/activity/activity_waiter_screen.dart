import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/core/widgets/dash_divider.dart';
import '../../../../core/utils/id_formatter.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../features/order/bloc/order_bloc.dart';
import '../../../../features/order/model/order_detail_model.dart';
import '../../../../features/order/model/order_model.dart';
import 'order_screen.dart';

class ActivityWaiterScreen extends StatefulWidget {
  const ActivityWaiterScreen({super.key});

  @override
  _ActivityWaiterScreenState createState() => _ActivityWaiterScreenState();
}

class _ActivityWaiterScreenState extends State<ActivityWaiterScreen> {
  int _currentIndex = 0;
  List<OrderModel> orders = [];
  final Map<String, bool> _expandedOrderState = {};

  final List<String> _tabTitles = ["Món sẵn sàng", "Đang hoạt động"];
  final List<Widget> _pages = [
    const Center(child: Text('Đơn hàng sẵn sàng trả')),
    const Center(child: Text('Lịch sử Content')),
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(
          OrderFetchStarted(
            status: const ['READY_TO_DELIVER'],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomTabBar(
              lineHeight: 4,
              tabBarWidthRatio: 1,
              linePadding: 10,
              currentIndex: _currentIndex,
              onTabTapped: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              tabTitles: _tabTitles,
            ),
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_currentIndex == 0) {
      context.read<OrderBloc>().add(
            OrderFetchStarted(
              status: const ['READY_TO_DELIVER'],
            ),
          );
      return _buildReadyToDeliverOrders();
    } else {
      return _buildActiveOrders();
    }
  }

  Widget _buildActiveOrders() {
    return const OrderScreen(
      isWaiter: true,
    );
  }

  Widget _buildReadyToDeliverOrders() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderFetchSuccess) {
          orders = state.orders;
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty_product.jpg', height: 100),
                  const SizedBox(height: 10),
                  const Text('Không có đơn hàng sẵn sàng!'),
                  const SizedBox(height: 5),
                  const Text('Vui lòng kiểm tra lại sau.'),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(OrderFetchStarted(
                      status: ['PENDING'],
                    ));
              },
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderItem(order);
                },
              ),
            );
          }
        } else if (state is OrderFetchFailure) {
          return Center(child: Text('Lỗi tải dữ liệu'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Hàm xây dựng item đơn hàng
  Widget _buildOrderItem(OrderModel order) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            _buildOrderHeader(order),
            const SizedBox(
              height: 10,
            ),
            _buildOrderDetails(order),
            const SizedBox(
              height: 10,
            ),
            _buildConfirmButton(order),
          ],
        ),
      ),
    );
  }

  // Header đơn hàng
  Widget _buildOrderHeader(OrderModel order) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bàn ${order.tableNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Đơn hàng: ${formatOrderId(order.id)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
              // Display order.id
            ],
          ),
          const Spacer(),
          Text('${CurrencyFormatter.format(order.total)}',
              style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  // Mở rộng chi tiết món trong đơn hàng
  Widget _buildOrderDetails(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedOrderState[order.id] =
                    !(_expandedOrderState[order.id] ?? false);
              });
            },
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu),
                  const SizedBox(width: 10),
                  const Text('Xem món ăn',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(
                    _expandedOrderState[order.id] == true
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_expandedOrderState[order.id] == true)
            _buildExpandedOrderDetails(order),
        ],
      ),
    );
  }

  Widget _buildExpandedOrderDetails(OrderModel order) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.orderItems.length,
      itemBuilder: (context, index) {
        final item = order.orderItems[index];
        bool showDivider = index < order.orderItems.length - 1;
        return _buildOrderDetailItem(item, showDivider);
      },
    );
  }

  Widget _buildOrderDetailItem(OrderDetailModel item, bool showDivider) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.grey.shade300)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(item.dishName),
            subtitle: Text(
                'Số lượng: ${item.quantity}, Giá: ${CurrencyFormatter.format(item.dishPrice)} '),
            trailing: Text(item.note,
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
        ),
        if (showDivider) const DashDivider(), // Show divider only between items
      ],
    );
  }

  // Xác nhận đã giao
  Widget _buildConfirmButton(OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () => _confirmOrderDelivered(order.id),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Xác nhận đã giao',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _confirmOrderDelivered(String orderId) {
    context
        .read<OrderBloc>()
        .add(OrderMarkDeliveredStarted(orderId: orderId, isWaiter: true));
    context.read<OrderBloc>().add(
          OrderFetchStarted(
            status: const ['READY_TO_DELIVER'],
          ),
        );
  }
}
