part of 'order_bloc.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}

// order staff create
class OrderStaffCreateInProgress extends OrderState {}

class OrderStaffCreateSuccess extends OrderState {}

class OrderStaffCreateFailure extends OrderState {
  final String error;

  OrderStaffCreateFailure({required this.error});
}

// order staff create
class OrderCustomerCreateInProgress extends OrderState {}

class OrderCustomerCreateSuccess extends OrderState {}

class OrderCustomerCreateFailure extends OrderState {
  final String error;

  OrderCustomerCreateFailure({required this.error});
}


// order fetch
class OrderFetchInProgress extends OrderState {}

class OrderFetchSuccess extends OrderState {
  final List<OrderModel> orders;

  OrderFetchSuccess({required this.orders});
}

class OrderFetchFailure extends OrderState {
  final String error;

  OrderFetchFailure({required this.error});
}

// order update
class OrderUpdateInProgress extends OrderState {}

class OrderUpdateSuccess extends OrderState {}

class OrderUpdateFailure extends OrderState {
  final String error;

  OrderUpdateFailure({required this.error});
}
