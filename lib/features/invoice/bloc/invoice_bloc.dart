import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/invoice_model.dart';
import '../services/invoice_service.dart';

part 'invoice_event.dart';

part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceService invoiceService = InvoiceService();

  InvoiceBloc() : super(InvoiceInitial()) {
    on<InvoiceFetchStarted>(_onInvoiceFetchStarted);
    on<InvoiceFetchByIdStarted>(_onInvoiceFetchByIdStarted);
    on<InvoiceCreateStarted>(_onInvoiceCreateStarted);
  }

  Future<void> _onInvoiceFetchStarted(
      InvoiceFetchStarted event, Emitter<InvoiceState> emit) async {
    try {
      emit(InvoiceFetchInProgress());
      final invoices = await invoiceService.getInvoices();
      emit(InvoiceFetchSuccess(invoices: invoices));
    } catch (e) {
      emit(InvoiceFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onInvoiceFetchByIdStarted(
      InvoiceFetchByIdStarted event, Emitter<InvoiceState> emit) async {
    try {
      emit(InvoiceFetchInProgress());
      final invoice = await invoiceService.getInvoiceById(event.id);
      emit(InvoiceFetchSuccess(invoices: [invoice]));
    } catch (e) {
      emit(InvoiceFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onInvoiceCreateStarted(
      InvoiceCreateStarted event, Emitter<InvoiceState> emit) async {
    try {
      emit(InvoiceCreateInProgress());
      await invoiceService.createInvoice(
          orderId: event.orderId,
          paymentMethod: event.paymentMethod,
          amountGiven: event.amountGiven);
      emit(InvoiceCreateSuccess());
      add(InvoiceFetchStarted());
    } catch (e) {
      emit(InvoiceCreateFailure(error: e.toString()));
    }
  }
}
