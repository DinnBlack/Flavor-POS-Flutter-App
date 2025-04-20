import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:order_management_flutter_app/core/widgets/search_field.dart';
import 'package:order_management_flutter_app/features/cart/views/cart.dart';
import 'package:order_management_flutter_app/features/shift/services/shift_service.dart';
import 'package:provider/provider.dart';
import '../../features/shift/bloc/shift_bloc.dart';
import '../controllers/menu_app_controller.dart';
import '../utils/responsive.dart';
import 'package:order_management_flutter_app/features/cart/bloc/cart_bloc.dart';
import 'package:intl/intl.dart';

class Header extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onSearchChanged;

  const Header({
    super.key,
    this.controller,
    this.onSearchChanged,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int cartCount = 0;
  bool isCaOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().stream.listen((state) {
      if (state is CartFetchProductsSuccess) {
        setState(() {
          cartCount = state.cartItems.length;
        });
      }
    });
  }

  void _showConfirmationDialog() async {
    String currentTime =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(
            isCaOpen
                ? 'Bạn có chắc chắn muốn mở ca lúc $currentTime?'
                : 'Bạn có chắc chắn muốn đóng ca lúc $currentTime?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final shift = await ShiftService().getCurrentShift();
                context
                    .read<ShiftBloc>()
                    .add(ShiftEndStarted(shiftId: shift!.id));
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      setState(() {
        isCaOpen = !isCaOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (Responsive.isTablet(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
          if (Responsive.isMobile(context)) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SearchField(
                  hintText: 'Tìm kiếm món ăn của bạn',
                  controller: widget.controller ?? TextEditingController(),
                  onSearchChanged: widget.onSearchChanged ?? (value) {},
                ),
              ),
            ),
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyCart()),
                );
              },
            ),
          ],
          if (!Responsive.isMobile(context)) ...[
            const Text(
              "Bán hàng",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            FlutterSwitch(
              value: isCaOpen,
              onToggle: (val) {
                _showConfirmationDialog();
              },
              activeColor: Colors.green.withOpacity(0.1),
              inactiveColor: Colors.red.withOpacity(0.1),
              activeText: 'Mở ca',
              inactiveText: 'Đóng ca',
              activeTextColor: Colors.green,
              inactiveTextColor: Colors.red,
              width: 100,
              height: 40,
              toggleSize: 20,
              valueFontSize: 14.0,
              borderRadius: 10.0,
              showOnOff: true,
              activeTextFontWeight: FontWeight.bold,
              inactiveTextFontWeight: FontWeight.bold,
              toggleColor: Colors.white,
            )
          ],
        ],
      ),
    );
  }
}
