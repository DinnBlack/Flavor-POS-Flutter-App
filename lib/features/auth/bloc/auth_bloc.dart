import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../services/auth_service.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService auth0Service = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginStarted>(_onAuthLoginStarted);
    on<AuthLogoutStarted>(_onAuthLogoutStarted);
  }

  Future<void> _onAuthLoginStarted(
    AuthLoginStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginInProgress());
    try {
      await AuthService().login();
      emit(AuthLoginSuccess());
    } catch (e) {
      emit(AuthLoginFailure(error: e.toString()));
    }
  }

  Future<void> _onAuthLogoutStarted(
    AuthLogoutStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLogoutInProgress());
    try {
      await AuthService().logout();
      emit(AuthLogoutSuccess());
    } catch (e) {
      emit(AuthLogoutFailure(error: e.toString()));
    }
  }
}
