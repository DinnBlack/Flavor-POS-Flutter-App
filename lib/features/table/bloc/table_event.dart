part of 'table_bloc.dart';

@immutable
sealed class TableEvent {}

// Table Fetch
class TableFetchStarted extends TableEvent {
  final String? status;

  TableFetchStarted({this.status});
}

// Table Create
class TableCreateStarted extends TableEvent {
  final int number;
  final String floorId;

  TableCreateStarted({required this.number, required this.floorId});
}

// Table Update
class TableUpdateStarted extends TableEvent {
  final String tableId;
  final int number;
  final String description;
  final String floorId;

  TableUpdateStarted({required this.tableId, required this.number, required this.description, required this.floorId});
}

// Table Delete
class TableDeleteStarted extends TableEvent {
  final String tableId;

  TableDeleteStarted({required this.tableId});
}

// Table Bulk Create
class TableBulkCreateStarted extends TableEvent {
  final List<Map<String, dynamic>> tablesData;

  TableBulkCreateStarted({required this.tablesData});
}

class TableUpdateAvailableStarted extends TableEvent {
  final String tableId;

  TableUpdateAvailableStarted({required this.tableId});
}

class TableUpdateOccupiedStarted extends TableEvent {
  final String tableId;

  TableUpdateOccupiedStarted({required this.tableId});
}

class TableUpdateReservedStarted extends TableEvent {
  final String tableId;

  TableUpdateReservedStarted({required this.tableId});
}