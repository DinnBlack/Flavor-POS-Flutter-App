import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/features/bill/model/bill_model.dart';
import 'package:order_management_flutter_app/features/bill/views/widgets/bill_list_item.dart';

class BillList extends StatelessWidget {
  final List<BillModel> bills;

  const BillList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      separatorBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.grey,
        height: 1,
        width: double.infinity,
      ),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        return BillListItem(bill: bills[index]);
      },
    );
  }
}
