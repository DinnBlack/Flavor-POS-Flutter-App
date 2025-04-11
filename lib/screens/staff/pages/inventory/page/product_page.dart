import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/product/views/widgets/product_inventory_filter.dart';
import 'package:order_management_flutter_app/features/product/views/product_list_inventory.dart';
import '../../../../../core/widgets/custom_toast.dart';
import '../../../../../core/widgets/search_field.dart';
import '../../../../../features/product/bloc/product_bloc.dart';
import '../../../../../features/product/model/product_model.dart';
import '../../../../../features/product/views/widgets/product_create_button.dart';
import '../../../../../features/product/views/product_inventory_detail.dart';
import '../../../../../features/product/views/product_create_form.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _allProducts = [];
  ProductModel? _selectedProduct;
  String? selectedCategoryId;
  String selectedSortOption = 'Mặc định';
  Timer? _timer;
  bool _isCreatingProduct = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(ProductFetchStarted());
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isCreatingProduct) {
        context.read<ProductBloc>().add(ProductFetchStarted());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _filterProductsByCategory(String? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;

      if (categoryId == null || categoryId.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((product) {
          return '' == categoryId;
        }).toList();
        _onSearchChanged(_searchController.text);
      }
      _sortProducts(selectedSortOption);
    });
  }

  void _sortProducts(String option) {
    setState(() {
      selectedSortOption = option;
      switch (option) {
        case 'Giá tăng dần':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Giá giảm dần':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Tên A-Z':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Tên Z-A':
          _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
        default:
          _filteredProducts.sort((a, b) {
            int idA = int.tryParse(a.id) ?? 0;
            int idB = int.tryParse(b.id) ?? 0;
            _filterProductsByCategory(selectedCategoryId);
            return idA.compareTo(idB);
          });
          break;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = selectedCategoryId == null
            ? List.from(_allProducts)
            : _allProducts.where((product) {
                return '' == selectedCategoryId;
              }).toList();
      } else {
        _filteredProducts = _allProducts.where((product) {
          return (selectedCategoryId == null || '' == selectedCategoryId) &&
              product.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductFetchSuccess) {
          setState(() {
            _allProducts = state.products;
            _filteredProducts = List.from(_allProducts);
          });
        }
        if (state is ProductCreateSuccess) {
          setState(() {
            _isCreatingProduct = false;
          });
        }
        if (state is ProductDeleteSuccess) {
          CustomToast.showToast(context, "Xóa sản phẩm thành công!",
              type: ContentType.success);
        }
        if (state is ProductDeleteFailure) {
          CustomToast.showToast(context, "Xóa sản phẩm thất bại!",
              type: ContentType.failure);
        }
      },
      child: _isCreatingProduct
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCreatingProduct = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/arrow_left.svg',
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              colors.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Thêm sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const ProductCreateForm(),
                ],
              ),
            )
          : Column(
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
                              hintText: 'Tìm kiếm món ăn của bạn',
                              controller: _searchController,
                              onSearchChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ProductInventoryFilter(
                          onCategorySelected: _filterProductsByCategory,
                          onSortOptionSelected: _sortProducts,
                        ),
                        const Spacer(),
                        ProductCreateButton(
                          onPressed: () {
                            setState(() {
                              _isCreatingProduct = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: _selectedProduct == null ? 1 : 2,
                          child: ProductListInventory(
                            products: _filteredProducts,
                            isCompact: _selectedProduct != null,
                            onProductSelected: (product) {
                              setState(() {
                                _selectedProduct = product;
                              });
                            },
                          ),
                        ),
                        if (_selectedProduct != null) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: ProductInventoryDetail(
                              product: _selectedProduct!,
                              onClose: () {
                                setState(() {
                                  _selectedProduct = null;
                                });
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
    );
  }
}
