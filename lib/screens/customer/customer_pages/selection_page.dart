import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/cart/bloc/cart_bloc.dart';
import '../../../../features/product/bloc/product_bloc.dart';
import '../../../features/category/bloc/category_bloc.dart';
import '../../../features/category/model/category_model.dart';
import '../../../features/product/model/product_model.dart';
import 'order_page.dart';

class SelectionPage extends StatefulWidget {
  final String tableNumber;

  const SelectionPage({
    super.key,
    required this.tableNumber,
  });

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  int cartCount = 0;
  int? selectedIndex;
  String searchQuery = '';
  String? selectedCategoryId;
  CategoryModel? dropdownCategory;

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((product) {
      final matchName =
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchPrice = product.price.toString().contains(searchQuery);
      return (matchName || matchPrice);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductCusFetchStarted());
    context.read<CategoryBloc>().add(CategoryCusFetchStarted());
    selectedIndex = 0;

    context.read<CartBloc>().stream.listen((state) {
      if (state is CartFetchProductsSuccess) {
        setState(() {
          cartCount = state.cartItems.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.secondary,
      body: SafeArea(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductCusFetchSuccess) {
              final filteredProducts = _filterProducts(state.products);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(),
                    const SizedBox(height: 10),
                    _buildTableInfo(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(flex: 3, child: _buildSearchField()),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: _buildCategoryDropdown()),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductItem(context, product);
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartFetchProductsSuccess && state.cartItems.isNotEmpty) {
            final totalQuantity = state.cartItems
                .fold<int>(0, (sum, item) => sum + item.quantity);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bạn đã thêm",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$totalQuantity món ăn',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OrderPage(
                                    tableNumber: widget.tableNumber,
                                  )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Tiếp tục',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTableInfo() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bạn đang ở",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Bàn, ${widget.tableNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Text(
            'Flavor!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[700]),
          ),
          const Spacer(),
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 1 ? Colors.red[700] : Colors.grey[300],
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryCusFetchSuccess) {
          final categories = [
            const CategoryModel(id: '', name: 'Tất cả'),
            ...state.categories,
          ];

          return DropdownButtonHideUnderline(
            child: DropdownButton2<CategoryModel>(
              isExpanded: true,
              hint: const Text("Chọn danh mục"),
              value: dropdownCategory ?? categories.first,
              items: categories.map((category) {
                return DropdownMenuItem<CategoryModel>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (CategoryModel? newValue) {
                setState(() {
                  dropdownCategory = newValue;
                  selectedCategoryId =
                      newValue!.id.isEmpty ? null : newValue.id;
                  context.read<ProductBloc>().add(
                        ProductCusFetchStarted(categoryId: selectedCategoryId),
                      );
                });
              },
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 60,
                elevation: 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300,
                elevation: 0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey[300]!)),
              ),
            ),
          );
        }

        if (state is CategoryCusFetchFailure) {
          return const Padding(
            padding: EdgeInsets.all(10),
            child: Text('Lỗi khi tải danh mục'),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(10),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 60,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm món ăn...',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Container _buildProductItem(BuildContext context, ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: product.image != null && product.image!.isNotEmpty
                      ? Image.network(
                    product.image!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, size: 40),
                      );
                    },
                  )
                      : Image.asset(
                          'assets/images/default_food.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add, size: 20),
                        color: Colors.white,
                        onPressed: () {
                          context.read<CartBloc>().add(
                                CartAddProductStarted(product: product),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
