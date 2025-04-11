import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/floor/model/floor_model.dart';
import '../../../core/widgets/custom_toast.dart';
import '../bloc/table_bloc.dart';

class TableCreateForm extends StatefulWidget {
  final List<FloorModel> floors;

  const TableCreateForm({super.key, required this.floors});

  @override
  State<TableCreateForm> createState() => _TableCreateFormState();
}

class _TableCreateFormState extends State<TableCreateForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _singleTableController = TextEditingController();
  final _startNumberController = TextEditingController();
  final _endNumberController = TextEditingController();

  String? selectedFloor;
  String? floorError;
  String? tableNumberError;
  String? startNumberError;
  String? endNumberError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _singleTableController.dispose();
    _startNumberController.dispose();
    _endNumberController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<TableBloc, TableState>(
          listener: (context, state) {
            if (state is TableCreateSuccess) {
              CustomToast.showToast(context, "Bàn đã được tạo thành công!",
                  type: ContentType.success);
            } else if (state is TableCreateFailure) {
              CustomToast.showToast(context, "Tạo bàn thất bại do bàn đã tồn tại!",
                  type: ContentType.failure);
            }
          },
        ),
        BlocListener<TableBloc, TableState>(
          listener: (context, state) {
            if (state is TableBulkCreateSuccess) {
              CustomToast.showToast(context, "Đã tạo bàn đồng loạt thành công!",
                  type: ContentType.success);
            } else if (state is TableBulkCreateFailure) {
              CustomToast.showToast(
                  context, "Tất cả các bàn đã tồn tại!",
                  type: ContentType.failure);
            }
          },
        ),
      ],
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thêm bàn mới',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),

                /// TabBar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: "Tạo một bàn"),
                    Tab(text: "Tạo nhiều bàn"),
                  ],
                ),
                SizedBox(
                  height: 180,
                  child: Center(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSingleTableForm(),
                        _buildMultiTableForm(),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Huỷ'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _handleSubmit,
                      child: const Text('Thêm mới'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Form tạo 1 bàn
  Widget _buildSingleTableForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFloorDropdown(),
          const SizedBox(height: 12),
          TextFormField(
            controller: _singleTableController,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration("Nhập số bàn"),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  tableNumberError = "Vui lòng nhập số bàn";
                });
                return null;
              } else {
                setState(() {
                  tableNumberError = null;
                });
                return null;
              }
            },
          ),
          if (tableNumberError != null)
            Text(
              tableNumberError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  /// Form tạo nhiều bàn
  Widget _buildMultiTableForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFloorDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startNumberController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration("Số bắt đầu"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        startNumberError = "Bắt buộc";
                      });
                    } else {
                      setState(() {
                        startNumberError = null;
                      });
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _endNumberController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration("Số kết thúc"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        endNumberError = "Bắt buộc";
                      });
                    } else {
                      setState(() {
                        endNumberError = null;
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (startNumberError != null)
            Text(
              startNumberError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          if (endNumberError != null)
            Text(
              endNumberError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  /// Dropdown chọn tầng
  Widget _buildFloorDropdown() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: const Text(
              "Chọn tầng",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            value: selectedFloor,
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedFloor = newValue;
                floorError = null;
              });
            },
            dropdownStyleData: DropdownStyleData(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            items: widget.floors
                .map(
                  (floor) => DropdownMenuItem<String>(
                    value: floor.id,
                    child: Text(
                      floor.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (floorError != null)
          Text(
            floorError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (selectedFloor == null) {
        setState(() {
          floorError = "Vui lòng chọn tầng";
        });
        return;
      } else {
        setState(() {
          floorError = null;
        });
      }

      List<Map<String, dynamic>> tablesData = [];

      if (_tabController.index == 1) {
        int start = int.parse(_startNumberController.text.trim());
        int end = int.parse(_endNumberController.text.trim());

        for (int i = start; i <= end; i++) {
          tablesData.add({
            'number': i,
            'floorId': selectedFloor!,
          });
        }
        context
            .read<TableBloc>()
            .add(TableBulkCreateStarted(tablesData: tablesData));
      } else if (_tabController.index == 0) {
        int tableNumber = int.parse(_singleTableController.text.trim());
        context.read<TableBloc>().add(
            TableCreateStarted(number: tableNumber, floorId: selectedFloor!));
      }

      Navigator.pop(context);
    }
  }

  /// Custom decoration cho input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
