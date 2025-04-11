import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/features/floor/model/floor_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../table/services/table_service.dart';

class FloorListItem extends StatelessWidget {
  const FloorListItem({
    super.key,
    required this.floor,
    required this.isSelected,
    required this.onTap,
  });

  final FloorModel floor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color:
                isSelected ? colors.primary.withOpacity(0.1) : colors.secondary,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                floor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? colors.primary : null,
                  fontWeight: FontWeight.w500,
                ),
              ),

              /// 📌 Hiển thị số bàn trống bằng FutureBuilder
              if (floor.id == '')
                FutureBuilder<int>(
                  future: TableService().countTablesByStatus("AVAILABLE"),
                  builder: (context, snapshot) {
                    return Text(
                      "${snapshot.data} bàn trống",
                      style: Theme.of(context).textTheme.bodySmall!,
                    );
                  },
                )
              else
                FutureBuilder<int>(
                  future: TableService()
                      .countTablesByStatus("AVAILABLE", floorName: floor.name),
                  builder: (context, snapshot) {
                    return Text(
                      "${snapshot.data} bàn trống",
                      style: Theme.of(context).textTheme.bodySmall!,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
