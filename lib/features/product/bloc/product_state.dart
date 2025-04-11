part of 'product_bloc.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

// Product Fetch
class ProductFetchInProgress extends ProductState {}

class ProductFetchSuccess extends ProductState {
  final List<ProductModel> products;

  ProductFetchSuccess({required this.products});
}

class ProductFetchFailure extends ProductState {
  final String error;

  ProductFetchFailure({required this.error});
}

// Product Cus Fetch
class ProductCusFetchInProgress extends ProductState {}

class ProductCusFetchSuccess extends ProductState {
  final List<ProductModel> products;

  ProductCusFetchSuccess({required this.products});
}

class ProductCusFetchFailure extends ProductState {
  final String error;

  ProductCusFetchFailure({required this.error});
}

// Product Create
class ProductCreateInProgress extends ProductState {}

class ProductCreateSuccess extends ProductState {}

class ProductCreateFailure extends ProductState {
  final String error;

  ProductCreateFailure({required this.error});
}

// Product Update
class ProductUpdateInProgress extends ProductState {}

class ProductUpdateSuccess extends ProductState {}

class ProductUpdateFailure extends ProductState {
  final String error;

  ProductUpdateFailure({required this.error});
}

// Product Delete
class ProductDeleteInProgress extends ProductState {}

class ProductDeleteSuccess extends ProductState {}

class ProductDeleteFailure extends ProductState {
  final String error;

  ProductDeleteFailure({required this.error});
}
