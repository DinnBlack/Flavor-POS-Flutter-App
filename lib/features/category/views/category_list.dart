import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../product/bloc/product_bloc.dart';
import '../bloc/category_bloc.dart';
import '../model/category_model.dart';
import 'widgets/category_list_item.dart';
import 'widgets/category_skeleton_item.dart';

class MyCategories extends StatelessWidget {
  const MyCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: CategoryList(),
      tablet: CategoryList(),
      desktop: CategoryList(),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoryFetchStarted());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryFetchInProgress) {
          return SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: defaultPadding),
              itemBuilder: (context, index) => const CategorySkeletonItem(),
            ),
          );
        }

        if (state is CategoryFetchFailure) {
          return SizedBox(
            height: 60,
            child: Center(
              child: Text('Lỗi: ${state.error}'),
            ),
          );
        }

        if (state is CategoryFetchSuccess) {
          final categories = state.categories;
          return SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isMobile(context) ? defaultPadding : 0,
                        right: defaultPadding),
                    child: CategoryListItem(
                      category: const CategoryModel(
                        id: '',
                        name: "Tất cả",
                      ),
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          context
                              .read<ProductBloc>()
                              .add(ProductFetchStarted());
                        });
                      },
                    ),
                  );
                } else {
                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: defaultPadding),
                    child: CategoryListItem(
                      category: category,
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          context.read<ProductBloc>().add(
                              ProductFetchStarted(categoryId: category.id));
                        });
                      },
                    ),
                  );
                }
              },
            ),
          );
        }

        return const SizedBox(
          height: 60,
          child: Center(
            child: Text('Không có danh mục nào'),
          ),
        );
      },
    );
  }
}
