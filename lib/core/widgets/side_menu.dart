import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/services/auth_config.dart';
import '../utils/theme.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  const SideMenu({
    super.key,
    required this.onTabSelected,
    required this.selectedIndex,
  });

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          context.go('/login');
        }
      },
      child: Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            GestureDetector(
              onTap: () async {
                String? token = await AuthConfig.getToken();
                print(token);
              },
              child: DrawerHeader(
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
            DrawerListTile(
              title: "Bán hàng",
              svgSrc: "assets/icons/menu_dashboard.svg",
              press: () => widget.onTabSelected(0),
              isSelected: widget.selectedIndex == 0,
            ),
            ExpansionTileCard(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: [1, 2, 3].contains(widget.selectedIndex)
                      ? Theme.of(context).primaryColor
                      : (isDarkMode ? darkSecondaryColor : lightSecondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/icons/menu_tran.svg',
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    [1, 2, 3].contains(widget.selectedIndex)
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              title: Text(
                "Hoạt động",
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                ),
              ),
              elevation: 0,

              children: [
                SubMenuTile(
                  title: "Đơn hàng",
                  press: () => widget.onTabSelected(1),
                  isSelected: widget.selectedIndex == 1,
                ),
                SubMenuTile(
                  title: "Lịch sử đơn hàng",
                  press: () => widget.onTabSelected(2),
                  isSelected: widget.selectedIndex == 2,
                ),
                SubMenuTile(
                  title: "Hóa đơn",
                  press: () => widget.onTabSelected(3),
                  isSelected: widget.selectedIndex == 3,
                ),
              ],
            ),
            ExpansionTileCard(
              elevation: 0,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:[4, 5].contains(widget.selectedIndex)
                      ? Theme.of(context).primaryColor
                      : (isDarkMode ? darkSecondaryColor : lightSecondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/icons/menu_task.svg',
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    [4, 5].contains(widget.selectedIndex)
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              title: Text(
                "Quản lý",
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                ),
              ),
              children: [
                SubMenuTile(
                  title: "Sản phẩm",
                  press: () => widget.onTabSelected(4),
                  isSelected: widget.selectedIndex == 4,
                ),
                SubMenuTile(
                  title: "Bàn",
                  press: () => widget.onTabSelected(5),
                  isSelected: widget.selectedIndex == 5,
                ),
              ],
            ),
            const Spacer(),
            DrawerListTile(
              title: "Đăng xuất",
              svgSrc: "assets/icons/logout.svg",
              press: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Xác nhận đăng xuất'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () async {
                            context.read<AuthBloc>().add(AuthLogoutStarted());
                            await AuthConfig.clearToken();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: const Text('Đồng ý'),
                        ),
                      ],
                    );
                  },
                );
              },
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.isSelected,
  });

  final String title, svgSrc;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: press,
      horizontalTitleGap: 10,
      tileColor:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (isDarkMode ? darkSecondaryColor : lightSecondaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          svgSrc,
          height: 20,
          colorFilter: ColorFilter.mode(
            isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white : Colors.black),
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected
              ? Theme.of(context).primaryColor
              : (isDarkMode ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class SubMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback press;
  final bool isSelected;

  const SubMenuTile({
    super.key,
    required this.title,
    required this.press,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Theme.of(context).primaryColor: null, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : null),
        ),
      ),
    );
  }
}
