import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/widgets/activity_header.dart';

import '../../../../features/invoice/bloc/invoice_bloc.dart';
import '../../../../features/invoice/views/invoice_list.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(InvoiceFetchStarted());
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
                    child: BlocBuilder<InvoiceBloc, InvoiceState>(
                      builder: (context, state) {
                        if (state is InvoiceFetchInProgress) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is InvoiceFetchSuccess) {
                          return InvoiceList(invoices: state.invoices);
                        } else if (state is InvoiceFetchFailure) {
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
