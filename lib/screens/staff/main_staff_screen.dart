import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/invoice_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/order_history_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/product_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/table_screen.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/menu_app_controller.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/side_menu.dart';
import 'pages/activity/order_screen.dart';
import 'pages/dashboard/dashboard_screen.dart';

class MainStaffScreen extends StatefulWidget {
  const MainStaffScreen({super.key});

  @override
  State<MainStaffScreen> createState() => _MainStaffScreenState();
}

class _MainStaffScreenState extends State<MainStaffScreen> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    const DashboardScreen(),
    const OrderScreen(),
    const OrderHistoryScreen(),
    const InvoiceScreen(),
    const ProductScreen(),
    const TableScreen(),
  ];

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (!Responsive.isDesktop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
        onTabSelected: onTabSelected,
        selectedIndex: selectedIndex,
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(
                  onTabSelected: onTabSelected,
                  selectedIndex: selectedIndex,
                ),
              ),
            Expanded(
              flex: 5,
              child: pages[selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
