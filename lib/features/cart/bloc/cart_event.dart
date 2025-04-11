part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}

// fetch product in cart
class CartFetchProductsStarted extends CartEvent {}

// add product to cart
class CartAddProductStarted extends CartEvent {
  final ProductModel product;

  CartAddProductStarted({required this.product});
}

// remove product from cart
class CartRemoveProductStarted extends CartEvent {
  final String productId;

  CartRemoveProductStarted({required this.productId});
}

// update product quantity
class CartUpdateProductQuantityStarted extends CartEvent {
  final String productId;
  final int newQuantity;

  CartUpdateProductQuantityStarted(
      {required this.productId, required this.newQuantity});
}

// clear cart
class CartClearStarted extends CartEvent {}

// update product note
class CartUpdateProductNoteStarted extends CartEvent {
  final String productId;
  final String note;

  CartUpdateProductNoteStarted({required this.productId, required this.note});
}
