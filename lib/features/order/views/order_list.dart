import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/core/utils/constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/id_formatter.dart';
import '../model/order_detail_model.dart';
import '../model/order_model.dart';
import 'order_detail.dart';
import 'order_list_item.dart';

class OrderList extends StatelessWidget {
  final List<OrderModel> orders;

  const OrderList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? colors.background : colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isMobile ? _buildMobileList() : _buildDataTable(context, colors),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderListItem(order: orders[index]);
      },
    );
  }

  void _showPopupMenu(
      BuildContext context, OrderModel order, Offset position) async {
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: OrderDetail(order: order)),
                );
              },
            );
            break;
        }
      }
    });
  }

  Widget _buildDataTable(BuildContext context, ColorScheme colors) {
    return DataTable2(
      columnSpacing: 10,
      horizontalMargin: 10,
      dataRowHeight: 60,
      dividerThickness: 0,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      columns: [
        DataColumn2(
          label: _buildColumnHeader('Thời gian tạo', colors),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: _buildColumnHeader('Mã đơn', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thông tin khách hàng', colors),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: _buildColumnHeader('Tổng tiền', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Trạng thái', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thao tác', colors),
          size: ColumnSize.S,
        ),
      ],
      rows: orders.map((order) {
        return DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(order.createdAt),
              ),
            ),
            DataCell(Center(child: Text(formatIdToBase36Short(order.id)))),
            const DataCell(Center(child: Text('Khách lẻ'))),
            DataCell(
                Center(child: Text(CurrencyFormatter.format(order.total)))),
            DataCell(
              Center(
                child: _buildStatusCell(order.status),
              ),
            ),
            DataCell(
              Center(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showPopupMenu(context, order, details.globalPosition);
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
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusCell(String status) {
    String displayText = '';
    Color backgroundColor = Colors.grey;

    switch (status.toUpperCase()) {
      case 'REJECTION':
        displayText = 'Đã hủy';
        backgroundColor = Colors.red;
        break;
      case 'APPROVED':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.orange;
        break;
      case 'READY_TO_DELIVER':
        displayText = 'Đang hoạt động';
        backgroundColor = Colors.orange;
        break;
      case 'DELIVERED':
        displayText = 'Hoàn thành';
        backgroundColor = Colors.green;
        break;
      case 'PENDING':
        displayText = 'Chờ xác nhận';
        backgroundColor = Colors.blue;
        break;
      default:
        displayText = 'Không xác định';
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: backgroundColor,
        ),
        textAlign: TextAlign.center,
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
