import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../model/order_model.dart';

class OrderTrackingWidget extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme
        .of(context)
        .colorScheme;

    return const Placeholder();
  }
}