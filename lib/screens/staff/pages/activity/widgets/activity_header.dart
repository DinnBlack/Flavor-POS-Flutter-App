import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/controllers/menu_app_controller.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../widgets/toggle_switch.dart';

class ActivityHeader extends StatelessWidget {
  final String title;

  const ActivityHeader({
    super.key,
    required this.title,
  });


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
          if (!Responsive.isMobile(context))
              Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Hoạt động",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " / $title",
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
          // ToggleSwitchWidget(
          //   options: options,
          //   onToggle: onToggle,
          //   selectedIndex: selectedIndex,
          // ),
        ],
      ),
    );
  }
}
