part of 'floor_bloc.dart';

@immutable
sealed class FloorState {}

final class FloorInitial extends FloorState {}

// Fetch
class FloorFetchInProgress extends FloorState {}

class FloorFetchSuccess extends FloorState {
  final List<FloorModel> floors;

  FloorFetchSuccess({required this.floors});
}

class FloorFetchFailure extends FloorState {
  final String error;

  FloorFetchFailure({required this.error});
}

// Create
class FloorCreateInProgress extends FloorState {}

class FloorCreateSuccess extends FloorState {}

class FloorCreateFailure extends FloorState {
  final String error;

  FloorCreateFailure({required this.error});
}

// Update
class FloorUpdateInProgress extends FloorState {}

class FloorUpdateSuccess extends FloorState {}

class FloorUpdateFailure extends FloorState {
  final String error;

  FloorUpdateFailure({required this.error});
}

// Delete
class FloorDeleteInProgress extends FloorState {}

class FloorDeleteSuccess extends FloorState {}

class FloorDeleteFailure extends FloorState {
  final String error;

  FloorDeleteFailure({required this.error});
}
