import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/services/auth_config.dart';
import '../../features/table/bloc/table_bloc.dart';
import '../../features/user/model/user_model.dart';
import '../../features/user/services/user_service.dart';
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
  late Future<UserModel> _userFuture;

  List<bool> _isTileExpanded = [false, false];
  final List<GlobalKey<ExpansionTileCardState>> _tileKeys = [
    GlobalKey<ExpansionTileCardState>(),
    GlobalKey<ExpansionTileCardState>(),
  ];

  void _handleTileTap(int index) {
    setState(() {
      for (int i = 0; i < _isTileExpanded.length; i++) {
        if (i != index && _isTileExpanded[i]) {
          _tileKeys[i].currentState?.collapse();
          _isTileExpanded[i] = false;
        }
      }

      final currentTile = _tileKeys[index].currentState;
      if (_isTileExpanded[index]) {
        currentTile?.collapse();
      } else {
        currentTile?.expand();
      }

      _isTileExpanded[index] = !_isTileExpanded[index];
    });
  }

  @override
  void initState() {
    super.initState();
    _userFuture = UserService().getProfile(); // Asynchronous call
  }

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
        child: FutureBuilder<UserModel>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              UserModel user = snapshot.data!;
              return Column(
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerListTile(
                          title: "Bán hàng",
                          svgSrc: "assets/icons/menu_dashboard.svg",
                          press: () {
                            context
                                .read<TableBloc>()
                                .add(TableFetchStarted(status: 'AVAILABLE'));
                            widget.onTabSelected(0);
                          },
                          isSelected: widget.selectedIndex == 0,
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.grey,
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  secondary: Colors.grey,
                                ),
                          ),
                          child: ExpansionTileCard(
                            key: _tileKeys[0],
                            initiallyExpanded:
                                [1, 2, 3, 4].contains(widget.selectedIndex),
                            baseColor: Colors.transparent,
                            leading: _buildLeadingIcon(context, [1, 2, 3, 4]),
                            title: const Text(
                              "Hoạt động",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            elevation: 0,
                            onExpansionChanged: (isExpanded) {
                              if (isExpanded) _handleTileTap(0);
                            },
                            children: [
                              SubMenuTile(
                                  title: "Đơn hàng",
                                  press: () => widget.onTabSelected(1),
                                  isSelected: widget.selectedIndex == 1),
                              SubMenuTile(
                                  title: "Lịch sử đơn hàng",
                                  press: () => widget.onTabSelected(2),
                                  isSelected: widget.selectedIndex == 2),
                              SubMenuTile(
                                  title: "Hóa đơn",
                                  press: () => widget.onTabSelected(3),
                                  isSelected: widget.selectedIndex == 3),
                              if (user.nickname != 'waiter')
                                SubMenuTile(
                                    title: "Ca trực",
                                    press: () => widget.onTabSelected(4),
                                    isSelected: widget.selectedIndex == 4),
                            ],
                          ),
                        ),
                        if (user.nickname != 'waiter')
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.grey,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              colorScheme:
                                  Theme.of(context).colorScheme.copyWith(
                                        secondary: Colors.grey,
                                      ),
                            ),
                            child: ExpansionTileCard(
                              key: _tileKeys[1],
                              initiallyExpanded:
                                  [5, 6, 7].contains(widget.selectedIndex),
                              baseColor: Colors.transparent,
                              leading: _buildLeadingIcon(context, [5, 6, 7]),
                              title: const Text(
                                "Quản lý",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              elevation: 0,
                              onExpansionChanged: (isExpanded) {
                                if (isExpanded) _handleTileTap(1);
                              },
                              children: [
                                SubMenuTile(
                                    title: "Sản phẩm",
                                    press: () => widget.onTabSelected(5),
                                    isSelected: widget.selectedIndex == 5),
                                SubMenuTile(
                                    title: "Bàn",
                                    press: () => widget.onTabSelected(6),
                                    isSelected: widget.selectedIndex == 6),
                                SubMenuTile(
                                    title: "Nhân viên",
                                    press: () => widget.onTabSelected(7),
                                    isSelected: widget.selectedIndex == 7),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận đăng xuất'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn đăng xuất?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthLogoutStarted());
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
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/logout.svg',
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      title: const Text(
                        "Đăng xuất",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Container(); // Return an empty container if no data
          },
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, List<int> selectedIndexList) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = selectedIndexList.contains(widget.selectedIndex);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor
            : (isDarkMode ? darkSecondaryColor : lightSecondaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        selectedIndexList == [1, 2, 3, 4]
            ? 'assets/icons/menu_tran.svg'
            : 'assets/icons/menu_task.svg',
        height: 20,
        colorFilter: ColorFilter.mode(
          isSelected
              ? Colors.white
              : (isDarkMode ? Colors.white : Colors.black),
          BlendMode.srcIn,
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
          style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : null,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : null),
        ),
      ),
    );
  }
}
