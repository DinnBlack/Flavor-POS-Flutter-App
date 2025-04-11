import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/widgets/activity_header.dart';

import '../../../../features/order/views/order_history.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                ActivityHeader(
                  title: 'Lịch sử đơn hàng',
                ),
                Expanded(
                  child: OrderHistory(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
