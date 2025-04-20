import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_management_flutter_app/features/user/bloc/user_bloc.dart';
import 'package:order_management_flutter_app/features/user/model/user_model.dart';

import '../../../../features/auth/bloc/auth_bloc.dart';
import '../../../../features/auth/services/auth_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserFetchProfileStarted());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
      // TODO: Thêm event để upload avatar lên server (nếu cần)
    }
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Mật khẩu hiện tại
                TextField(
                  controller: currentPwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 14),

                // Mật khẩu mới
                TextField(
                  controller: newPwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 14),

                // Xác nhận mật khẩu
                TextField(
                  controller: confirmPwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: xử lý đổi mật khẩu
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Xác nhận"),
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




  Widget _buildProfileTile(String label, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.blue),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserFetchProfileInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserFetchProfileSuccess) {
          final user = state.user;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : user.avatar.isNotEmpty
                                  ? NetworkImage(user.avatar)
                                  : const AssetImage(
                                          'assets/images/default_avatar.png')
                                      as ImageProvider,
                        ),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 18, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user.nickname,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Info fields
                  _buildProfileTile("ID", user.id, icon: Icons.perm_identity),
                  _buildProfileTile("Ngôn ngữ", user.languageCode ?? "Không có",
                      icon: Icons.language),
                  _buildProfileTile(
                      "Quyền",
                      user.permissions
                              ?.map((p) => p.permissionName)
                              .join(", ") ??
                          "Không có quyền",
                      icon: Icons.verified_user),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Đổi mật khẩu"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận đăng xuất'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn đăng xuất?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthLogoutStarted());
                                    await AuthConfig.clearToken();
                                    if (context.mounted) {
                                      context.go('/login');
                                    }
                                  },
                                  child: const Text('Đồng ý'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Đăng xuất"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        } else if (state is UserFetchProfileFailure) {
          return Center(child: Text('Lỗi: ${state.error}'));
        } else {
          return const Center(child: Text('Không có dữ liệu'));
        }
      },
    );
  }
}
