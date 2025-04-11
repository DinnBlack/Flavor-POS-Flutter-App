import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/bill_model.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  BillBloc() : super(BillInitial()) {
    on<BillFetchStarted>(_onBillFetchStarted);
  }

  Future<void> _onBillFetchStarted(
      BillFetchStarted event, Emitter<BillState> emit) async {
    try {
      emit(BillFetchInProgress());
    } catch (e) {
      emit(BillFetchFailure(error: e.toString()));
    }
  }
}
