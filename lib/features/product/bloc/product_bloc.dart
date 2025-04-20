import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../model/product_model.dart';
import '../services/product_service.dart';

part 'product_event.dart';

part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService = ProductService();
  Timer? _timer; // Timer for polling

  ProductBloc() : super(ProductInitial()) {
    on<ProductFetchStarted>(_onProductFetchStarted);
    on<ProductCusFetchStarted>(_onProductCusFetchStarted);
    on<ProductCreateStarted>(_onProductCreateStarted);
    on<ProductUpdateStarted>(_onProductUpdateStarted);
    on<ProductDeleteStarted>(_onProductDeleteStarted);
    on<ProductShowStarted>(_onProductShowStarted);
    on<ProductHideStarted>(_onProductHideStarted);

    // _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(ProductFetchStarted());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  // Product fetch
  Future<void> _onProductFetchStarted(
      ProductFetchStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductFetchInProgress());
      final products =
          await productService.getProducts(categoryId: event.categoryId, isShown: event.isShow);
      emit(ProductFetchSuccess(products: products));
    } catch (e) {
      emit(ProductFetchFailure(error: e.toString()));
    }
  }

  // Product cus fetch
  Future<void> _onProductCusFetchStarted(
      ProductCusFetchStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductCusFetchInProgress());
      final products = await productService.getCustomerProducts(
          categoryId: event.categoryId);
      emit(ProductCusFetchSuccess(products: products));
    } catch (e) {
      emit(ProductCusFetchFailure(error: e.toString()));
    }
  }

  // Product create
  Future<void> _onProductCreateStarted(
      ProductCreateStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductCreateInProgress());
      await productService.createProduct(event.name, event.price,
          event.description, event.isShown, event.categoryId, event.imageFile);
      emit(ProductCreateSuccess());
      add(ProductFetchStarted());
    } on Exception catch (e) {
      emit(ProductCreateFailure(error: e.toString()));
    }
  }

  // Product update
  Future<void> _onProductUpdateStarted(
      ProductUpdateStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductUpdateInProgress());
      await productService.updateProduct(event.id, event.name, event.price,
          event.description, event.isShown, event.categoryId!);
      emit(ProductUpdateSuccess());
      add(ProductFetchStarted());
    } on Exception catch (e) {
      emit(ProductUpdateFailure(error: e.toString()));
    }
  }

  // Product delete
  Future<void> _onProductDeleteStarted(
      ProductDeleteStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductDeleteInProgress());
      await productService.deleteProduct(event.id);
      emit(ProductDeleteSuccess());
      add(ProductFetchStarted());
    } on Exception catch (e) {
      emit(ProductUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onProductShowStarted(
      ProductShowStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductUpdateInProgress());
      await productService.showProduct(event.product);
      emit(ProductUpdateSuccess());
      add(ProductFetchStarted());
    } catch (e) {
      emit(ProductUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onProductHideStarted(
      ProductHideStarted event, Emitter<ProductState> emit) async {
    try {
      emit(ProductUpdateInProgress());
      await productService.hideProduct(event.product);
      emit(ProductUpdateSuccess());
      add(ProductFetchStarted());
    } catch (e) {
      emit(ProductUpdateFailure(error: e.toString()));
    }
  }
}
