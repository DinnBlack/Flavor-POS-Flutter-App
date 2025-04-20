import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_toast.dart';
import '../bloc/user_bloc.dart';
import '../model/user_model.dart';

class UserList extends StatelessWidget {
  final List<UserModel> users;
  final bool isCompact;
  final Function(UserModel) onUserSelected;

  const UserList({
    super.key,
    required this.users,
    required this.isCompact,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? colors.background : colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildDataTable(context, colors),
    );
  }

  void _showPopupMenu(
      BuildContext context, UserModel user, Offset position) async {
    final colors = Theme.of(context).colorScheme;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem<String>(
          value: 'view',
          child: Text(
            "Xem chi tiết",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text(
            "Chỉnh sửa",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            "Xóa sản phẩm",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
    ).then((selectedValue) {
      // Handle the selected value
      if (selectedValue != null) {
        switch (selectedValue) {
          case 'view':
            print('View details');
            break;
          case 'edit':
            print('Edit user');
            break;
          case 'delete':
            _showDeleteConfirmationDialog(context, user);
            break;
        }
      }
    });
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa nhân viên ${user.nickname}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<UserBloc>()
                    .add(UserDeleteStarted(userId: user.id));
                Navigator.of(context).pop();
                CustomToast.showToast(context, "Sản phẩm đã được xóa!",
                    type: ContentType.success);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context, ColorScheme colors) {
    if (users.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty_product.jpg',
                height: 300,
                width: 300,
              ),
              Text(
                'Chưa có món ăn nào',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Hãy tạo món ăn mới để bắt đầu.',
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DataTable2(
      columnSpacing: 10,
      horizontalMargin: 10,
      dataRowHeight: 70,
      dividerThickness: 0,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      columns: [
        DataColumn2(
            label: _buildColumnHeader("Ảnh", colors), size: ColumnSize.S),
        DataColumn2(
            label: _buildColumnHeader("Tên nhân viên", colors),
            size: ColumnSize.M),
        DataColumn2(
            label: _buildColumnHeader("Quyền", colors), size: ColumnSize.S),
        if (!isCompact)
          DataColumn2(
              label: _buildColumnHeader("Chi tiết", colors),
              size: ColumnSize.S),
      ],
      rows: users.map((user) {
        return DataRow(
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (user.avatar.isEmpty)
                        ? Image.network(
                      'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
                      width: 80,
                      height: 60,
                      fit: BoxFit.contain,
                    )
                        : Image.network(
                      user.avatar,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/user_default.jpg',
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildShimmerSkeleton();
                      },
                    ),
                  ),
                ),
              ),

            ),
            DataCell(
              GestureDetector(
                onTap: () => onUserSelected(user),
                child: Center(child: Text(user.nickname)),
              ),
            ),
            const DataCell(
                Center(child: Text('Nhân viên'))),
            if (!isCompact)
              DataCell(
                Center(
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      _showPopupMenu(context, user, details.globalPosition);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/more.svg',
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              )
          ],
        );
      }).toList(),
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

  Widget _buildColumnHeader(String title, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colors.background,
      ),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
