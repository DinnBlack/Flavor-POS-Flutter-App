part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

// login
class AuthLoginStarted extends AuthEvent {}

// logout
class AuthLogoutStarted extends AuthEvent {}
