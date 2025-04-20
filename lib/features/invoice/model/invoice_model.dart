import '../../order/model/order_model.dart';

class InvoiceModel {
  final String id;
  final String invoiceCode;
  final double total;
  final double amountGiven;
  final double changeAmount;
  final String paymentMethod;
  final String cashierName;
  final OrderModel order;
  final String createdAt;

//<editor-fold desc="Data Methods">
  const InvoiceModel({
    required this.id,
    required this.invoiceCode,
    required this.total,
    required this.amountGiven,
    required this.changeAmount,
    required this.paymentMethod,
    required this.cashierName,
    required this.order,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceCode == other.invoiceCode &&
          total == other.total &&
          amountGiven == other.amountGiven &&
          changeAmount == other.changeAmount &&
          paymentMethod == other.paymentMethod &&
          cashierName == other.cashierName &&
          order == other.order &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      invoiceCode.hashCode ^
      total.hashCode ^
      amountGiven.hashCode ^
      changeAmount.hashCode ^
      paymentMethod.hashCode ^
      cashierName.hashCode ^
      order.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'InvoiceModel{' +
        ' id: $id,' +
        ' invoiceCode: $invoiceCode,' +
        ' total: $total,' +
        ' amountGiven: $amountGiven,' +
        ' changeAmount: $changeAmount,' +
        ' paymentMethod: $paymentMethod,' +
        ' cashierName: $cashierName,' +
        ' order: $order,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceCode,
    double? total,
    double? amountGiven,
    double? changeAmount,
    String? paymentMethod,
    String? cashierName,
    OrderModel? order,
    String? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceCode: invoiceCode ?? this.invoiceCode,
      total: total ?? this.total,
      amountGiven: amountGiven ?? this.amountGiven,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashierName: cashierName ?? this.cashierName,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'invoiceCode': this.invoiceCode,
      'total': this.total,
      'amountGiven': this.amountGiven,
      'changeAmount': this.changeAmount,
      'paymentMethod': this.paymentMethod,
      'cashierName': this.cashierName,
      'order': this.order,
      'createdAt': this.createdAt,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as String,
      invoiceCode: map['invoiceCode'] as String,
      total: (map['total'] ?? 0).toDouble(),
      amountGiven: (map['amountGiven'] ?? 0).toDouble(),
      changeAmount: (map['changeAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      cashierName: map['cashierName'] as String? ?? '',
      order: OrderModel.fromMap(map['order'] as Map<String, dynamic>),
      createdAt: map['createdAt'] as String,
    );
  }

//</editor-fold>
}
