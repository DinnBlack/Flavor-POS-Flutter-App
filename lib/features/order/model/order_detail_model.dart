import 'package:order_management_flutter_app/features/product/model/product_model.dart';

class OrderDetailModel {
  final int quantity;
  final String dishName;
  final double dishPrice;
  final String note;

//<editor-fold desc="Data Methods">
  const OrderDetailModel({
    required this.quantity,
    required this.dishName,
    required this.dishPrice,
    required this.note,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderDetailModel &&
          runtimeType == other.runtimeType &&
          quantity == other.quantity &&
          dishName == other.dishName &&
          dishPrice == other.dishPrice &&
          note == other.note);

  @override
  int get hashCode =>
      quantity.hashCode ^
      dishName.hashCode ^
      dishPrice.hashCode ^
      note.hashCode;

  @override
  String toString() {
    return 'OrderDetailModel{' +
        ' quantity: $quantity,' +
        ' dishName: $dishName,' +
        ' dishPrice: $dishPrice,' +
        ' note: $note,' +
        '}';
  }

  OrderDetailModel copyWith({
    int? quantity,
    String? dishName,
    double? dishPrice,
    String? note,
  }) {
    return OrderDetailModel(
      quantity: quantity ?? this.quantity,
      dishName: dishName ?? this.dishName,
      dishPrice: dishPrice ?? this.dishPrice,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': this.quantity,
      'dishName': this.dishName,
      'dishPrice': this.dishPrice,
      'note': this.note,
    };
  }

  factory OrderDetailModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailModel(
      quantity: map['quantity'] as int,
      dishName: map['dishName'] as String,
      dishPrice: map['dishPrice'] as double,
      note: map['note'] as String,
    );
  }

//</editor-fold>
}