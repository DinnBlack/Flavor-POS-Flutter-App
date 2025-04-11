import '../../order/model/order_model.dart';

class BillModel {
  final String id;
  final OrderModel order;
  final String paymentStatus;
  final String paymentMethod;
  final String paymentEmployee;
  final DateTime createdAt;
  final DateTime updatedAt;

//<editor-fold desc="Data Methods">
  const BillModel({
    required this.id,
    required this.order,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paymentEmployee,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          order == other.order &&
          paymentStatus == other.paymentStatus &&
          paymentMethod == other.paymentMethod &&
          paymentEmployee == other.paymentEmployee &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt);

  @override
  int get hashCode =>
      id.hashCode ^
      order.hashCode ^
      paymentStatus.hashCode ^
      paymentMethod.hashCode ^
      paymentEmployee.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'BillModel{' +
        ' id: $id,' +
        ' order: $order,' +
        ' paymentStatus: $paymentStatus,' +
        ' paymentMethod: $paymentMethod,' +
        ' paymentEmployee: $paymentEmployee,' +
        ' createdAt: $createdAt,' +
        ' updatedAt: $updatedAt,' +
        '}';
  }

  BillModel copyWith({
    String? id,
    OrderModel? order,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentEmployee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      order: order ?? this.order,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentEmployee: paymentEmployee ?? this.paymentEmployee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'order': this.order,
      'paymentStatus': this.paymentStatus,
      'paymentMethod': this.paymentMethod,
      'paymentEmployee': this.paymentEmployee,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as String,
      order: map['order'] as OrderModel,
      paymentStatus: map['paymentStatus'] as String,
      paymentMethod: map['paymentMethod'] as String,
      paymentEmployee: map['paymentEmployee'] as String,
      createdAt: map['createdAt'] as DateTime,
      updatedAt: map['updatedAt'] as DateTime,
    );
  }

//</editor-fold>
}
