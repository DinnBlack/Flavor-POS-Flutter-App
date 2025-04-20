import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/category/bloc/category_bloc.dart';
import 'package:order_management_flutter_app/features/category/model/category_model.dart';
import '../../bloc/product_bloc.dart';

class ProductInventoryFilter extends StatefulWidget {
  final Function(String) onSortOptionSelected;

  const ProductInventoryFilter({
    super.key,
    required this.onSortOptionSelected,
  });

  @override
  State<ProductInventoryFilter> createState() => _ProductInventoryFilterState();
}

class _ProductInventoryFilterState extends State<ProductInventoryFilter> {
  String selectedCategory = '';
  String selectedSortOption = 'Mặc định';

  final List<String> sortOptions = [
    'Mặc định',
    'Giá tăng dần',
    'Giá giảm dần',
    'Tên A-Z',
    'Tên Z-A',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Dropdown Sắp xếp
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedSortOption,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedSortOption = newValue;
                });
                widget.onSortOptionSelected(newValue);
              }
            },
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              elevation: 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: colors.onPrimary,
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
            items: sortOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 10),
        // Dropdown Category
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryFetchInProgress) {
              return const CircularProgressIndicator();
            } else if (state is CategoryFetchFailure) {
              return Text('Error: ${state.error}');
            } else if (state is CategoryFetchSuccess) {
              final List<CategoryModel> categories = [
                const CategoryModel(id: '', name: "Tất cả"),
                ...state.categories,
              ];

              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue ?? '';
                    });
                    if (selectedCategory != '') {
                      context.read<ProductBloc>().add(ProductFetchStarted(
                            categoryId: selectedCategory,
                          ));
                    } else {
                      context.read<ProductBloc>().add(ProductFetchStarted());
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    elevation: 0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: colors.onPrimary,
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
                  items: categories.map((CategoryModel category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name,
                          style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
