import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:order_management_flutter_app/features/table/services/table_service.dart';
import '../model/table_model.dart';

part 'table_event.dart';

part 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableService tableService = TableService();

  TableBloc() : super(TableInitial()) {
    on<TableFetchStarted>(_onTableFetchStarted);
    on<TableCreateStarted>(_onTableCreateStarted);
    on<TableUpdateStarted>(_onTableUpdateStarted);
    on<TableDeleteStarted>(_onTableDeleteStarted);
    on<TableBulkCreateStarted>(_onTableBulkCreateStarted);
    on<TableUpdateAvailableStarted>(_onTableUpdateAvailableStarted);
    on<TableUpdateOccupiedStarted>(_onTableUpdateOccupiedStarted);
    on<TableUpdateReservedStarted>(_onTableUpdateReservedStarted);
  }

  // Table fetch
  Future<void> _onTableFetchStarted(
      TableFetchStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableFetchInProgress());
      final tables = await tableService.getTables(status: event.status);
      emit(TableFetchSuccess(tables: tables));
    } on Exception catch (e) {
      emit(TableFetchFailure(error: e.toString()));
    }
  }

  // Table Create
  Future<void> _onTableCreateStarted(
      TableCreateStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableCreateInProgress());
      await tableService.createTable(event.number, event.floorId);
      emit(TableCreateSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableCreateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

  // Table Update
  Future<void> _onTableUpdateStarted(
      TableUpdateStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableUpdateInProgress());
      await tableService.updateTable(
          event.tableId, event.number, event.description, event.floorId);
      emit(TableUpdateSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableUpdateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

  // Table Delete
  Future<void> _onTableDeleteStarted(
      TableDeleteStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableDeleteInProgress());
      await tableService.deleteTable(event.tableId);
      emit(TableDeleteSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableDeleteFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

// Table Bulk Create
  Future<void> _onTableBulkCreateStarted(
      TableBulkCreateStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableBulkCreateInProgress());
      await tableService.createMultipleTables(event.tablesData);
      emit(TableBulkCreateSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      print('Exception: $e');
      emit(TableBulkCreateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

  // Cập nhật trạng thái bàn thành AVAILABLE
  Future<void> _onTableUpdateAvailableStarted(
      TableUpdateAvailableStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableUpdateAvailableInProgress());
      await tableService.updateTableStatus(event.tableId, 'available');
      emit(TableUpdateAvailableSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableUpdateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

  // Cập nhật trạng thái bàn thành OCCUPIED
  Future<void> _onTableUpdateOccupiedStarted(
      TableUpdateOccupiedStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableUpdateOccupiedInProgress());
      await tableService.updateTableStatus(event.tableId, 'occupied');
      emit(TableUpdateOccupiedSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableUpdateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }

  // Cập nhật trạng thái bàn thành RESERVED
  Future<void> _onTableUpdateReservedStarted(
      TableUpdateReservedStarted event, Emitter<TableState> emit) async {
    try {
      emit(TableUpdateReservedInProgress());
      await tableService.updateTableStatus(event.tableId, 'reserved');
      emit(TableUpdateReservedSuccess());
      add(TableFetchStarted());
    } on Exception catch (e) {
      emit(TableUpdateFailure(error: e.toString()));
      add(TableFetchStarted());
    }
  }
}
