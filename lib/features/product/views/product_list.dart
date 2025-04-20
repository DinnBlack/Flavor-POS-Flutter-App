import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import '../../../core/utils/constants.dart';
import '../model/product_model.dart';
import 'widgets/product_list_item.dart';

class ProductList extends StatelessWidget {
  final List<ProductModel> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/4076/4076549.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Không có sản phẩm nào!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount;

      if (Responsive.isMobile(context)) {
        crossAxisCount = 2;
      } else if (Responsive.isTablet(context)) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 4;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: defaultPadding,
          mainAxisSpacing: defaultPadding,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) =>
            ProductListItem(product: products[index]),
      );
    });
  }
}
