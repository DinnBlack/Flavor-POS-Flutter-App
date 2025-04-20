import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/user_model.dart';
import '../services/user_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService = UserService();

  UserBloc() : super(UserInitial()) {
    on<UserFetchStarted>(_onUserFetchStarted);
    on<UserFetchProfileStarted>(_onUserFetchProfileStarted);
    on<UserCreateStarted>(_onUserCreateStarted);
    on<UserDeleteStarted>(_onUserDeleteStarted);
  }

  // User fetch
  Future<void> _onUserFetchStarted(
      UserFetchStarted event, Emitter<UserState> emit) async {
    try {
      emit(UserFetchInProgress());
      final users = await userService.getUsers();
      emit(UserFetchSuccess(users: users));
    } catch (e) {
      emit(UserFetchFailure(error: e.toString()));
    }
  }

  // User fetch profile
  Future<void> _onUserFetchProfileStarted(
      UserFetchProfileStarted event, Emitter<UserState> emit) async {
    try {
      emit(UserFetchProfileInProgress());
      final user = await userService.getProfile();
      emit(UserFetchProfileSuccess(user: user));
    } catch (e) {
      emit(UserFetchProfileFailure(error: e.toString()));
    }
  }


  // User create
  Future<void> _onUserCreateStarted(
      UserCreateStarted event, Emitter<UserState> emit) async {
    try {
      emit(UserCreateInProgress());
      await userService.createUser(event.email, event.permission);
      emit(UserCreateSuccess());
      add(UserFetchStarted());
    } on Exception catch (e) {
      emit(UserCreateFailure(error: e.toString()));
    }
  }

  // User delete
  Future<void> _onUserDeleteStarted(
      UserDeleteStarted event, Emitter<UserState> emit) async {
    try {
      emit(UserDeleteInProgress());
      await userService.deleteUser(event.userId);
      emit(UserDeleteSuccess());
      add(UserFetchStarted());
    } on Exception catch (e) {
      emit(UserDeleteFailure(error: e.toString()));
    }
  }
}
