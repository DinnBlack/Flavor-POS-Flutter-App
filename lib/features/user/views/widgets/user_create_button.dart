import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserCreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UserCreateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colors.secondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thêm nhân viên mới',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: SvgPicture.asset(
                'assets/icons/add.svg',
                colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
