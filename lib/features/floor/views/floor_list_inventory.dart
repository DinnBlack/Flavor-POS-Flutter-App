import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/table/model/table_model.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../table/services/table_service.dart';
import '../bloc/floor_bloc.dart';
import '../model/floor_model.dart';

class FloorListInventory extends StatelessWidget {
  final List<FloorModel> floors;
  final Function(FloorModel) onFloorSelected;
  final List<TableModel> tables;

  const FloorListInventory({
    super.key,
    required this.floors,
    required this.onFloorSelected, required this.tables,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool isMobile = Responsive.isMobile(context);

    return BlocListener<FloorBloc, FloorState>(
      listener: (context, state) {
        if (state is FloorDeleteSuccess) {
          CustomToast.showToast(context, "Xóa tầng thành công!",
              type: ContentType.success);
        } else if (state is FloorDeleteFailure) {
          CustomToast.showToast(context, "Xóa tầng thất bại!",
              type: ContentType.failure);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isMobile ? colors.background : colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildDataTable(context, colors),
      ),
    );
  }

  void _showPopupMenu(
      BuildContext context, FloorModel floor, Offset position) async {
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
            "Chỉnh sửa sản phẩm",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            "Xóa tầng",
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
          width: 1, // Độ dày của border
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
            print('Edit floor');
            break;
          case 'delete':
            _showDeleteConfirmationDialog(context, floor);
            break;
        }
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, FloorModel floor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
              "Bạn có chắc chắn muốn xóa tầng ${floor.name}?.\nXóa tầng sẽ xóa tất cả các bàn hiện có trong tầng này."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                context.read<FloorBloc>().add(FloorDeleteStarted(id: floor.id));
                Navigator.of(context).pop();
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context, ColorScheme colors) {
    if (floors.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty_floor.jpg',
                height: 300,
                width: 300,
              ),
              Text(
                'Chưa có danh mục nào',
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Hãy tạo một danh mục mới để bắt đầu.',
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
            label: _buildColumnHeader("Tầng", colors), size: ColumnSize.M),
        DataColumn2(
            label: _buildColumnHeader("Số lượng bàn", colors),
            size: ColumnSize.S),
        DataColumn2(
            label: _buildColumnHeader("Chi tiết", colors), size: ColumnSize.S),
      ],
      rows: floors.map((floor) {
        return DataRow(
          cells: [
            DataCell(
              GestureDetector(
                onTap: () => onFloorSelected(floor),
                child: Center(child: Text(floor.name)),
              ),
            ),
            DataCell(
              Center(
                child: GestureDetector(
                  onTap: () => onFloorSelected(floor),
                  child: FutureBuilder<int>(
                    future: TableService()
                        .countTablesByStatus(null, floorName: floor.name, listTable: tables),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return Text(
                        "${snapshot.data} bàn",
                      );
                    },
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showPopupMenu(context, floor, details.globalPosition);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/more.svg',
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
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

