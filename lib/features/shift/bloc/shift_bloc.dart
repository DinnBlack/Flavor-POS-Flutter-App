import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/shift_model.dart';
import '../services/shift_service.dart';

part 'shift_event.dart';

part 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final ShiftService shiftService = ShiftService();

  ShiftBloc() : super(ShiftInitial()) {
    on<ShiftFetchStarted>(_onShiftFetchStarted);
    on<ShiftFetchByIdStarted>(_onShiftFetchByIdStarted);
    on<ShiftStartStarted>(_onShiftStartStarted);
    on<ShiftEndStarted>(_onShiftEndStarted);
    on<ShiftGetCurrentStarted>(_onShiftGetCurrentStarted);
  }
  Future<void> _onShiftFetchStarted(
      ShiftFetchStarted event, Emitter<ShiftState> emit) async {
    emit(ShiftFetchInProgress());
    try {
      final shifts = await shiftService.getShifts();
      emit(ShiftFetchSuccess(shifts: shifts));
    } catch (e) {
      emit(ShiftFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onShiftFetchByIdStarted(
      ShiftFetchByIdStarted event, Emitter<ShiftState> emit) async {
    emit(ShiftFetchInProgress());
    try {
      final shift = await shiftService.getShiftById(event.id);
      emit(ShiftFetchByIdSuccess(shift: shift));
    } catch (e) {
      emit(ShiftFetchFailure(error: e.toString()));
    }
  }

  Future<void> _onShiftStartStarted(
      ShiftStartStarted event, Emitter<ShiftState> emit) async {
    emit(ShiftStartInProgress());
    try {
      await shiftService.startShift();
      emit(ShiftStartSuccess());
    } catch (e) {
      emit(ShiftStartFailure(error: e.toString()));
    }
  }

  Future<void> _onShiftEndStarted(
      ShiftEndStarted event, Emitter<ShiftState> emit) async {
    emit(ShiftEndInProgress());
    try {
      await shiftService.endShift(event.shiftId);
      emit(ShiftEndSuccess());
    } catch (e) {
      emit(ShiftEndFailure(error: e.toString()));
    }
  }

  Future<void> _onShiftGetCurrentStarted(
      ShiftGetCurrentStarted event, Emitter<ShiftState> emit) async {
    try {
      final shift = await shiftService.getCurrentShift();
      emit(ShiftGetCurrentSuccess(currentShift: shift));
    } catch (e) {
      emit(ShiftFetchFailure(error: e.toString()));
    }
  }
}
