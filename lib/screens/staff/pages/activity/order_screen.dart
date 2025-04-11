import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/features/order/views/order_history.dart';

import '../../../../features/order/views/active_order.dart';
import 'widgets/activity_header.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
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
                  title: 'Đơn hàng',
                ),
                Expanded(
                  child: ActiveOrder(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
