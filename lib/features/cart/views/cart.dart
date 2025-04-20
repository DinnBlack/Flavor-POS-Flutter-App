import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/floor/bloc/floor_bloc.dart';
import 'package:order_management_flutter_app/features/floor/model/floor_model.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/dash_divider.dart';
import '../../category/bloc/category_bloc.dart';
import '../../order/bloc/order_bloc.dart';
import '../../table/bloc/table_bloc.dart';
import '../../table/model/table_model.dart';
import '../bloc/cart_bloc.dart';
import 'widgets/cart_item.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  String selectedTable = "";
  String selectedFloor = "";

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartFetchProductsStarted());
    context.read<FloorBloc>().add(FloorFetchStarted());
    context.read<TableBloc>().add(TableFetchStarted(status: 'AVAILABLE'));
    selectedTable = '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartFetchProductsInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CartFetchProductsFailure) {
                    return Center(
                        child: Text("Lỗi: ${state.error}",
                            style: const TextStyle(color: Colors.red)));
                  }

                  if (state is CartFetchProductsSuccess) {
                    final cartItems = state.cartItems;
                    if (cartItems.isEmpty) {
                      return const Center(
                          child: Text("Giỏ hàng trống",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const DashDivider(),
                      itemBuilder: (context, index) =>
                          CartItem(cartItem: cartItems[index]),
                    );
                  }

                  return const Center(child: Text("Giỏ hàng trống"));
                },
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/order.svg',
                    colorFilter:
                        const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                ),
              ),
              const Text(
                "Tạo đơn hàng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: "Xác nhận",
                      content:
                          "Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?",
                      onConfirm: () {
                        context.read<CartBloc>().add(CartClearStarted());
                        CustomToast.showToast(context, "Giỏ hàng đã được xóa!",
                            type: ContentType.success);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    colorFilter:
                        const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              BlocBuilder<FloorBloc, FloorState>(
                builder: (context, state) {
                  if (state is FloorFetchSuccess) {
                    final floors = state.floors;
                    if (selectedFloor.isEmpty && floors.isNotEmpty) {
                      selectedFloor = floors[0].name;
                    }
                    return Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: selectedFloor,
                          buttonStyleData: ButtonStyleData(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            elevation: 0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFloor = newValue!;
                              selectedTable = "";
                            });
                          },
                          items: floors.map((FloorModel floor) {
                            return DropdownMenuItem<String>(
                              value: floor.name,
                              child: Text(floor.name,
                                  style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else if (state is FloorFetchFailure) {}
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(
                width: 10,
              ),
              BlocBuilder<TableBloc, TableState>(
                builder: (context, state) {
                  if (state is TableFetchSuccess) {
                    // Lọc bàn theo tầng đã chọn
                    final tables = state.tables;
                    final filteredTables = tables
                        .where((table) => table.floorName == selectedFloor)
                        .toSet()
                        .toList();

                    print(filteredTables);
                    if (selectedTable.isEmpty && filteredTables.isNotEmpty) {
                      selectedTable = filteredTables[0].number.toString();
                    }

                    return Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: selectedTable.isEmpty ? null : selectedTable,
                          buttonStyleData: ButtonStyleData(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 50,
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            elevation: 0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedTable = newValue;
                              });
                            }
                          },
                          items: filteredTables.isEmpty
                              ? [
                                  const DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('Không có bàn nào',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ]
                              : filteredTables
                                  .map((TableModel table) {
                                    return DropdownMenuItem<String>(
                                      value: table.number.toString(),
                                      child: Text('Bàn ${table.number}',
                                          style: const TextStyle(fontSize: 12)),
                                    );
                                  })
                                  .toSet()
                                  .toList(), // Loại bỏ bàn trùng lặp
                        ),
                      ),
                    );
                  } else if (state is TableFetchFailure) {
                    // Handle failure state if necessary
                    return const SizedBox.shrink();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        double totalPrice = 0;
        if (state is CartFetchProductsSuccess) {
          totalPrice = state.cartItems.fold(
              0, (sum, item) => sum + (item.product.price * item.quantity));
        }
        if (totalPrice == 0) {
          return const SizedBox.shrink();
        } else {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                )),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng tiền:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        CurrencyFormatter.format(totalPrice),
                        style: TextStyle(
                            fontSize: 14,
                            color: colors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                BlocListener<OrderBloc, OrderState>(
                  listener: (context, state) {
                    if (state is OrderStaffCreateSuccess) {
                      CustomToast.showToast(context, "Gọi món thành công!",
                          type: ContentType.success);
                      context.read<CartBloc>().add(CartClearStarted());
                      context
                          .read<TableBloc>()
                          .add(TableFetchStarted(status: 'AVAILABLE'));
                      if (Responsive.isMobile(context)) Navigator.pop(context);
                      setState(() {
                        selectedTable = "";
                      });
                    } else if (state is OrderStaffCreateFailure) {
                      CustomToast.showToast(context, "Gọi món thất bại!",
                          type: ContentType.failure);
                    }
                  },
                  child: BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is OrderStaffCreateInProgress
                              ? null
                              : () async {
                                  final isConfirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Xác nhận"),
                                      content: const Text(
                                          "Bạn có chắc muốn gọi món cho bàn này không?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Hủy"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("Gọi món"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (isConfirmed == true) {
                                    context.read<OrderBloc>().add(
                                          OrderStaffCreateStarted(
                                            tableNumber:
                                                int.parse(selectedTable),
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: state is OrderStaffCreateInProgress
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  "Gọi món",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
