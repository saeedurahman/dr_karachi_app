import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    bool marketingOptIn = false,
  });

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    required String fullName,
    String? email,
  });

  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Login failed. Please check your credentials.');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    bool marketingOptIn = false,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'phone': phone,
          'password': password,
          if (email != null && email.isNotEmpty) 'email': email,
          'marketing_opt_in': marketingOptIn,
        },
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Registration failed. Please check your details.');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Failed to fetch user profile.');
      throw Exception(message);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    String? email,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConstants.me,
        data: {
          'full_name': fullName,
          'email': email?.trim().isEmpty == true ? null : email?.trim(),
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Failed to update profile.');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await apiClient.dio.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
    } catch (_) {
      // Best effort logout on server
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) {
            return first['msg'].toString();
          }
        }
      }
    }
    return fallback;
  }
}
