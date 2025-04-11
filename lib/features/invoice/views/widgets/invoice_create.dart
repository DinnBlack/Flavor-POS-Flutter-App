import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../bloc/invoice_bloc.dart';
import 'invoice_detail.dart';

class InvoiceCreate extends StatefulWidget {
  final OrderModel order;

  const InvoiceCreate({super.key, required this.order});

  @override
  State<InvoiceCreate> createState() => _InvoiceCreateState();
}

class _InvoiceCreateState extends State<InvoiceCreate> {
  String _paymentMethod = 'Tiền mặt';
  final List<String> _paymentOptions = ['Tiền mặt', 'Quét mã'];
  final TextEditingController _amountGivenController = TextEditingController();
  double _change = 0.0;

  @override
  void dispose() {
    _amountGivenController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final given = double.tryParse(_amountGivenController.text) ?? 0.0;
    setState(() {
      _change = given - widget.order.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoá đơn - Bàn ${widget.order.tableNumber}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.order.orderItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.dishName,
                              style: const TextStyle(fontSize: 16)),
                          if (item.note.isNotEmpty)
                            Text('Ghi chú: ${item.note}',
                                style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.dishPrice)}'),
                        Text(
                          CurrencyFormatter.format(
                              item.quantity * item.dishPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const Divider(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Tổng cộng: ${CurrencyFormatter.format(widget.order.total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Text('Phương thức thanh toán',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            items: _paymentOptions
                .map((method) =>
                    DropdownMenuItem(value: method, child: Text(method)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
          if (_paymentMethod == 'Tiền mặt') ...[
            TextField(
              controller: _amountGivenController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền khách đưa (đ)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculateChange(),
            ),
            const SizedBox(height: 8),
            Text(
              _change >= 0
                  ? 'Tiền thừa: ${CurrencyFormatter.format(_change)}'
                  : 'Thiếu: ${CurrencyFormatter.format(-_change)}',
              style: TextStyle(
                color: _change >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (_paymentMethod == 'Quét mã') ...[
            Center(
              child: QrImageView(
                data:
                    'Thanh toán ${widget.order.total.toStringAsFixed(0)}đ cho bàn ${widget.order.tableNumber}',
                version: QrVersions.auto,
                size: 180,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Vui lòng quét mã để thanh toán',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<InvoiceBloc>().add(InvoiceCreateStarted(
                        orderId: widget.order.id,
                        paymentMethod: 'CASH',
                        amountGiven: widget.order.total));
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          insetPadding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: const InvoiceDetail(),
                          ),
                        );
                      },
                    );

                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Xác nhận thanh toán'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
