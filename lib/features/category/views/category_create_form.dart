import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_toast.dart';
import '../bloc/category_bloc.dart';

class CategoryCreateForm extends StatefulWidget {
  const CategoryCreateForm({super.key});

  @override
  State<CategoryCreateForm> createState() => _CategoryCreateFormState();
}

class _CategoryCreateFormState extends State<CategoryCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryCreateInProgress) {
          Navigator.pop(context);
        } else if (state is CategoryCreateSuccess) {
          CustomToast.showToast(context, "Tạo danh mục thành công!",
              type: ContentType.success);
        } else if (state is CategoryCreateFailure) {
          CustomToast.showToast(
              context, "Tạo danh mục thất bại do danh mục này đã có sẵn!",
              type: ContentType.failure);
        }
      },
      child: Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Thêm mới danh mục sản phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintText: 'Nhập tên danh mục',
                    fillColor: colors.background,
                    filled: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Huỷ'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CategoryBloc>().add(
                                CategoryCreateStarted(
                                    categoryName: _nameController.text.trim()),
                              );
                        }
                      },
                      child: const Text('Thêm mới'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
