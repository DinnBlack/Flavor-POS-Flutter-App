part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

// User Fetch
class UserFetchStarted extends UserEvent {}

class UserFetchProfileStarted extends UserEvent {}

// User Create
class UserCreateStarted extends UserEvent {
  final String email;
  final String permission;

  UserCreateStarted({
    required this.email,
    required this.permission,
  });
}

// User Delete
class UserDeleteStarted extends UserEvent {
  final String userId;

  UserDeleteStarted({
    required this.userId,
  });
}
