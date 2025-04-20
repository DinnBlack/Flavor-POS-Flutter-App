part of 'shift_bloc.dart';

@immutable
sealed class ShiftState {}

final class ShiftInitial extends ShiftState {}

// Fetch list
class ShiftFetchInProgress extends ShiftState {}

class ShiftFetchSuccess extends ShiftState {
  final List<ShiftModel> shifts;

  ShiftFetchSuccess({required this.shifts});
}

class ShiftFetchFailure extends ShiftState {
  final String error;

  ShiftFetchFailure({required this.error});
}

// Fetch single shift
class ShiftFetchByIdSuccess extends ShiftState {
  final ShiftModel shift;

  ShiftFetchByIdSuccess({required this.shift});
}

// Start new shift
class ShiftStartInProgress extends ShiftState {}

class ShiftStartSuccess extends ShiftState {}

class ShiftStartFailure extends ShiftState {
  final String error;

  ShiftStartFailure({required this.error});
}

// End  shift
class ShiftEndInProgress extends ShiftState {}

class ShiftEndSuccess extends ShiftState {}

class ShiftEndFailure extends ShiftState {
  final String error;

  ShiftEndFailure({required this.error});
}

// Get current shift
class ShiftGetCurrentSuccess extends ShiftState {
  final ShiftModel? currentShift;

  ShiftGetCurrentSuccess({required this.currentShift});
}
