import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/table/services/table_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/controllers/menu_app_controller.dart';
import 'core/utils/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/bill/bloc/bill_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/category/bloc/category_bloc.dart';
import 'features/floor/bloc/floor_bloc.dart';
import 'features/order/bloc/order_bloc.dart';
import 'features/product/bloc/product_bloc.dart';
import 'features/table/bloc/table_bloc.dart';
import 'features/table/model/table_model.dart';
import 'screens/customer/customer_pages/scan_qr_page.dart';
import 'screens/customer/customer_pages/selection_page.dart';

void main() {
  runApp(
    kReleaseMode
        ? const CustomerApp()
        : DevicePreview(
      enabled:
      !kReleaseMode,
      builder: (context) => const CustomerApp(),
    ),
  );
}

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const ScanQRPage();
          },
        ),
        GoRoute(
          path: '/selection/:tableNumber',
          builder: (context, state) {
            final tableNumber = state.pathParameters['tableNumber']!;
            return FutureBuilder<TableModel>(
              future: TableService().getCustomerTableByNumber(int.parse(tableNumber)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching table.'));
                }

                final table = snapshot.data;
                if (table == null || table.status != 'AVAILABLE') {
                  return _showTableNotAvailableDialog(context, tableNumber);
                }
                return SelectionPage(tableNumber: tableNumber);
              },
            );
          },
        ),
      ],
    );
  }

  // Function to show a dialog when the table is not available
  Widget _showTableNotAvailableDialog(BuildContext context, String tableNumber) {
    return AlertDialog(
      title: const Text('Table Not Available'),
      content: const Text('This table is not available. Would you like to scan again?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/'); // Go back to ScanQRPage
          },
          child: const Text('Scan Again'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
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
