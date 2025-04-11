import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/table/model/table_model.dart';
import '../../../../../core/widgets/search_field.dart';
import '../../../../../features/floor/bloc/floor_bloc.dart';
import '../../../../../features/floor/model/floor_model.dart';
import '../../../../../features/floor/views/floor_create_form.dart';
import '../../../../../features/floor/views/floor_list_inventory.dart';
import '../../../../../features/floor/views/widgets/floor_create_button.dart';

class FloorPage extends StatefulWidget {
  final List<TableModel> tables;
  const FloorPage({super.key, required this.tables});

  @override
  State<FloorPage> createState() => _FloorPageState();
}

class _FloorPageState extends State<FloorPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FloorModel> _filteredFloors = [];
  List<FloorModel> _allFloors = [];
  String? selectedFloor;
  String selectedSortOption = 'Mặc định';
  Timer? _timer;
  final bool _isCreatingFloor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FloorBloc>().add(FloorFetchStarted());
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isCreatingFloor) {
        context.read<FloorBloc>().add(FloorFetchStarted());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFloors = selectedFloor == null
            ? List.from(_allFloors)
            : _allFloors.where((product) {
          return '' == selectedFloor;
        }).toList();
      } else {
        _filteredFloors = _allFloors.where((product) {
          return (selectedFloor == null || '' == selectedFloor) &&
              product.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showFloorCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const FloorCreateForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<FloorBloc, FloorState>(
      listener: (context, state) {
        if (state is FloorFetchSuccess) {
          setState(() {
            _allFloors = state.floors;
            _filteredFloors = List.from(_allFloors);
          });
        }
      },
      child: Column(
        children: [
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Expanded(
                      child: SearchField(
                        hintText: 'Tìm kiếm danh mục của bạn',
                        controller: _searchController,
                        onSearchChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FloorCreateButton(
                    onPressed: _showFloorCreateDialog,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FloorListInventory(
                floors: _filteredFloors,
                tables: widget.tables,
                onFloorSelected: (p0) {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
