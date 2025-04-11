import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../features/cart/views/cart.dart';
import '../../../../features/category/views/category_list.dart';
import '../../../../features/product/bloc/product_bloc.dart';
import '../../../../features/product/views/product_list.dart';
import 'package:order_management_flutter_app/features/product/model/product_model.dart';
import '../../../../features/product/views/widgets/product_list_item_skeleton.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _allProducts = [];
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductFetchStarted());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterProductsByCategory(String? categoryId) {
    setState(() {
      if (categoryId == null) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return '' == categoryId;
        }).toList();
      }
    });
    _onSearchChanged(_searchController.text);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (selectedCategoryId == null) {
        _filteredProducts = _allProducts.where((product) {
          return product.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredProducts = _allProducts.where((product) {
          return '' == selectedCategoryId &&
              product.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductFetchSuccess) {
          setState(() {
            _allProducts = state.products;
            _filteredProducts = _allProducts;
          });
        }
      },
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              const Expanded(
                flex: 3,
                child: MyCart(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Header(
          controller: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: !Responsive.isMobile(context) ? 10 : 0),
          child: MyCategories(
            onCategorySelected: (categoryId) {
              setState(() {
                selectedCategoryId = categoryId;
              });
              _filterProductsByCategory(selectedCategoryId);
            },
          ),
        ),
        const SizedBox(height: defaultPadding),
        if (!Responsive.isMobile(context)) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SearchField(
              hintText: 'Tìm kiếm món ăn của bạn',
              controller: _searchController,
              onSearchChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductFetchInProgress) {
                return LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount;

                  if (Responsive.isMobile(context)) {
                    crossAxisCount = 2;
                  } else if (Responsive.isTablet(context)) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 3;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: 16,
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: defaultPadding,
                      mainAxisSpacing: defaultPadding,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) =>
                        const ProductListItemSkeleton(),
                  );
                });
              } else if (state is ProductFetchSuccess) {
                return ProductList(products: _filteredProducts);
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }
}
