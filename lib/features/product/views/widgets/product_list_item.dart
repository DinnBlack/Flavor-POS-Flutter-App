import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../model/product_model.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;

  const ProductListItem({
    super.key,
    required this.product,
  });

  void _addToCart(BuildContext context) {
    context.read<CartBloc>().add(CartAddProductStarted(product: product));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () => _addToCart(context),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (product.image == null || product.image!.isEmpty)
                    ? Center(
                        child: Image.asset(
                          'assets/images/default_food.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_food.jpg',
                          fit: BoxFit.cover,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildShimmerSkeleton();
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              CurrencyFormatter.format(product.price),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
