import '../../product/model/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String? note;

  const CartItemModel({
    required this.product,
    required this.quantity,
    this.note,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItemModel &&
          runtimeType == other.runtimeType &&
          product == other.product &&
          quantity == other.quantity &&
          note == other.note);

  @override
  int get hashCode => product.hashCode ^ quantity.hashCode ^ note.hashCode;

  @override
  String toString() {
    return 'CartItemModel{ product: $product, quantity: $quantity, note: $note }';
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? note,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'note': note, 
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel.fromMap(map['product']),
      quantity: map['quantity'] as int,
      note: map['note'] as String?,
    );
  }
}
