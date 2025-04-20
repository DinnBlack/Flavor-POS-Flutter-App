import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_toast.dart';
import '../bloc/user_bloc.dart';

class UserCreateForm extends StatefulWidget {
  const UserCreateForm({super.key});

  @override
  State<UserCreateForm> createState() => _UserCreateFormState();
}

class _UserCreateFormState extends State<UserCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRole = 'manager';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserCreateSuccess) {
          Navigator.pop(context);
          CustomToast.showToast(context, "Nhân viên đã được tạo thành công!",
              type: ContentType.success);
        } else if (state is UserCreateFailure) {
          CustomToast.showToast(context, "Có lỗi xảy ra: ${state.error}",
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
                  'Thêm nhân viên',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // Tên danh mục nhập vào
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintText: 'Nhập email',
                    fillColor: colors.background,
                    filled: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      value: _selectedRole,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        elevation: 0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            )),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'manager', child: Text('Quản lý')),
                        DropdownMenuItem(value: 'chef', child: Text('Đầu bếp')),
                        DropdownMenuItem(
                            value: 'waiter', child: Text('Phục vụ')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Các nút Huỷ và Thêm mới
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
                          context.read<UserBloc>().add(
                                UserCreateStarted(
                                  email: _nameController.text.trim(),
                                  permission: _selectedRole ?? 'manager',
                                ),
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
