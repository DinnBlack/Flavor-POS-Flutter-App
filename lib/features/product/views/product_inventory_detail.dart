import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import '../model/product_model.dart';

class ProductInventoryDetail extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onClose;

  const ProductInventoryDetail({
    super.key,
    required this.product,
    required this.onClose,
  });

  @override
  _ProductInventoryDetailState createState() => _ProductInventoryDetailState();
}

class _ProductInventoryDetailState extends State<ProductInventoryDetail> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
        text: CurrencyFormatter.format(widget.product.price));
    _descriptionController =
        TextEditingController(text: widget.product.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Chi tiết sản phẩm",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: _isEditing
                            ? Colors.green.withOpacity(0.1)
                            : colors.primary.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: SvgPicture.asset(
                        _isEditing
                            ? 'assets/icons/check.svg'
                            : 'assets/icons/edit.svg',
                        colorFilter: ColorFilter.mode(
                            _isEditing ? Colors.green : colors.primary,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => widget.onClose(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/close.svg',
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Tên sản phẩm',
            controller: _nameController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Giá sản phẩm',
            controller: _priceController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Danh mục',
            controller: _priceController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Mô tả',
            controller: _descriptionController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (widget.product.image == null || widget.product.image!.isEmpty)
                  ? Image.network(
                'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.network(
                widget.product.image!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/product_default.jpg',
                  fit: BoxFit.cover,
                ),

              ),
            ),
          ),
          if (_isEditing) ...[
            const    SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child:  Text('Lưu thay đổi', style: TextStyle(color: colors.background, fontWeight: FontWeight.bold),),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              hintText: label,
              fillColor: Colors.grey[200],
              filled: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            enabled: isEditable,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label không thể để trống';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
