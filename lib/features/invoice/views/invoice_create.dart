import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/core/utils/currency_formatter.dart';
import 'package:order_management_flutter_app/core/widgets/dash_divider.dart';
import 'package:order_management_flutter_app/features/order/model/order_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../order/bloc/order_bloc.dart';
import '../../table/bloc/table_bloc.dart';
import '../../table/services/table_service.dart';
import '../bloc/invoice_bloc.dart';
import 'invoice_detail.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class InvoiceCreate extends StatefulWidget {
  final OrderModel order;

  const InvoiceCreate({super.key, required this.order});

  @override
  State<InvoiceCreate> createState() => _InvoiceCreateState();
}

class _InvoiceCreateState extends State<InvoiceCreate> {
  String _paymentMethod = 'CASH';
  final List<String> _paymentOptions = ['CASH', 'MOBILE_BANKING'];
  final TextEditingController _amountGivenController = TextEditingController();
  double _change = 0.0;
  bool _isValidAmount = true;

  @override
  void dispose() {
    _amountGivenController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final given = double.tryParse(_amountGivenController.text);
    if (given == null) {
      setState(() {
        _change = 0.0;
        _isValidAmount = false;
      });
      return;
    }

    final change = given - widget.order.total;
    setState(() {
      _change = change;
      _isValidAmount = given >= widget.order.total;
    });
  }

  bool get _canConfirm {
    if (_paymentMethod == 'CASH') {
      final given = double.tryParse(_amountGivenController.text);
      return given != null && given >= widget.order.total;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) async {
        if (state is InvoiceCreateSuccess) {
          final table = await TableService().getTableByTableNumber(widget.order.tableNumber);
          TableService().updateTableStatusAvailable(table.id);

          context.read<OrderBloc>().add(OrderFetchStarted(status: const [
            'PENDING',
            'READY_TO_DELIVER',
            'DELIVERED',
            'APPROVED'
          ]));

          Navigator.pop(context);

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: InvoiceDetail(invoice: state.invoice),
              ),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hoá đơn - Bàn ${widget.order.tableNumber}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildOrderItemsList(),

            const SizedBox(height: 10),
            const DashDivider(),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tổng cộng: ${CurrencyFormatter.format(widget.order.total)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),
            _buildPaymentMethodDropdown(),
            const SizedBox(height: 16),

            if (_paymentMethod == 'CASH') _buildCashPaymentSection(),
            if (_paymentMethod != 'CASH') _buildQRCodeSection(),

            const SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: widget.order.orderItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.dishName, style: const TextStyle(fontSize: 16)),
                            if (item.note.isNotEmpty)
                              Text('Ghi chú: ${item.note}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item.quantity} x ${CurrencyFormatter.format(item.dishPrice)}'),
                          Text(
                            CurrencyFormatter.format(item.quantity * item.dishPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Row(
      children: [
        Text('Thanh toán', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        DropdownButton2<String>(
          value: _paymentMethod,
          underline: const SizedBox.shrink(),
          items: _paymentOptions.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản', style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _paymentMethod = value!),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCashPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _amountGivenController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Số tiền khách đưa (đ)',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onChanged: (_) => _calculateChange(),
        ),
        const SizedBox(height: 10),
        Text(
          _isValidAmount
              ? 'Tiền thừa: ${CurrencyFormatter.format(_change)}'
              : 'Thiếu: ${CurrencyFormatter.format(-_change)}',
          style: TextStyle(
            color: _isValidAmount ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    return Column(
      children: [
        Center(
          child: QrImageView(
            data: 'Thanh toán ${widget.order.total.toStringAsFixed(0)}đ cho bàn ${widget.order.tableNumber}',
            version: QrVersions.auto,
            size: 180,
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Vui lòng quét mã để thanh toán',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _canConfirm
                ? () {
              final amountGiven = _paymentMethod == 'CASH'
                  ? double.tryParse(_amountGivenController.text)
                  : null;

              context.read<InvoiceBloc>().add(InvoiceCreateStarted(
                  orderId: widget.order.id,
                  paymentMethod: _paymentMethod,
                  amountGiven: amountGiven));
            }
                : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Xác nhận thanh toán'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
