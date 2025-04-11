part of 'category_bloc.dart';

@immutable
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

// fetch
class CategoryFetchInProgress extends CategoryState {}

class CategoryFetchSuccess extends CategoryState {
  final List<CategoryModel> categories;

  CategoryFetchSuccess({required this.categories});
}

class CategoryFetchFailure extends CategoryState {
  final String error;

  CategoryFetchFailure({required this.error});
}

// cus fetch
class CategoryCusFetchInProgress extends CategoryState {}

class CategoryCusFetchSuccess extends CategoryState {
  final List<CategoryModel> categories;

  CategoryCusFetchSuccess({required this.categories});
}

class CategoryCusFetchFailure extends CategoryState {
  final String error;

  CategoryCusFetchFailure({required this.error});
}

// add
class CategoryCreateInProgress extends CategoryState {}

class CategoryCreateSuccess extends CategoryState {}

class CategoryCreateFailure extends CategoryState {
  final String error;

  CategoryCreateFailure({required this.error});
}

// delete
class CategoryDeleteInProgress extends CategoryState {}

class CategoryDeleteSuccess extends CategoryState {}

class CategoryDeleteFailure extends CategoryState {
  final String error;

  CategoryDeleteFailure({required this.error});
}

// update
class CategoryUpdateInProgress extends CategoryState {}

class CategoryUpdateSuccess extends CategoryState {}

class CategoryUpdateFailure extends CategoryState {
  final String error;

  CategoryUpdateFailure({required this.error});
}
