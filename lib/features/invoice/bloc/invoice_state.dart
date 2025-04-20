part of 'invoice_bloc.dart';

@immutable
sealed class InvoiceState {}

final class InvoiceInitial extends InvoiceState {}

// Fetch
class InvoiceFetchInProgress extends InvoiceState {}

class InvoiceFetchSuccess extends InvoiceState {
  final List<InvoiceModel> invoices;

  InvoiceFetchSuccess({required this.invoices});
}

class InvoiceFetchFailure extends InvoiceState {
  final String error;

  InvoiceFetchFailure({required this.error});
}

// Create
class InvoiceCreateInProgress extends InvoiceState {}

class InvoiceCreateSuccess extends InvoiceState {
  final InvoiceModel invoice;

  InvoiceCreateSuccess({required this.invoice});
}

class InvoiceCreateFailure extends InvoiceState {
  final String error;

  InvoiceCreateFailure({required this.error});
}