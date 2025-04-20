import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:order_management_flutter_app/features/user/model/user_model.dart';
import 'package:order_management_flutter_app/features/user/services/user_service.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/invoice_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/order_history_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/shift_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/dashboard/profile_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/product_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/table_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/user_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/order_screen.dart';
import 'package:order_management_flutter_app/screens/staff/pages/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/menu_app_controller.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/side_menu.dart';
import 'pages/activity/activity_chef_screen.dart';
import 'pages/activity/activity_waiter_screen.dart';

class MainStaffScreen extends StatefulWidget {
  const MainStaffScreen({super.key});

  @override
  State<MainStaffScreen> createState() => _MainStaffScreenState();
}

class _MainStaffScreenState extends State<MainStaffScreen> {
  int selectedIndex = 0;
  late UserModel user;
  List<Widget> pages = [];
  bool isLoading = true;
  late String role;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user = await UserService().getProfile();
    setState(() {
      role = user.nickname;

      if (role == 'waiter') {
        pages = [
          const DashboardScreen(),
          const ActivityWaiterScreen(),
          const ProfileScreen(),
        ];
      } else if (role == 'chef') {
        pages = [
          const ActivityChefScreen(),
          const ProfileScreen(),
        ];
      }

      else {
        pages = [
          const DashboardScreen(),
          const OrderScreen(),
          const OrderHistoryScreen(),
          const InvoiceScreen(),
          const ShiftScreen(),
          const ProductScreen(),
          const TableScreen(),
          const UserScreen(),
        ];
      }

      isLoading = false;
    });
  }

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: (role == 'waiter' || role == 'chef')
          ? null
          : SideMenu(
        onTabSelected: onTabSelected,
        selectedIndex: selectedIndex,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!['waiter', 'chef'].contains(role) && Responsive.isDesktop(context))
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
      bottomNavigationBar: (role == 'waiter' || role == 'chef')
          ? Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GNav(
          gap: 8,
          backgroundColor: Colors.white,
          color: Colors.grey[600],
          activeColor: Colors.white,
          tabBackgroundColor: Colors.blue.shade400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          selectedIndex: selectedIndex,
          onTabChange: onTabSelected,
          tabs: role == 'waiter'
              ? const [
            GButton(
              icon: Icons.dashboard,
              text: 'Bán hàng',
            ),
            GButton(
              icon: Icons.receipt_long,
              text: 'Hoạt động',
            ),
            GButton(
              icon: Icons.person,
              text: 'Cá nhân',
            ),
          ]
              : const [
            GButton(
              icon: Icons.receipt_long,
              text: 'Hoạt động',
            ),
            GButton(
              icon: Icons.person,
              text: 'Cá nhân',
            ),
          ],
        ),
      )
          : null,
    );
  }
}
