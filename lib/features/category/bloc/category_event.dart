part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {}

// fetch
class CategoryFetchStarted extends CategoryEvent {}

// cus fetch
class CategoryCusFetchStarted extends CategoryEvent {}

// add
class CategoryCreateStarted extends CategoryEvent {
  final String categoryName;

  CategoryCreateStarted({required this.categoryName});
}

// delete
class CategoryDeleteStarted extends CategoryEvent {
  final String categoryId;

  CategoryDeleteStarted({required this.categoryId});
}

// update
class CategoryUpdateStarted extends CategoryEvent {
  final String categoryId;
  final String categoryName;

  CategoryUpdateStarted({required this.categoryId, required this.categoryName});
}
