import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/core/widgets/dash_divider.dart';
import '../../../../core/utils/id_formatter.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../../features/order/bloc/order_bloc.dart';
import '../../../../features/order/model/order_detail_model.dart';
import '../../../../features/order/model/order_item_model.dart';
import '../../../../features/order/model/order_model.dart';
import 'order_screen.dart';

class ActivityChefScreen extends StatefulWidget {
  const ActivityChefScreen({super.key});

  @override
  _ActivityChefScreenState createState() => _ActivityChefScreenState();
}

class _ActivityChefScreenState extends State<ActivityChefScreen> {
  int _currentIndex = 0;
  List<OrderModel> orders = [];
  final Map<String, bool> _expandedOrderState = {};

  final List<String> _tabTitles = ["Chờ xác nhận", "Đơn thực hiện"];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(
          OrderFetchStarted(
            status: const ['PENDING'],
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
            OrderFetchStarted(status: ['PENDING']),
          );
      return _buildReadyToDeliverOrders();
    } else {
      context.read<OrderBloc>().add(
            OrderFetchStarted(status: ['APPROVED']),
          );
      return _buildApprovedOrders();
    }
  }

  Widget _buildApprovedOrders() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderFetchSuccess) {
          orders = state.orders;
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty_product.jpg', height: 100),
                  const SizedBox(height: 10),
                  const Text('Không có đơn hàng đang thực hiện!'),
                  const SizedBox(height: 5),
                  const Text('Vui lòng kiểm tra lại sau.'),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(OrderFetchStarted(
                  status: ['APPROVED'],
                ));
              },
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderItem(order, true);
                },
              ),
            );
          }
        } else if (state is OrderFetchFailure) {
          return const Center(child: Text('Lỗi tải dữ liệu'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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
                  return _buildOrderItem(order, false);
                },
              ),
            );
          }
        } else if (state is OrderFetchFailure) {
          return const Center(child: Text('Lỗi tải dữ liệu'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Hàm xây dựng item đơn hàng
  Widget _buildOrderItem(OrderModel order, bool isApproved) {
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
            _buildConfirmButton(order, isApproved),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 28, color: Colors.orange),
            const SizedBox(width: 8),
            // Thông tin đơn hàng gộp lại 1 cột
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng 1: Bàn + Mã đơn
                  Text(
                    'Bàn ${order.tableNumber} • Đơn: ${formatOrderId(order.id)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Dòng 2: Thời gian tạo
                  Text(
                    'Tạo lúc: ${order.createdAt}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Tổng tiền
            Text(
              CurrencyFormatter.format(order.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
        if (showDivider) const DashDivider(),
      ],
    );
  }

  // Xác nhận đã giao
  Widget _buildConfirmButton(OrderModel order, bool isApproved) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (!isApproved) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _confirmOrderCancel(order.id, order.orderItems),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.red,
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
                  child: const Text('Từ chối đơn hàng',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => isApproved
                    ? _confirmOrderReadyToDeliver(order.id)
                    : _confirmOrderApproveStarted(order.id),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: isApproved ? Colors.blue : Colors.green,
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
                child: Text(
                    isApproved ? 'Sẵn sàn trả món' : 'Chấp nhận đơn hàng',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onConfirm(); // Run callback
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  void _confirmOrderApproveStarted(String orderId) {
    _showConfirmDialog(
      context: context,
      title: "Xác nhận duyệt đơn",
      content: "Bạn có chắc muốn duyệt đơn này không?",
      onConfirm: () {
        context.read<OrderBloc>().add(
              OrderApproveStarted(orderId: orderId, isChef: true),
            );
        context.read<OrderBloc>().add(
              OrderFetchStarted(status: const ['PENDING']),
            );
      },
    );
  }

  void _confirmOrderReadyToDeliver(String orderId) {
    _showConfirmDialog(
      context: context,
      title: "Xác nhận sẵn sàng giao",
      content: "Bạn có chắc món đã sẵn sàng để giao không?",
      onConfirm: () {
        context.read<OrderBloc>().add(
              OrderMarkReadyToDeliverStarted(orderId: orderId, isChef: true),
            );
        context.read<OrderBloc>().add(
              OrderFetchStarted(status: const ['PENDING']),
            );
      },
    );
  }

  void _confirmOrderCancel(String orderId, List<OrderDetailModel> items) async {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận hủy đơn"),
        content: const Text("Bạn có chắc chắn muốn từ chối đơn hàng này?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text("Xác nhận"),
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(
                    OrderRejectStarted(
                      orderId: orderId,
                      isChef: true,
                    ),
                  );
              context.read<OrderBloc>().add(
                    OrderFetchStarted(status: const ['PENDING']),
                  );
              showDialog(
                context: context,
                builder: (_) => _buildRejectReasonDialog(orderId, items),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRejectReasonDialog(
      String orderId, List<OrderDetailModel> items) {
    final disabledItems = <String>{};

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Chọn món bị hết nguyên liệu",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const DashDivider(),
              itemBuilder: (_, index) {
                final item = items[index];
                final isDisabled = disabledItems.contains(item.dishName);

                return CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    item.dishName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  value: isDisabled,
                  activeColor: Colors.redAccent,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        disabledItems.add(item.dishName);
                      } else {
                        disabledItems.remove(item.dishName);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Thêm logic xử lý nếu cần ở đây
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text("Xác nhận tắt món"),
            ),
          ],
        );
      },
    );
  }
}
