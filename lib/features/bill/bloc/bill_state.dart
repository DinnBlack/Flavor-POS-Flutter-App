part of 'bill_bloc.dart';

@immutable
sealed class BillState {}

final class BillInitial extends BillState {}

// fetch bills
class BillFetchInProgress extends BillState {}

class BillFetchSuccess extends BillState {
  final List<BillModel> bills;

  BillFetchSuccess({required this.bills});
}

class BillFetchFailure extends BillState {
  final String error;
  BillFetchFailure({required this.error});
}
