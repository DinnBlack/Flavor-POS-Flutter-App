import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../bloc/cart_bloc.dart';
import '../../model/cart_item_model.dart';

class CartItem extends StatefulWidget {
  final CartItemModel cartItem;

  const CartItem({super.key, required this.cartItem});

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> with TickerProviderStateMixin {
  late TextEditingController _noteController;
  late ValueNotifier<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.cartItem.note ?? "");
    _isExpanded = ValueNotifier(false);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, child) {
        return GestureDetector(
          onTap: () => _isExpanded.value = !_isExpanded.value,
          child: Slidable(
            key: Key(widget.cartItem.product.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    context.read<CartBloc>().add(
                          CartRemoveProductStarted(
                            productId: widget.cartItem.product.id,
                          ),
                        );
                  },
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Xóa',
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (widget.cartItem.product.image == null ||
                                widget.cartItem.product.image!.isEmpty)
                            ? Image.asset(
                                'assets/images/default_food.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.cartItem.product.image!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cartItem.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                  widget.cartItem.product.price),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.cartItem.note?.isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  "${widget.cartItem.note}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionButton(Icons.remove, () {
                                    if (widget.cartItem.quantity > 1) {
                                      context.read<CartBloc>().add(
                                            CartUpdateProductQuantityStarted(
                                              productId:
                                                  widget.cartItem.product.id,
                                              newQuantity:
                                                  widget.cartItem.quantity - 1,
                                            ),
                                          );
                                    } else {
                                      context.read<CartBloc>().add(
                                            CartRemoveProductStarted(
                                                productId:
                                                    widget.cartItem.product.id),
                                          );
                                    }
                                  }),
                                  const SizedBox(width: 5),
                                  Text("${widget.cartItem.quantity}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 5),
                                  _buildActionButton(Icons.add, () {
                                    context.read<CartBloc>().add(
                                          CartUpdateProductQuantityStarted(
                                            productId:
                                                widget.cartItem.product.id,
                                            newQuantity:
                                                widget.cartItem.quantity + 1,
                                          ),
                                        );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isExpanded ? _buildNoteInput() : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _noteController,
        builder: (context, value, child) {
          bool hasChanged =
              value.text.trim() != (widget.cartItem.note ?? "").trim();
          return TextField(
            controller: _noteController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              filled: true,
              hintText: 'Ghi chú',
              hintStyle: const TextStyle(fontSize: 12),
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.check_circle,
                    color: hasChanged ? Colors.green : Colors.grey),
                onPressed: hasChanged
                    ? () {
                        context.read<CartBloc>().add(
                              CartUpdateProductNoteStarted(
                                productId: widget.cartItem.product.id,
                                note: _noteController.text.trim(),
                              ),
                            );
                        _isExpanded.value = false;
                      }
                    : null,
              ),
            ),
            style: const TextStyle(
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
