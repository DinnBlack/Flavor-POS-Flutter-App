import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../model/category_model.dart';
import '../services/category_service.dart';

part 'category_event.dart';

part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService categoryService = CategoryService();

  CategoryBloc() : super(CategoryInitial()) {
    on<CategoryFetchStarted>(_onCategoryFetchStarted);
    on<CategoryCusFetchStarted>(_onCategoryCusFetchStarted);
    on<CategoryCreateStarted>(_onCategoryCreateStarted);
    on<CategoryDeleteStarted>(_onCategoryDeleteStarted);
    on<CategoryUpdateStarted>(_onCategoryUpdateStarted);
  }

  Future<void> _onCategoryFetchStarted(
    CategoryFetchStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryFetchInProgress());
    try {
      final categories = await categoryService.getCategories();
      emit(CategoryFetchSuccess(categories: categories));
    } catch (e) {
      emit(CategoryFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onCategoryCusFetchStarted(
      CategoryCusFetchStarted event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryCusFetchInProgress());
    try {
      final categories = await categoryService.getCustomerCategories();
      emit(CategoryCusFetchSuccess(categories: categories));
    } catch (e) {
      emit(CategoryCusFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onCategoryCreateStarted(
    CategoryCreateStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryCreateInProgress());
    try {
      await categoryService.createCategory(event.categoryName);
      emit(CategoryCreateSuccess());
      add(CategoryFetchStarted());
    } catch (e) {
      emit(CategoryCreateFailure(error: e.toString()));
    }
  }

  Future<void> _onCategoryDeleteStarted(
    CategoryDeleteStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryDeleteInProgress());
    try {
      await categoryService.deleteCategory(event.categoryId);
      emit(CategoryDeleteSuccess());
      add(CategoryFetchStarted());
    } catch (e) {
      emit(CategoryDeleteFailure(error: e.toString()));
    }
  }

  Future<void> _onCategoryUpdateStarted(
    CategoryUpdateStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryUpdateInProgress());
    try {
      await CategoryService()
          .updateCategory(event.categoryId, event.categoryName);
      emit(CategoryUpdateSuccess());
      add(CategoryFetchStarted());
    } catch (e) {
      emit(CategoryUpdateFailure(error: e.toString()));
    }
  }
}
