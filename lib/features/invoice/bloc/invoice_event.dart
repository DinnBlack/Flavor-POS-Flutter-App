part of 'invoice_bloc.dart';

@immutable
sealed class InvoiceEvent {}

// Fetch Invoices
class InvoiceFetchStarted extends InvoiceEvent {}

// Fetch a single floor
class InvoiceFetchByIdStarted extends InvoiceEvent {
  final String id;

  InvoiceFetchByIdStarted({required this.id});
}

// Create Invoice
class InvoiceCreateStarted extends InvoiceEvent {
  final String orderId;
  final String paymentMethod;
  final double? amountGiven;

  InvoiceCreateStarted(
      {required this.orderId,
      required this.paymentMethod,
      required this.amountGiven});
}
