import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/table/bloc/table_bloc.dart';
import 'package:order_management_flutter_app/features/table/model/table_model.dart';
import 'page/floor_page.dart';
import 'page/table_page.dart';
import 'widgets/table_header.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  int _selectedIndex = 0;
  List<TableModel> _tables = [];

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const TablePage();
      case 1:
        return FloorPage(tables: _tables);
      default:
        return const TablePage();
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(TableFetchStarted());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<TableBloc, TableState>(
        listener: (context, state) {
          if (state is TableFetchSuccess) {
            setState(() {
              _tables = state.tables;
            });
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  TableHeader(
                    onToggle: _updateSelectedIndex,
                    selectedIndex: _selectedIndex,
                  ),
                  Expanded(
                    child: _getSelectedScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
