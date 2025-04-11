import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/controllers/menu_app_controller.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../widgets/toggle_switch.dart';

class TableHeader extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onToggle;

  const TableHeader({
    super.key,
    required this.selectedIndex,
    required this.onToggle,
  });

  final List<Map<String, String>> options = const [
    {"title": "Bàn", "icon": "assets/icons/product.svg"},
    {"title": "Tầng", "icon": "assets/icons/table-2.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context)) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
            const SizedBox(
              width: 10,
            )
          ],
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "Quản lý",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " / ${options[selectedIndex]["title"]}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ToggleSwitchWidget(
            options: options,
            onToggle: onToggle,
            selectedIndex: selectedIndex,
          ),
        ],
      ),
    );
  }
}
