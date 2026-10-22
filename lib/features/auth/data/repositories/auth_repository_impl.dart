import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      phone: phone,
      password: password,
    );

    await storageService.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await storageService.saveUserData(jsonEncode(response.user.toJson()));

    return response.user;
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    bool marketingOptIn = false,
  }) async {
    final response = await remoteDataSource.register(
      fullName: fullName,
      phone: phone,
      password: password,
      email: email,
      marketingOptIn: marketingOptIn,
    );

    await storageService.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await storageService.saveUserData(jsonEncode(response.user.toJson()));

    return response.user;
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final token = await storageService.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final rawUser = await storageService.getUserData();
    UserModel? cachedUser;
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(rawUser) as Map<String, dynamic>;
        cachedUser = UserModel.fromJson(map);
      } catch (_) {}
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      await storageService.saveUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('credentials')) {
        await storageService.clearAuth();
        return null;
      }
      return cachedUser;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    String? email,
  }) async {
    final updatedUser = await remoteDataSource.updateProfile(
      fullName: fullName,
      email: email,
    );
    await storageService.saveUserData(jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await remoteDataSource.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // Ignore remote logout failure so local auth is always cleared
    } finally {
      await storageService.clearAuth();
    }
  }
}
