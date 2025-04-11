class OrderItemModel {
  final int quantity;
  final String dishId;
  final String note;

  OrderItemModel({
    required this.quantity,
    required this.dishId,
    this.note = "",
  });

  // Phương thức chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      "quantity": quantity,
      "dishId": dishId,
      "note": note,
    };
  }

  // Phương thức toString để in thông tin chi tiết
  @override
  String toString() {
    return 'OrderItemModel(quantity: $quantity, dishId: $dishId, note: $note)';
  }
}
