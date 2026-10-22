abstract class ForgotPasswordRepository {
  Future<String> requestOtp(String phone);

  Future<String> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
