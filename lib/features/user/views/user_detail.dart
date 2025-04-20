import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../model/user_model.dart';

class UserDetail extends StatefulWidget {
  final UserModel user;
  final VoidCallback onClose;

  const UserDetail({
    super.key,
    required this.user,
    required this.onClose,
  });

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _permissionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nickname);
    _emailController = TextEditingController(text:widget.user.email);
    _permissionController =
        TextEditingController(text: 'Nhân viên');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _permissionController.dispose();
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
            label: 'Tên nhân viên',
            controller: _nameController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Quyền',
            controller: _permissionController,
            isEditable: _isEditing,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (widget.user.avatar.isEmpty)
                  ? Image.network(
                'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.network(
                widget.user.avatar,
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
