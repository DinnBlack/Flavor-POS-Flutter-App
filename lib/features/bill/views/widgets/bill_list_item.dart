import 'package:flutter/material.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import '../../model/bill_model.dart';
import 'package:intl/intl.dart';

class BillListItem extends StatelessWidget {
  final BillModel bill;

  const BillListItem({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cột thông tin đơn hàng
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 2,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Mã đơn: ",
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: "#${bill.order.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  style: DefaultTextStyle.of(context).style,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Bàn: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const TextSpan(
                      text: "05",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  style: DefaultTextStyle.of(context).style,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(DateFormat('dd/MM - HH:mm a').format(bill.createdAt),
                  style: TextStyle(color: colors.outline)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              CurrencyFormatter.format(bill.order.total),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              bill.paymentStatus,
              style: TextStyle(
                color:
                    bill.paymentStatus == "Pending" ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (bill.paymentStatus == "Pending")
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện thanh toán
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: colors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  ),
                  child: const Text("Thanh toán",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
