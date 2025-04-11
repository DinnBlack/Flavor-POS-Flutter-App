import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/category/views/category_list_inventory.dart';
import '../../../../../core/widgets/search_field.dart';
import '../../../../../features/category/bloc/category_bloc.dart';
import '../../../../../features/category/model/category_model.dart';
import '../../../../../features/category/views/category_create_form.dart';
import '../../../../../features/category/views/widgets/category_create_button.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _filteredCategories = [];
  List<CategoryModel> _allCategories = [];
  String? selectedCategory;
  String selectedSortOption = 'Mặc định';
  Timer? _timer;
  final bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(CategoryFetchStarted());
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isCreatingCategory) {
        context.read<CategoryBloc>().add(CategoryFetchStarted());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sortCategories(String option) {
    setState(() {
      selectedSortOption = option;
      switch (option) {
        case 'Tên A-Z':
          _filteredCategories.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Tên Z-A':
          _filteredCategories.sort((a, b) => b.name.compareTo(a.name));
          break;
        default:
          _filteredCategories.sort((a, b) {
            int idA = int.tryParse(a.id) ?? 0;
            int idB = int.tryParse(b.id) ?? 0;
            return idA.compareTo(idB);
          });
          break;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = selectedCategory == null
            ? List.from(_allCategories)
            : _allCategories.where((product) {
                return '' == selectedCategory;
              }).toList();
      } else {
        _filteredCategories = _allCategories.where((product) {
          return (selectedCategory == null || '' == selectedCategory) &&
              product.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showCategoryCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CategoryCreateForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryFetchSuccess) {
          setState(() {
            _allCategories = state.categories;
            _filteredCategories = List.from(_allCategories);
          });
        }
      },
      child: Column(
        children: [
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Expanded(
                      child: SearchField(
                        hintText: 'Tìm kiếm danh mục của bạn',
                        controller: _searchController,
                        onSearchChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CategoryCreateButton(
                    onPressed: _showCategoryCreateDialog,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CategoryListInventory(
                categories: _filteredCategories,
                onCategorySelected: (p0) {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
