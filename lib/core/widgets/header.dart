import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/core/widgets/search_field.dart';
import 'package:order_management_flutter_app/features/cart/views/cart.dart';
import 'package:provider/provider.dart';
import '../../features/cart/bloc/cart_bloc.dart';
import '../controllers/menu_app_controller.dart';
import '../utils/responsive.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                        padding: EdgeInsets.all(5),
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
          if (!Responsive.isMobile(context))
            const Text(
               "Bán hàng",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
