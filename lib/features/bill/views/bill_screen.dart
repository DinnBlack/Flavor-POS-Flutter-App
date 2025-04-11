import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import 'package:order_management_flutter_app/features/bill/views/bill_list.dart';

import '../../../core/utils/constants.dart';
import '../bloc/bill_bloc.dart';
import '../model/bill_model.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<BillModel> _filteredBills = [];
  List<BillModel> _allBills = [];

  final List<String> options = ["All", "Pending", "Paid"];
  String selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(BillFetchStarted());
  }

  void _filterBills() {
    setState(() {
      if (selectedStatus == "All") {
        _filteredBills = _allBills;
      } else {
        _filteredBills = _allBills
            .where((bill) => bill.paymentStatus == selectedStatus)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pendingCount =
        _allBills.where((bill) => bill.paymentStatus == "Pending").length;

    return BlocListener<BillBloc, BillState>(
      listener: (context, state) {
        if (state is BillFetchSuccess) {
          setState(() {
            _allBills = state.bills;
            _filterBills();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                if (Responsive.isMobile(context))
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        value: selectedStatus,
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          elevation: 0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: colors.background,
                          ),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                            _filterBills();
                          });
                        },
                        items: options.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  ...options.map(
                    (status) {
                      bool isSelected = status == selectedStatus;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStatus = status;
                            _filterBills();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: status == options[2] ? 0 : 5,
                            left: status == options[0] ? 0 : 5,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withOpacity(0.1)
                                : colors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? colors.primary :null,
                              fontWeight: isSelected ? FontWeight.w700 : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$pendingCount Active Queue',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BillList(bills: _filteredBills),
            ),
          ],
        ),
      ),
    );
  }
}
