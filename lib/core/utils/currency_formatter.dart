import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)}đ";
  }

  static double stringToDouble(String formattedString) {
    String cleanString =
        formattedString.replaceAll('đ', '').replaceAll('.', '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}

class PriceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  PriceTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Giá sản phẩm *',
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        hintText: hintText,
        fillColor: colors.background,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Giá sản phẩm không thể để trống';
            }
            final price =
                double.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
            if (price == null) {
              return 'Giá phải là một số hợp lệ';
            }
            return null;
          },
      onChanged: (value) {
        if (value.isEmpty) {
          return;
        }

        // Remove non-numeric characters
        String sanitizedValue = value.replaceAll(RegExp(r'[^\d]'), '');
        double? price = double.tryParse(sanitizedValue);

        if (price != null) {
          String formattedPrice = CurrencyFormatter.format(price);
          controller.value = TextEditingValue(
            text: formattedPrice,
            selection:
                TextSelection.collapsed(offset: formattedPrice.length - 1),
          );
        }
      },
      onEditingComplete: () {
        String value = controller.text;
        String sanitizedValue = value.replaceAll(RegExp(r'[^\d]'), '');
        double? price = double.tryParse(sanitizedValue);

        if (price != null) {
          String formattedPrice = CurrencyFormatter.format(price);
          controller.text = formattedPrice;
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
