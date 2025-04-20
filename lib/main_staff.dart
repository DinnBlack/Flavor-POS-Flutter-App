import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/auth/views/login_screen.dart';
import 'package:order_management_flutter_app/features/invoice/bloc/invoice_bloc.dart';
import 'package:order_management_flutter_app/features/user/bloc/user_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/controllers/menu_app_controller.dart';
import 'core/utils/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/services/auth_config.dart';
import 'features/bill/bloc/bill_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/category/bloc/category_bloc.dart';
import 'features/floor/bloc/floor_bloc.dart';
import 'features/order/bloc/order_bloc.dart';
import 'features/product/bloc/product_bloc.dart';
import 'features/shift/bloc/shift_bloc.dart';
import 'features/table/bloc/table_bloc.dart';
import 'screens/staff/main_staff_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await AuthConfig.getToken();
  final isTokenExpired = await AuthConfig.isTokenExpired();
  if (isTokenExpired) {
    await AuthConfig.clearToken();
  }

  runApp(
    StaffApp(isLoggedIn: token != null && !isTokenExpired),
  );
}

class StaffApp extends StatefulWidget {
  final bool isLoggedIn;

  const StaffApp({super.key, required this.isLoggedIn});

  @override
  State<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends State<StaffApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: widget.isLoggedIn ? '/main' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) {
            return const MainStaffScreen();
          },
        ),
        GoRoute(
          path: '/logout',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MenuAppController()),
        BlocProvider(create: (context) => ProductBloc()),
        BlocProvider(create: (context) => CartBloc()),
        BlocProvider(create: (context) => TableBloc()),
        BlocProvider(create: (context) => FloorBloc()),
        BlocProvider(create: (context) => OrderBloc()),
        BlocProvider(create: (context) => BillBloc()),
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => CategoryBloc()),
        BlocProvider(create: (context) => InvoiceBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => ShiftBloc()),
      ],
      child: MaterialApp.router(
        title: 'Flavor Customer',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
