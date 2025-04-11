part of 'table_bloc.dart';

@immutable
sealed class TableState {}

final class TableInitial extends TableState {}

// Table Fetch
class TableFetchInProgress extends TableState {}

class TableFetchSuccess extends TableState {
  final List<TableModel> tables;

  TableFetchSuccess({required this.tables});
}

class TableFetchFailure extends TableState {
  final String error;

  TableFetchFailure({required this.error});
}

// Table Create
class TableCreateInProgress extends TableState {}

class TableCreateSuccess extends TableState {}

class TableCreateFailure extends TableState {
  final String error;

  TableCreateFailure({required this.error});
}

// Table Update
class TableUpdateInProgress extends TableState {}

class TableUpdateSuccess extends TableState {}

class TableUpdateFailure extends TableState {
  final String error;

  TableUpdateFailure({required this.error});
}

// Table Delete
class TableDeleteInProgress extends TableState {}

class TableDeleteSuccess extends TableState {}

class TableDeleteFailure extends TableState {
  final String error;

  TableDeleteFailure({required this.error});
}

// Table Bulk Create
class TableBulkCreateInProgress extends TableState {}

class TableBulkCreateSuccess extends TableState {}

class TableBulkCreateFailure extends TableState {
  final String error;

  TableBulkCreateFailure({required this.error});
}

// Trạng thái cho 3 trạng thái update bàn
class TableUpdateAvailableInProgress extends TableState {}

class TableUpdateOccupiedInProgress extends TableState {}

class TableUpdateReservedInProgress extends TableState {}

class TableUpdateAvailableSuccess extends TableState {}

class TableUpdateOccupiedSuccess extends TableState {}

class TableUpdateReservedSuccess extends TableState {}
