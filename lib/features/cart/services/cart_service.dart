import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart_item_model.dart';

class CartService {
  static const String cartKey = 'cart_items';

  Future<List<CartItemModel>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(cartKey);
    if (cartJson == null) return [];
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.map((item) => CartItemModel.fromMap(item)).toList();
  }

  Future<List<CartItemModel>> addProductToCart(CartItemModel cartItem) async {
    final cart = await loadCart();
    final index =
        cart.indexWhere((item) => item.product.id == cartItem.product.id);

    if (index >= 0) {
      cart[index] = CartItemModel(
        product: cart[index].product,
        quantity: cart[index].quantity + cartItem.quantity,
        note: cartItem.note?.isNotEmpty == true
            ? cartItem.note
            : cart[index].note,
      );
    } else {
      cart.add(cartItem);
    }

    return _saveCart(cart);
  }

  Future<List<CartItemModel>> removeProductFromCart(String productId) async {
    final cart = await loadCart();
    cart.removeWhere((item) => item.product.id == productId);
    return _saveCart(cart);
  }

  Future<List<CartItemModel>> updateProductQuantity(
      String productId, int newQuantity) async {
    final cart = await loadCart();
    final index = cart.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      cart[index] = CartItemModel(
        product: cart[index].product,
        quantity: newQuantity,
        note: cart[index].note,
      );
    }
    return _saveCart(cart);
  }

  Future<List<CartItemModel>> updateProductNote(
      String productId, String note) async {
    final cart = await loadCart();
    final index = cart.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      cart[index] = CartItemModel(
        product: cart[index].product,
        quantity: cart[index].quantity,
        note: note,
      );
    }

    return _saveCart(cart);
  }

  Future<List<CartItemModel>> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cartKey);
    return [];
  }

  Future<List<CartItemModel>> _saveCart(List<CartItemModel> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(cart.map((item) => item.toMap()).toList());
    await prefs.setString(cartKey, encoded);
    return cart;
  }
}
