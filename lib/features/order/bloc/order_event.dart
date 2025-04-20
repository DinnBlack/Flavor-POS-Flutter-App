part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {}

// order staff create
class OrderStaffCreateStarted extends OrderEvent {
  final int tableNumber;

  OrderStaffCreateStarted({required this.tableNumber});
}

// order customer create
class OrderCustomerCreateStarted extends OrderEvent {
  final int tableNumber;

  OrderCustomerCreateStarted({required this.tableNumber});
}

// order fetch
class OrderFetchStarted extends OrderEvent {
  final List<String>? status;
  final DateTime? startTime;
  final DateTime? endTime;

  OrderFetchStarted({
    this.status,
    this.startTime,
    this.endTime,
  });
}

// reject order
class OrderRejectStarted extends OrderEvent {
  final String orderId;
  final bool isChef;

  OrderRejectStarted(
      {required this.orderId, required this.isChef});
}

// mark order as ready to deliver
class OrderMarkReadyToDeliverStarted extends OrderEvent {
  final String orderId;
  final bool isChef;

  OrderMarkReadyToDeliverStarted({required this.orderId, required this.isChef});
}

// mark order as delivered
class OrderMarkDeliveredStarted extends OrderEvent {
  final String orderId;
  final bool isWaiter;

  OrderMarkDeliveredStarted({required this.orderId, required this.isWaiter});
}

// approve order
class OrderApproveStarted extends OrderEvent {
  final String orderId;
  final bool isChef;

  OrderApproveStarted({required this.orderId, required this.isChef});
}
