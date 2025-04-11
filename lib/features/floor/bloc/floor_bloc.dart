import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:order_management_flutter_app/features/floor/model/floor_model.dart';

import '../services/floor_service.dart';

part 'floor_event.dart';

part 'floor_state.dart';

class FloorBloc extends Bloc<FloorEvent, FloorState> {
  final FloorService floorService = FloorService();

  FloorBloc() : super(FloorInitial()) {
    on<FloorFetchStarted>(_onFloorFetchStarted);
    on<FloorFetchByIdStarted>(_onFloorFetchByIdStarted);
    on<FloorCreateStarted>(_onFloorCreateStarted);
    on<FloorUpdateStarted>(_onFloorUpdateStarted);
    on<FloorDeleteStarted>(_onFloorDeleteStarted);
  }

  Future<void> _onFloorFetchStarted(
      FloorFetchStarted event, Emitter<FloorState> emit) async {
    try {
      emit(FloorFetchInProgress());
      final floors = await floorService.getFloors();
      emit(FloorFetchSuccess(floors: floors));
    } catch (e) {
      emit(FloorFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onFloorFetchByIdStarted(
      FloorFetchByIdStarted event, Emitter<FloorState> emit) async {
    try {
      emit(FloorFetchInProgress());
      final floor = await floorService.getFloorById(event.id);
      emit(FloorFetchSuccess(floors: [floor]));
    } catch (e) {
      emit(FloorFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onFloorCreateStarted(
      FloorCreateStarted event, Emitter<FloorState> emit) async {
    try {
      emit(FloorCreateInProgress());
      await floorService.createFloor(event.floorName);
      emit(FloorCreateSuccess());
      add(FloorFetchStarted());
    } catch (e) {
      emit(FloorCreateFailure(error: e.toString()));
    }
  }

  Future<void> _onFloorUpdateStarted(
      FloorUpdateStarted event, Emitter<FloorState> emit) async {
    try {
      emit(FloorUpdateInProgress());
      await floorService.updateFloor(event.id, event.floorName);
      emit(FloorUpdateSuccess());
      add(FloorFetchStarted());
    } catch (e) {
      emit(FloorUpdateFailure(error: e.toString()));
    }
  }

  Future<void> _onFloorDeleteStarted(
      FloorDeleteStarted event, Emitter<FloorState> emit) async {
    try {
      emit(FloorDeleteInProgress());
      await floorService.deleteFloor(event.id);
      emit(FloorDeleteSuccess());
      add(FloorFetchStarted());
    } catch (e) {
      emit(FloorDeleteFailure(error: e.toString()));
    }
  }
}
