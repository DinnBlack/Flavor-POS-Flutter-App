part of 'shift_bloc.dart';

@immutable
sealed class ShiftEvent {}

// Fetch all shifts
class ShiftFetchStarted extends ShiftEvent {}

// Fetch shift by ID
class ShiftFetchByIdStarted extends ShiftEvent {
  final String id;

  ShiftFetchByIdStarted({required this.id});
}

// Start new shift
class ShiftStartStarted extends ShiftEvent {}

// End  shift
class ShiftEndStarted extends ShiftEvent {
  final String shiftId;

  ShiftEndStarted({required this.shiftId});
}

// Get current shift (open shift)
class ShiftGetCurrentStarted extends ShiftEvent {}