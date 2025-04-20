import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/page/user_page.dart';
import 'package:order_management_flutter_app/screens/staff/pages/inventory/widgets/user_header.dart';
import 'page/category_page.dart';
import 'page/product_page.dart';
import 'widgets/product_header.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                UserHeader(),
                Expanded(
                  child: UserPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
