part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

// User fetch
class UserFetchInProgress extends UserState{}

class UserFetchSuccess extends  UserState{
  final List<UserModel> users;

  UserFetchSuccess({required this.users});
}

class UserFetchFailure extends UserState{
  final String error;

  UserFetchFailure({required this.error});
}

// User get profile
class UserFetchProfileInProgress extends UserState{}

class UserFetchProfileSuccess extends  UserState{
  final UserModel user;

  UserFetchProfileSuccess({required this.user});
}

class UserFetchProfileFailure extends UserState{
  final String error;

  UserFetchProfileFailure({required this.error});
}

// User Create
class UserCreateInProgress extends UserState {}

class UserCreateSuccess extends UserState {}

class UserCreateFailure extends UserState {
  final String error;

  UserCreateFailure({required this.error});
}

// User Delete
class UserDeleteInProgress extends UserState {}

class UserDeleteSuccess extends UserState {}

class UserDeleteFailure extends UserState {
  final String error;

  UserDeleteFailure({required this.error});
}
