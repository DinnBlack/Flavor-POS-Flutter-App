part of 'product_bloc.dart';

@immutable
sealed class ProductEvent {}

// Product Fetch
class ProductFetchStarted extends ProductEvent {
  final String? categoryId;
  final bool? isShow;

  ProductFetchStarted({this.isShow, this.categoryId});
}

// Product Cus Fetch
class ProductCusFetchStarted extends ProductEvent {
  final String? categoryId;

  ProductCusFetchStarted({this.categoryId});
}

// Product Create
class ProductCreateStarted extends ProductEvent {
  final String name;
  final double price;
  final String description;
  final bool isShown;
  final String categoryId;
  final File? imageFile;

  ProductCreateStarted({
    required this.name,
    required this.price,
    required this.description,
    required this.isShown,
    required this.categoryId,
    this.imageFile,
  });
}

// Product Update
class ProductUpdateStarted extends ProductEvent {
  final String id;
  final String name;
  final double price;
  final String description;
  final bool isShown;
  final String categoryId;

  ProductUpdateStarted({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.isShown,
    required this.categoryId,
  });
}

// Product Delete
class ProductDeleteStarted extends ProductEvent {
  final String id;

  ProductDeleteStarted({required this.id});
}

// Toggle Product Show/Hide
class ProductShowStarted extends ProductEvent {
  final ProductModel product;

  ProductShowStarted({required this.product});
}

class ProductHideStarted extends ProductEvent {
  final ProductModel product;

  ProductHideStarted({required this.product});
}