import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';

class ToggleSwitchWidget extends StatelessWidget {
  final Function(int) onToggle;
  final int selectedIndex;
  final List<Map<String, String>> options;

  const ToggleSwitchWidget({
    super.key,
    required this.onToggle,
    required this.selectedIndex,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onToggle(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMobile)
                    SvgPicture.asset(
                      options[index]["icon"]!,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : colors.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  if (!isMobile) ...[
                    Text(
                      options[index]["title"]!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : colors.onSurface,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold :null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
