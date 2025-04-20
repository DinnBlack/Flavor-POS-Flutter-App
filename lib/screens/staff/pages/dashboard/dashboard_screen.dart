import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/shift/model/shift_model.dart';
import 'package:order_management_flutter_app/features/shift/services/shift_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/header.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../features/cart/views/cart.dart';
import '../../../../features/category/views/category_list.dart';
import '../../../../features/product/bloc/product_bloc.dart';
import '../../../../features/product/views/product_list.dart';
import 'package:order_management_flutter_app/features/product/model/product_model.dart';
import '../../../../features/product/views/widgets/product_skeleton_item.dart';
import '../../../../features/shift/bloc/shift_bloc.dart';
import '../../../../features/table/bloc/table_bloc.dart';

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
  late ShiftModel? shift;
  bool isShiftClosed = false;
  Timer? _timeUpdateTimer;
  bool _isTimerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadShift();
    context.read<ProductBloc>().add(ProductFetchStarted(isShow: true));
    context.read<TableBloc>().add(TableFetchStarted(status: 'AVAILABLE'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShift() async {
    shift = await ShiftService().getCurrentShift();
    if (mounted) {
      setState(() {
        isShiftClosed = shift == null;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTimerInitialized) {
      _startTimer();
      _isTimerInitialized = true;
    }
  }

  void _startTimer() {
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _startShift() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận mở ca'),
        content: const Text('Bạn có chắc chắn muốn mở ca trực mới không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ShiftBloc>().add(ShiftStartStarted());
      _loadShift();
    }
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    return BlocListener<ShiftBloc, ShiftState>(
      listener: (context, state) {
        if (state is ShiftStartSuccess || state is ShiftEndSuccess) {
          _loadShift();
        }
      },
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductFetchSuccess) {
            setState(() {
              _allProducts = state.products;
              _filteredProducts = _allProducts;
            });
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Row(
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
              if (isShiftClosed)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/off_shift.jpg',
                            height: 300,
                            width: 300,
                          ),
                          Text(
                            'Đã đóng ca trực.\nHiện tại là ${_formattedTime()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Vui lòng mở ca để tiếp tục sử dụng hệ thống',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _startShift,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Mở ca trực'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
          child: const MyCategories(),
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
                        const ProductSkeletonItem(),
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

  void _onSearchChanged(String query) {
    setState(() {
      String normalizedQuery = removeDiacritics(query.toLowerCase());
      _filteredProducts = _allProducts.where((product) {
        String normalizedProductName =
            removeDiacritics(product.name.toLowerCase());
        return normalizedProductName.contains(normalizedQuery);
      }).toList();
    });
  }
}
