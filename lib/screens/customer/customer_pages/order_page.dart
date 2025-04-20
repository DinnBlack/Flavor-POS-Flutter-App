import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../features/cart/bloc/cart_bloc.dart';
import '../../../features/order/bloc/order_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:order_management_flutter_app/features/cart/model/cart_item_model.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;

  _SliverAppBarDelegate({
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              // Back button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Title
              Positioned(
                left: 48,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    'Gọi món ngay!',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Progress dots
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class OrderPage extends StatefulWidget {
  final String tableNumber;

  const OrderPage({super.key, required this.tableNumber});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final Distance distance = const Distance();
  final LatLng storeLocation = const LatLng(10.730770, 106.699139);
  final double maxDistance = 200;

  Future<bool> _checkLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng bật dịch vụ vị trí'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng cấp quyền truy cập vị trí'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      double distanceInMeters = distance.as(
        LengthUnit.Meter,
        LatLng(position.latitude, position.longitude),
        storeLocation,
      );

      if (distanceInMeters > maxDistance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đang ngoài phạm vi cửa hàng'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xác định vị trí: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, double total) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Xác nhận đặt món',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn có chắc chắn muốn đặt món với tổng tiền ${CurrencyFormatter.format(total)}?',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tên: ${_nameController.text}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Huỷ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Đặt món',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartFetchProductsStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: _SliverAppBarDelegate(height: 100).build(
              context,
              0,
              false,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tên của bạn',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập tên ',
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.red[700],
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () {
                              FocusScope.of(context)
                                  .requestFocus(_nameFocusNode);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Danh sách món ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartFetchProductsInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CartFetchProductsFailure) {
                  return Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is CartFetchProductsSuccess) {
                  if (state.cartItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'Hãy thêm món ăn nào!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return _buildCartItem(item, context);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartFetchProductsSuccess) {
                  final subtotal = state.cartItems.fold<double>(
                    0,
                    (sum, item) => sum + (item.product.price * item.quantity),
                  );
                  final tax = subtotal * 0.0;
                  final total = subtotal + tax;

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng cộng',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '(${state.cartItems.length} sản phẩm)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      CurrencyFormatter.format(total),
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tạm tính',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(subtotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Thuế',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(tax),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập tên của bạn'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              FocusScope.of(context)
                                  .requestFocus(_nameFocusNode);
                              return;
                            }

                            bool isInRange = await _checkLocation();
                            if (!isInRange) return;

                            bool confirm =
                                await _showConfirmDialog(context, total);
                            if (!confirm) return;

                            context.read<OrderBloc>().add(
                                OrderCustomerCreateStarted(
                                    tableNumber:
                                        int.parse(widget.tableNumber.trim())));
                            context.read<CartBloc>().add(CartClearStarted());

                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đặt món thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Gọi món!',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  ValueListenableBuilder<bool> _buildCartItem(
      CartItemModel item, BuildContext context) {
    final ValueNotifier<bool> _isExpanded = ValueNotifier(false);
    final TextEditingController _noteController =
    TextEditingController(text: item.note ?? '');

    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (context, expanded, _) {
        return GestureDetector(
          onTap: () => _isExpanded.value = !_isExpanded.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.product.image == null
                          ? Image.asset(
                        'assets/images/default_food.jpg',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        item.product.image!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (item.note != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.note!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(item.product.price),
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove,
                                color: Colors.grey[600], size: 20),
                            onPressed: () {
                              if (item.quantity > 1) {
                                context.read<CartBloc>().add(
                                  CartUpdateProductQuantityStarted(
                                    productId: item.product.id,
                                    newQuantity: item.quantity - 1,
                                  ),
                                );
                              } else {
                                context.read<CartBloc>().add(
                                  CartRemoveProductStarted(
                                    productId: item.product.id,
                                  ),
                                );
                              }
                            },
                          ),
                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add,
                                color: Colors.grey[600], size: 20),
                            onPressed: () {
                              context.read<CartBloc>().add(
                                CartAddProductStarted(product: item.product),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: expanded
                      ? Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Ghi chú món ăn...',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                            BorderSide(color: Colors.grey.shade600),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              context.read<CartBloc>().add(
                                CartUpdateProductNoteStarted(
                                  productId: item.product.id,
                                  note: _noteController.text.trim(),
                                ),
                              );
                              _isExpanded.value = false;
                            },
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
