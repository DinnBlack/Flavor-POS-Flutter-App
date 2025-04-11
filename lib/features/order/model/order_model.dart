import 'order_detail_model.dart';

class OrderModel {
  final String id;
  final int tableNumber;
  final String status;
  final List<OrderDetailModel> orderItems;
  final double total;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.orderItems,
    required this.total,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is OrderModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              tableNumber == other.tableNumber &&
              status == other.status &&
              orderItems == other.orderItems &&
              total == other.total &&
              createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      tableNumber.hashCode ^
      status.hashCode ^
      orderItems.hashCode ^
      total.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'OrderModel{' +
        ' id: $id,' +
        ' tableNumber: $tableNumber,' +
        ' status: $status,' +
        ' orderItems: $orderItems,' +
        ' total: $total,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  OrderModel copyWith({
    String? id,
    int? tableNumber,
    String? status,
    List<OrderDetailModel>? orderItems,
    double? total,
    String? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      orderItems: orderItems ?? this.orderItems,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'tableNumber': this.tableNumber,
      'status': this.status,
      'orderItems': this.orderItems.map((item) => item.toMap()).toList(),
      'total': this.total,
      'createdAt': this.createdAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    var items = map['orderItems'] as List;
    List<OrderDetailModel> orderItems = items.map((item) => OrderDetailModel.fromMap(item)).toList();

    double total = 0;
    for (var item in orderItems) {
      total += item.dishPrice * item.quantity;
    }

    return OrderModel(
      id: map['id'] as String,
      tableNumber: map['tableNumber'] as int,
      status: map['status'] as String,
      orderItems: orderItems,
      total: total,
      createdAt: map['createdAt'] as String,
    );
  }
}
