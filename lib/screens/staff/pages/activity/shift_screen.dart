import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/widgets/activity_header.dart';

import '../../../../features/invoice/bloc/invoice_bloc.dart';
import '../../../../features/invoice/views/invoice_list.dart';
import '../../../../features/shift/bloc/shift_bloc.dart';
import '../../../../features/shift/views/shift_list.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  _ShiftScreenState createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(ShiftFetchStarted());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const ActivityHeader(title: 'Hóa đơn'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: BlocBuilder<ShiftBloc, ShiftState>(
                      builder: (context, state) {
                        if (state is ShiftFetchInProgress) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ShiftFetchSuccess) {
                          return ShiftList(shifts: state.shifts);
                        } else if (state is ShiftFetchFailure) {
                          return Center(
                              child: Text('Lỗi khi tải hóa đơn: ${state.error}'));
                        } else {
                          return const Center(child: Text('Không có dữ liệu'));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
