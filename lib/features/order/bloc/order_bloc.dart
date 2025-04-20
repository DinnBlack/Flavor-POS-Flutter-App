import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:order_management_flutter_app/features/cart/services/cart_service.dart';
import '../../table/model/table_model.dart';
import '../../table/services/table_service.dart';
import '../model/order_item_model.dart';
import '../model/order_model.dart';
import '../services/order_service.dart';

part 'order_event.dart';

part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();
  final TableService tableService = TableService();

  OrderBloc() : super(OrderInitial()) {
    on<OrderStaffCreateStarted>(_onOrderStaffCreateStarted);
    on<OrderCustomerCreateStarted>(_onOrderCustomerCreateStarted);
    on<OrderFetchStarted>(_onOrderFetchStarted);
    on<OrderRejectStarted>(_onOrderRejectStarted);
    on<OrderMarkReadyToDeliverStarted>(_onOrderMarkReadyToDeliverStarted);
    on<OrderMarkDeliveredStarted>(_onOrderMarkDeliveredStarted);
    on<OrderApproveStarted>(_onOrderApproveStarted);
  }

  Future<void> _onOrderStaffCreateStarted(
      OrderStaffCreateStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderStaffCreateInProgress());
      final cart = await cartService.loadCart();
      List<OrderItemModel> orderItems = cart.map((item) {
        return OrderItemModel(
          quantity: item.quantity,
          dishId: item.product.id,
          note: item.note ?? "",
        );
      }).toList();
      await orderService.createStaffOrder(event.tableNumber, orderItems);
      final currentTable =
          await tableService.getTableByTableNumber(event.tableNumber);
      await tableService.updateTableStatusOccupied(currentTable.id);
      emit(OrderStaffCreateSuccess());
      add(OrderFetchStarted());
    } catch (e) {
      emit(OrderStaffCreateFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderCustomerCreateStarted(
      OrderCustomerCreateStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderCustomerCreateInProgress());
      final cart = await cartService.loadCart();
      List<OrderItemModel> orderItems = cart.map((item) {
        return OrderItemModel(
          quantity: item.quantity,
          dishId: item.product.id,
          note: item.note ?? "",
        );
      }).toList();
      await orderService.createCustomerOrder(event.tableNumber, orderItems);
      emit(OrderCustomerCreateSuccess());
      add(OrderFetchStarted());
    } catch (e) {
      emit(OrderCustomerCreateFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderFetchStarted(
      OrderFetchStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderFetchInProgress());
      final orders = await orderService.getOrders(
        statuses: event.status,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      emit(OrderFetchSuccess(orders: orders));
    } catch (e) {
      emit(OrderFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderRejectStarted(
      OrderRejectStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderUpdateInProgress());
      await orderService.rejectOrder(event.orderId);
      emit(OrderUpdateSuccess());
      if (event.isChef) {
        add(OrderFetchStarted(
          status: ['PENDING'],
        ));
      } else {
        add(OrderFetchStarted(
          status: ['PENDING', 'READY_TO_DELIVER', 'DELIVERED', 'APPROVED'],
        ));
      }
    } catch (e) {
      emit(OrderUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderMarkReadyToDeliverStarted(
      OrderMarkReadyToDeliverStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderUpdateInProgress());
      await orderService.markOrderAsReadyToDeliver(event.orderId);
      emit(OrderUpdateSuccess());
      if (event.isChef) {
        add(OrderFetchStarted(
          status: ['APPROVED'],
        ));
      } else {
        add(OrderFetchStarted(
          status: ['PENDING', 'READY_TO_DELIVER', 'DELIVERED', 'APPROVED'],
        ));
      }
    } catch (e) {
      emit(OrderUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderMarkDeliveredStarted(
      OrderMarkDeliveredStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderUpdateInProgress());
      await orderService.markOrderAsDelivered(event.orderId);
      emit(OrderUpdateSuccess());
      if (event.isWaiter) {
        add(OrderFetchStarted(
          status: ['READY_TO_DELIVER'],
        ));
      } else {
        add(OrderFetchStarted(
          status: ['PENDING', 'READY_TO_DELIVER', 'DELIVERED', 'APPROVED'],
        ));
      }
    } catch (e) {
      emit(OrderUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onOrderApproveStarted(
      OrderApproveStarted event, Emitter<OrderState> emit) async {
    try {
      emit(OrderUpdateInProgress());
      await orderService.approveOrder(event.orderId);
      emit(OrderUpdateSuccess());
      if (event.isChef) {
        add(OrderFetchStarted(
          status: ['PENDING'],
        ));
      } else {
        add(OrderFetchStarted(
          status: ['PENDING', 'READY_TO_DELIVER', 'DELIVERED', 'APPROVED'],
        ));
      }
    } catch (e) {
      emit(OrderUpdateFailure(error: e.toString()));
    }
  }
}
