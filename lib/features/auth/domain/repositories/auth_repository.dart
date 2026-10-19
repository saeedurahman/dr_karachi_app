import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({
    required String phone,
    required String password,
  });

  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    bool marketingOptIn = false,
  });

  Future<UserModel?> getSavedUser();

  Future<UserModel> updateProfile({
    required String fullName,
    String? email,
  });

  Future<bool> isAuthenticated();

  Future<void> logout();
}
