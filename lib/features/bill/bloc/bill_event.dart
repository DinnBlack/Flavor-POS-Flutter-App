part of 'bill_bloc.dart';

@immutable
sealed class BillEvent {}

// fetch bills
class BillFetchStarted extends BillEvent {}
