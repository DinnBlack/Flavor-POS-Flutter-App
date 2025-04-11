import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../services/cart_service.dart';
import '../../product/model/product_model.dart';
import '../model/cart_item_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService cartService = CartService();

  CartBloc() : super(CartInitial()) {
    on<CartFetchProductsStarted>(_onCartFetchProductsStarted);
    on<CartAddProductStarted>(_onCartAddProductStarted);
    on<CartRemoveProductStarted>(_onCartRemoveProductStarted);
    on<CartUpdateProductQuantityStarted>(_onCartUpdateProductQuantityStarted);
    on<CartClearStarted>(_onCartClearStarted);
    on<CartUpdateProductNoteStarted>(_onCartUpdateProductNoteStarted);
  }

  Future<void> _onCartFetchProductsStarted(
      CartFetchProductsStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartFetchProductsInProgress());
      final cartItems = await cartService.loadCart();
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartFetchProductsFailure(error: e.toString()));
    }
  }

  Future<void> _onCartAddProductStarted(
      CartAddProductStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartAddProductInProgress());
      final cartItems = await cartService.addProductToCart(
        CartItemModel(product: event.product, quantity: 1),
      );
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartAddProductFailure(error: e.toString()));
    }
  }

  Future<void> _onCartRemoveProductStarted(
      CartRemoveProductStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartRemoveProductInProgress());
      final cartItems = await cartService.removeProductFromCart(event.productId);
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartRemoveProductFailure(error: e.toString()));
    }
  }

  Future<void> _onCartUpdateProductQuantityStarted(
      CartUpdateProductQuantityStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartUpdateProductQuantityInProgress());
      final cartItems =
      await cartService.updateProductQuantity(event.productId, event.newQuantity);
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartUpdateProductQuantityFailure(error: e.toString()));
    }
  }

  Future<void> _onCartClearStarted(
      CartClearStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartClearInProgress());
      final cartItems = await cartService.clearCart();
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartClearFailure(error: e.toString()));
    }
  }

  Future<void> _onCartUpdateProductNoteStarted(
      CartUpdateProductNoteStarted event, Emitter<CartState> emit) async {
    try {
      emit(CartUpdateProductNoteInProgress());
      final cartItems = await cartService.updateProductNote(
        event.productId,
        event.note,
      );
      emit(CartFetchProductsSuccess(cartItems: cartItems));
    } catch (e) {
      emit(CartUpdateProductNoteFailure(error: e.toString()));
    }
  }
}
