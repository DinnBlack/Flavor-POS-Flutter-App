import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/core/utils/constants.dart';
import 'package:order_management_flutter_app/features/shift/views/widgets/shift_list_item.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/id_formatter.dart';
import '../../invoice/views/invoice_list.dart';
import '../model/shift_model.dart';

class ShiftList extends StatefulWidget {
  final List<ShiftModel> shifts;

  const ShiftList({super.key, required this.shifts});

  @override
  _ShiftListState createState() => _ShiftListState();
}

class _ShiftListState extends State<ShiftList> {
  ShiftModel? selectedShift;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    bool isMobile = Responsive.isMobile(context);

    if (selectedShift != null) {
      // Show shift details view
      return _buildShiftDetailsView(selectedShift!);
    }

    if (widget.shifts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isMobile ? colors.background : colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/4076/4076549.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vui lòng tạo đơn hàng mới để hiển thị ở đây.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isMobile ? colors.background : colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isMobile ? _buildMobileList() : _buildDataTable(context, colors),
    );
  }

  Widget _buildShiftDetailsView(ShiftModel shift) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedShift = null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/arrow_left.svg',
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colors.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Tổng hợp hóa đơn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: _buildDetailRow(
                              "Mã ca:", formatShiftId(selectedShift!.id))),
                      Expanded(
                        flex: 1,
                        child: _buildDetailRow("Thời gian mở:",
                            formatDateTime(selectedShift!.startTime)),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildDetailRow(
                          "Thời gian đóng:",
                          selectedShift!.endTime != null
                              ? formatDateTime(selectedShift!.endTime!)
                              : '--:--',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(child: InvoiceList(invoices: shift.invoices)),
          ],
        ),
      ),
    );
  }

// Helper method to display detail rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: widget.shifts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedShift = widget.shifts[index];
            });
          },
          child: ShiftListItem(shift: widget.shifts[index]),
        );
      },
    );
  }

  void _showPopupMenu(
      BuildContext context, ShiftModel shift, Offset position) async {
    final colors = Theme.of(context).colorScheme;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem<String>(
          value: 'view',
          child: Text(
            "Tổng hợp hóa đơn",
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
          case 'view':
            setState(() {
              selectedShift = shift;
            });
            break;
        }
      }
    });
  }

  String formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return DateFormat('HH:mm dd/MM/yyyy').format(localTime);
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
          label: _buildColumnHeader('Mã ca', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thời gian mở', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thời gian đóng', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Người quản lý', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Tổng hóa đơn', colors),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: _buildColumnHeader('Doanh thu', colors),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: _buildColumnHeader('Thao tác', colors),
          size: ColumnSize.S,
        ),
      ],
      rows: widget.shifts.map((shift) {
        return DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(
                  formatShiftId(shift.id),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  formatDateTime(shift.startTime),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            DataCell(Center(
              child: Text(
                shift.endTime != null
                    ? formatDateTime(shift.endTime!)
                    : '--:--',
                style: const TextStyle(fontSize: 12),
              ),
            )),
            DataCell(
              Center(
                child: Text(
                  shift.managerName,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  '${shift.totalInvoices}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  CurrencyFormatter.format(shift.totalRevenue),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            DataCell(
              Center(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showPopupMenu(context, shift, details.globalPosition);
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
