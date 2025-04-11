import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

class DashDivider extends StatelessWidget {
  const DashDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Dash(
            direction: Axis.horizontal,
            length: constraints.maxWidth,
            dashLength: 8,
            dashColor: Colors.grey.shade400,
          );
        },
      ),
    );
  }
}