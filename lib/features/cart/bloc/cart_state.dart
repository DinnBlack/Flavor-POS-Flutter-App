part of 'cart_bloc.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

// fetch product in cart
class CartFetchProductsInProgress extends CartState {}

class CartFetchProductsSuccess extends CartState {
  final List<CartItemModel> cartItems;

  CartFetchProductsSuccess({required this.cartItems});
}

class CartFetchProductsFailure extends CartState {
  final String error;
  CartFetchProductsFailure({required this.error});
}

// add product to cart
class CartAddProductInProgress extends CartState {}

class CartAddProductSuccess extends CartState {}

class CartAddProductFailure extends CartState {
  final String error;

  CartAddProductFailure({required this.error});
}

// remove product from cart
class CartRemoveProductInProgress extends CartState {}

class CartRemoveProductSuccess extends CartState {}

class CartRemoveProductFailure extends CartState {
  final String error;

  CartRemoveProductFailure({required this.error});
}

// update product quantity
class CartUpdateProductQuantityInProgress extends CartState {}

class CartUpdateProductQuantitySuccess extends CartState {}

class CartUpdateProductQuantityFailure extends CartState {
  final String error;

  CartUpdateProductQuantityFailure({required this.error});
}

// clear cart
class CartClearInProgress extends CartState {}

class CartClearSuccess extends CartState {}

class CartClearFailure extends CartState {
  final String error;

  CartClearFailure({required this.error});
}

// update product note
class CartUpdateProductNoteInProgress extends CartState {}

class CartUpdateProductNoteSuccess extends CartState {}

class CartUpdateProductNoteFailure extends CartState {
  final String error;

  CartUpdateProductNoteFailure({required this.error});
}
