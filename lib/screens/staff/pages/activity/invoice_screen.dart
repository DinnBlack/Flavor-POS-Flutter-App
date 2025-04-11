import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/screens/staff/pages/activity/widgets/activity_header.dart';

import '../../../../features/invoice/views/widgets/invoice_detail.dart';
import '../../../../features/order/views/order_history.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                ActivityHeader(
                  title: 'Hóa đơn',
                ),
                Expanded(
                  child:InvoiceDetail(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
