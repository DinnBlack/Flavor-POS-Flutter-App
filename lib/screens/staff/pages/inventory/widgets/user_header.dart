import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/controllers/menu_app_controller.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../widgets/toggle_switch.dart';

class UserHeader extends StatelessWidget {

  const UserHeader({
    super.key,
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
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Quản lý",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " / Nhân viên",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
