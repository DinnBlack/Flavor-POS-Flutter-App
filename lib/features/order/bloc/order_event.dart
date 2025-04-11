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

  OrderFetchStarted({this.status});
}

// reject order
class OrderRejectStarted extends OrderEvent {
  final String orderId;

  OrderRejectStarted({required this.orderId});
}

// mark order as ready to deliver
class OrderMarkReadyToDeliverStarted extends OrderEvent {
  final String orderId;

  OrderMarkReadyToDeliverStarted({required this.orderId});
}

// mark order as delivered
class OrderMarkDeliveredStarted extends OrderEvent {
  final String orderId;

  OrderMarkDeliveredStarted({required this.orderId});
}

// approve order
class OrderApproveStarted extends OrderEvent {
  final String orderId;

  OrderApproveStarted({required this.orderId});
}
