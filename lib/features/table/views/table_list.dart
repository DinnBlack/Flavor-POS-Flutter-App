import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/features/floor/model/floor_model.dart';
import 'package:order_management_flutter_app/features/table/views/widgets/table_list_item.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/dash_divider.dart';
import '../model/table_model.dart';

class TableList extends StatelessWidget {
  final List<TableModel> tables;
  final List<FloorModel> floors;

  const TableList({
    super.key,
    required this.tables,
    required this.floors,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> uniqueFloor =
        tables.map((table) => table.floorName).toSet();
    final bool isSingleFloor = uniqueFloor.length == 1;
    final colors = Theme.of(context).colorScheme;

    if (tables.isEmpty) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty_table.jpg',
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

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: isSingleFloor ? 1 : floors.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, floorIndex) {
          final floor = isSingleFloor
              ? floors.firstWhere((floor) => floor.name == uniqueFloor.first)
              : floors[floorIndex];
          final floorTables =
              tables.where((table) => table.floorName == floor.name).toList();
          if (floorTables.isEmpty) {
            return const SizedBox.shrink();
          }

          bool isLastFloor = (isSingleFloor || floorIndex == floors.length - 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSingleFloor) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    floor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
              LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount;

                if (Responsive.isMobile(context)) {
                  crossAxisCount = 3;
                } else if (Responsive.isTablet(context)) {
                  crossAxisCount = 5;
                } else {
                  crossAxisCount = 6;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: floorTables.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, tableIndex) {
                    return TableListItem(table: floorTables[tableIndex]);
                  },
                );
              }),
              if (!isLastFloor) ...[
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DashDivider(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
