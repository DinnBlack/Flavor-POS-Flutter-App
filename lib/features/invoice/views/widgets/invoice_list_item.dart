import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/constants.dart';
import '../../model/invoice_model.dart';
import '../invoice_detail.dart';

class InvoiceListItem extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceListItem({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = Theme
        .of(context)
        .colorScheme;

    return Card(
      color: colors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#${invoice.id}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: colors.primary)),
                _statusChip(invoice.cashierName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _paymentStatusChip(invoice.amountGiven.toString()),
                Text("💰 ${CurrencyFormatter.format(invoice.total)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx + 1,
                        details.globalPosition.dy + 1,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'track',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.track_changes,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Theo dõi",
                                style: TextStyle(
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Chi tiết",
                                style: TextStyle(
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      elevation: 8,
                    ).then((value) {
                      if (value == 'track') {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                backgroundColor: colors.surface,
                                content: SizedBox(
                                  width: 400,
                                  child: Placeholder(),
                                ),
                              ),
                        );
                      } else if (value == 'detail') {
                        _showInvoiceDetails(context, invoice);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/more.svg',
                      colorFilter: const ColorFilter.mode(
                          Colors.grey, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = status == "completed"
        ? Colors.green
        : (status == "pending" ? Colors.orange : Colors.grey);
    return Chip(
      label: Text(status.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _paymentStatusChip(String status) {
    Color color = status == "paid" ? Colors.green : Colors.red;
    return Chip(
      label: Text(status.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showInvoiceDetails(BuildContext context, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .secondary,
          content: SizedBox(
            width: 400,
            child: InvoiceDetail(
              invoice:invoice,
            ),
          ),
        );
      },
    );
  }

}