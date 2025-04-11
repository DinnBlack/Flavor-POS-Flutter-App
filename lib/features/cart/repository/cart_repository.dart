import 'package:order_management_flutter_app/features/product/model/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartRepository {
  final List<CartItem> _items = [];

  Future<List<CartItem>> getCartItems() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    return _items;
  }

  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    final existingItem = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _items.add(CartItem(product: product));
    } else {
      final index = _items.indexOf(existingItem);
      _items[index] = CartItem(
        product: product,
        quantity: existingItem.quantity + 1,
      );
    }
  }

  Future<void> removeProduct(String productId) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    final existingItem = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: '',
          name: '',
          price: 0,
          description: '',
          // createdAt: DateTime.now(),
          // updatedAt: DateTime.now(),
        ),
      ),
    );

    if (existingItem.quantity > 1) {
      final index = _items.indexOf(existingItem);
      _items[index] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity - 1,
      );
    } else {
      _items.removeWhere((item) => item.product.id == productId);
    }
  }

  Future<void> clearCart() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    _items.clear();
  }
}
