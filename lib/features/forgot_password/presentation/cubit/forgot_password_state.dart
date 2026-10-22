enum ForgotPasswordStep {
  phone,
  otp,
  newPassword,
  success,
}

class ForgotPasswordState {
  final ForgotPasswordStep step;
  final String phone;
  final String? resetToken; // In-memory only, never persisted or logged
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int cooldownSeconds;
  final bool shouldShakeOtp;
  final bool isTokenExpired;

  const ForgotPasswordState({
    this.step = ForgotPasswordStep.phone,
    this.phone = '',
    this.resetToken,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.cooldownSeconds = 0,
    this.shouldShakeOtp = false,
    this.isTokenExpired = false,
  });

  /// Whether resending code is currently permitted.
  bool get canResend => cooldownSeconds == 0 && !isLoading;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? phone,
    String? resetToken,
    bool clearResetToken = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    int? cooldownSeconds,
    bool? shouldShakeOtp,
    bool? isTokenExpired,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      shouldShakeOtp: shouldShakeOtp ?? this.shouldShakeOtp,
      isTokenExpired: isTokenExpired ?? this.isTokenExpired,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordState &&
          runtimeType == other.runtimeType &&
          step == other.step &&
          phone == other.phone &&
          (resetToken != null) == (other.resetToken != null) &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage &&
          cooldownSeconds == other.cooldownSeconds &&
          shouldShakeOtp == other.shouldShakeOtp &&
          isTokenExpired == other.isTokenExpired;

  @override
  int get hashCode => Object.hash(
        step,
        phone,
        resetToken != null,
        isLoading,
        errorMessage,
        successMessage,
        cooldownSeconds,
        shouldShakeOtp,
        isTokenExpired,
      );

  @override
  String toString() {
    // Redact token from toString to prevent accidental logging
    return 'ForgotPasswordState(step: $step, phone: $phone, hasToken: ${resetToken != null}, loading: $isLoading, cooldown: $cooldownSeconds, error: $errorMessage)';
  }
}
