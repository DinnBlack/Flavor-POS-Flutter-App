part of 'floor_bloc.dart';

@immutable
sealed class FloorEvent {}

// Fetch Floors
class FloorFetchStarted extends FloorEvent {
}

// Fetch a single floor
class FloorFetchByIdStarted extends FloorEvent {
  final String id;

  FloorFetchByIdStarted({required this.id});
}

// Create Floor
class FloorCreateStarted extends FloorEvent {
  final String floorName;

  FloorCreateStarted({required this.floorName});
}

// Update Floor
class FloorUpdateStarted extends FloorEvent {
  final String id;
  final String floorName;

  FloorUpdateStarted({required this.id, required this.floorName});
}

// Delete Floor
class FloorDeleteStarted extends FloorEvent {
  final String id;

  FloorDeleteStarted({required this.id});
}
