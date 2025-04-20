import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../bloc/table_bloc.dart';
import '../qr_code_generator.dart';
import '../../model/table_model.dart';

class TableListItem extends StatefulWidget {
  final TableModel table;

  const TableListItem({
    super.key,
    required this.table,
  });

  @override
  State<TableListItem> createState() => _TableListItemState();
}

class _TableListItemState extends State<TableListItem> {
  void _showPopupMenu(
      BuildContext context, TableModel table, Offset position) async {
    final colors = Theme.of(context).colorScheme;

    final isReserved = table.status == 'RESERVED';

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem<String>(
          value: 'toggleStatus',
          child: Text(
            isReserved ? "Mở bàn" : "Đóng bàn",
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'qrCode',
          child: Text(
            "Mã QR bàn",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            "Xóa bàn",
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
      if (selectedValue != null) {
        switch (selectedValue) {
          case 'toggleStatus':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final action = isReserved ? 'mở' : 'đóng';
                return AlertDialog(
                  title: Text('Xác nhận $action bàn'),
                  content: Text(
                      'Bạn có chắc chắn muốn $action bàn ${table.number}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (isReserved) {
                          context.read<TableBloc>().add(
                              TableUpdateAvailableStarted(tableId: table.id));
                        } else {
                          context.read<TableBloc>().add(
                              TableUpdateReservedStarted(tableId: table.id));
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ],
                );
              },
            );
            break;
          case 'qrCode':
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 450,
                  child: QRCodeGenerator(
                    table: table,
                  ),
                ),
              ),
            );
            break;
          case 'delete':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Xác nhận xóa bàn'),
                  content: Text(
                      'Bạn có chắc chắn muốn xóa bàn ${table.number} này?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<TableBloc>()
                            .add(TableDeleteStarted(tableId: table.id));
                        Navigator.of(context).pop();
                      },
                      child: const Text('Xóa'),
                    ),
                  ],
                );
              },
            );
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color iconColor;
    if (widget.table.status == 'RESERVED') {
      backgroundColor = Colors.red.withOpacity(0.1);
      iconColor = Colors.red;
    } else if (widget.table.status == 'OCCUPIED') {
      backgroundColor = colors.primary.withOpacity(0.1);
      iconColor = colors.primary;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.1);
      iconColor = isDarkMode ? Colors.white : Colors.grey;
    }

    return BlocListener<TableBloc, TableState>(
      listener: (context, state) {
        if (state is TableDeleteSuccess) {
          CustomToast.showToast(
              context, 'Bàn ${widget.table.number} đã được xóa thành công!',
              type: ContentType.success);
        } else if (state is TableDeleteFailure) {
          CustomToast.showToast(
              context, 'Xóa bàn ${widget.table.number} thất bại!',
              type: ContentType.failure);
        }
      },
      child: GestureDetector(
        onLongPressStart: (LongPressStartDetails details) {
          _showPopupMenu(context, widget.table, details.globalPosition);
        },
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bàn ${widget.table.number}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 14,
                        color: iconColor,
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SvgPicture.asset(
                  'assets/icons/table.svg',
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: 50,
                  height: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '10:20 AM',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                        color: iconColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
