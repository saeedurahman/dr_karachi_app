import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/forgot_password_remote_data_source.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository repository;
  Timer? _cooldownTimer;

  ForgotPasswordCubit({required this.repository})
      : super(const ForgotPasswordState());

  @override
  void emit(ForgotPasswordState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }

  void setPhone(String phone) {
    emit(state.copyWith(phone: phone, clearError: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void resetShake() {
    if (state.shouldShakeOtp) {
      emit(state.copyWith(shouldShakeOtp: false));
    }
  }

  void changeNumber() {
    _cooldownTimer?.cancel();
    emit(state.copyWith(
      step: ForgotPasswordStep.phone,
      clearError: true,
      cooldownSeconds: 0,
      clearResetToken: true,
    ));
  }

  Future<void> sendOtp({String? overridePhone}) async {
    final phoneToUse = (overridePhone ?? state.phone).trim();
    if (phoneToUse.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter your phone number.'));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      phone: phoneToUse,
    ));

    try {
      final message = await repository.requestOtp(phoneToUse);
      _startCooldown(60);
      emit(state.copyWith(
        step: ForgotPasswordStep.otp,
        isLoading: false,
        successMessage: message,
        clearError: true,
      ));
    } on RateLimitException catch (e) {
      _startCooldown(e.retryAfterSeconds);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        // If user is already on OTP step, keep them on OTP step; otherwise advance to OTP step if cooldown indicates an existing code was dispatched
        step: ForgotPasswordStep.otp,
      ));
    } on NoInternetException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: cleanMessage,
      ));
    }
  }

  Future<void> verifyOtp(String otp) async {
    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6) {
      emit(state.copyWith(
        errorMessage: 'Please enter the complete 6-digit code.',
        shouldShakeOtp: true,
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      shouldShakeOtp: false,
    ));

    try {
      final token = await repository.verifyOtp(
        phone: state.phone,
        otp: cleanOtp,
      );

      _cooldownTimer?.cancel();
      emit(state.copyWith(
        step: ForgotPasswordStep.newPassword,
        resetToken: token,
        isLoading: false,
        clearError: true,
        cooldownSeconds: 0,
      ));
    } on InvalidCodeException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        shouldShakeOtp: true,
      ));
    } on NoInternetException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: cleanMessage,
        shouldShakeOtp: true,
      ));
    }
  }

  Future<void> resetPassword({required String newPassword}) async {
    final currentToken = state.resetToken;
    if (currentToken == null || currentToken.isEmpty) {
      emit(state.copyWith(
        step: ForgotPasswordStep.phone,
        clearResetToken: true,
        errorMessage: 'Session expired. Please request a new verification code.',
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final message = await repository.resetPassword(
        resetToken: currentToken,
        newPassword: newPassword,
      );

      emit(state.copyWith(
        step: ForgotPasswordStep.success,
        clearResetToken: true,
        isLoading: false,
        successMessage: message,
      ));
    } on ExpiredTokenException catch (e) {
      // Step 5: Expired token (go back to step 1)
      emit(state.copyWith(
        step: ForgotPasswordStep.phone,
        clearResetToken: true,
        isLoading: false,
        isTokenExpired: true,
        errorMessage: e.message.isNotEmpty
            ? e.message
            : 'Reset session has expired. Please verify your phone number again.',
      ));
    } on NoInternetException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: cleanMessage,
      ));
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    emit(state.copyWith(cooldownSeconds: seconds));

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.cooldownSeconds <= 1) {
        timer.cancel();
        emit(state.copyWith(cooldownSeconds: 0));
      } else {
        emit(state.copyWith(cooldownSeconds: state.cooldownSeconds - 1));
      }
    });
  }
}
