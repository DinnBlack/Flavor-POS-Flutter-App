import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_management_flutter_app/features/category/model/category_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/product/services/product_service.dart'; // Import the service

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 60,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color:
                isSelected ? colors.primary.withOpacity(0.1) : colors.secondary,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? colors.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
              FutureBuilder<int>(
                future: ProductService().getTotalProductCount(
                    categoryId: category.id.isEmpty ? null : category.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "${snapshot.data} sản phẩm",
                      style: Theme.of(context).textTheme.bodySmall!,
                    );
                  } else {
                    return  Text(
                      "0 sản phẩm",
                      style: Theme.of(context).textTheme.bodySmall!,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
