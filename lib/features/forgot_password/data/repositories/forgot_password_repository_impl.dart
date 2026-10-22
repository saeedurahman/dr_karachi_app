import '../../domain/repositories/forgot_password_repository.dart';
import '../datasources/forgot_password_remote_data_source.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordRemoteDataSource remoteDataSource;

  ForgotPasswordRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> requestOtp(String phone) {
    return remoteDataSource.requestOtp(phone);
  }

  @override
  Future<String> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return remoteDataSource.verifyOtp(phone: phone, otp: otp);
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  }) {
    return remoteDataSource.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
