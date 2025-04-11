// import 'package:flutter/material.dart';
// import 'package:order_management_flutter_app/features/table/model/table_model.dart';
// import 'customer_pages/scan_qr_page.dart';
// import 'customer_pages/selection_page.dart';
// import '../../features/table/repository/table_data.dart';
//
// class MainCustomerScreen extends StatefulWidget {
//   final String? tableId;
//   const MainCustomerScreen({super.key, this.tableId});
//
//   @override
//   State<MainCustomerScreen> createState() => _MainCustomerScreenState();
// }
//
// class _MainCustomerScreenState extends State<MainCustomerScreen> {
//   TableModel? _selectedTable;
//
//   @override
//   void initState() {
//     super.initState();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(widget.tableId ?? 'Không có tableId'),
//         backgroundColor: Colors.red,
//       ),
//     );
//     if (widget.tableId != null) {
//       _checkAndSetTableId(widget.tableId);
//     } else {
//       setState(() {
//         _selectedTable = null;
//       });
//     }
//   }
//
//   void _checkAndSetTableId(String? id) {
//     if (id != null) {
//       // Tìm bàn trong demoTables
//       final table = demoTables.firstWhere(
//         (table) => table.id == id,
//         orElse: () => demoTables[0].copyWith(status: 'not_found'),
//       );
//
//       // Kiểm tra trạng thái bàn
//       if (table.status == 'not_found') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Không tìm thấy bàn này'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else if (table.status != 'Sẵn sàng') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Bàn ${table.number} hiện không khả dụng. Vui lòng chọn bàn khác.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         setState(() {
//           _selectedTable = table;
//         });
//       }
//     }
//   }
//
//   void _resetTable() {
//     setState(() {
//       _selectedTable = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Nếu chưa có bàn được chọn, chuyển đến trang scan
//     if (_selectedTable == null) {
//       return ScanQRPage(
//         onTableScanned: (TableModel scannedTable) {
//           setState(() {
//             _selectedTable = scannedTable;
//           });
//         },
//       );
//     }
//
//     // Nếu đã có bàn được chọn và bàn khả dụng, hiển thị trang chọn món
//     return Scaffold(
//       body: SelectionPage(
//         table: _selectedTable!,
//         onScanAgain: _resetTable,
//       ),
//     );
//   }
// }
