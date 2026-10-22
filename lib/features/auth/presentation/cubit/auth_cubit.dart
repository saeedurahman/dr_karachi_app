import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  @override
  void emit(AuthState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (!isAuth) {
        emit(Unauthenticated());
        return;
      }

      final user = await authRepository.getSavedUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        phone: phone,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(cleanMessage));
    }
  }

  Future<void> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    bool marketingOptIn = false,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
        marketingOptIn: marketingOptIn,
      );
      emit(Authenticated(user));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(cleanMessage));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? email,
  }) async {
    final currentState = state;
    try {
      final updatedUser = await authRepository.updateProfile(
        fullName: fullName,
        email: email,
      );
      emit(Authenticated(updatedUser));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      if (currentState is Authenticated) {
        emit(currentState);
      }
      throw Exception(cleanMessage);
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      emit(Unauthenticated());
    }
  }

  void forceUnauthenticated() {
    emit(Unauthenticated());
  }
}
