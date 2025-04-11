import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FloorEditButton extends StatelessWidget {
  const FloorEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colors.secondary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chỉnh sửa tầng',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(5),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                colorFilter:
                    const ColorFilter.mode(Colors.green, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
