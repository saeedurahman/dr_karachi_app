import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class RateLimitException implements Exception {
  final String message;
  final int retryAfterSeconds;

  const RateLimitException({
    required this.message,
    this.retryAfterSeconds = 60,
  });

  @override
  String toString() => message;
}

class InvalidCodeException implements Exception {
  final String message;

  const InvalidCodeException({required this.message});

  @override
  String toString() => message;
}

class ExpiredTokenException implements Exception {
  final String message;

  const ExpiredTokenException({required this.message});

  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;

  const NoInternetException({
    this.message = 'No internet connection. Please check your network and try again.',
  });

  @override
  String toString() => message;
}

abstract class ForgotPasswordRemoteDataSource {
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

class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  final ApiClient apiClient;

  ForgotPasswordRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> requestOtp(String phone) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.forgotPassword,
        data: {'phone': phone},
        options: Options(extra: {'no_auth': true}),
      );

      if (response.data is Map && (response.data as Map).containsKey('message')) {
        return (response.data as Map)['message'].toString();
      }
      return 'Verification code sent to WhatsApp.';
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw const NoInternetException();
      }

      if (e.response?.statusCode == 429) {
        final retryHeader = e.response?.headers.value('retry-after');
        final retrySec = int.tryParse(retryHeader ?? '') ?? 60;
        final detail = _extractErrorMessage(
          e,
          'Too many requests. Please wait $retrySec seconds before trying again.',
        );
        throw RateLimitException(
          message: detail,
          retryAfterSeconds: retrySec,
        );
      }

      final message = _extractErrorMessage(
        e,
        'Failed to request verification code. Please try again.',
      );
      throw Exception(message);
    } catch (e) {
      if (e is RateLimitException || e is NoInternetException) rethrow;
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.forgotPasswordVerify,
        data: {
          'phone': phone,
          'otp': otp,
        },
        options: Options(extra: {'no_auth': true}),
      );

      final data = response.data;
      if (data is Map && data.containsKey('reset_token')) {
        final token = data['reset_token'] as String;
        return token;
      }
      throw Exception('Invalid response received from server.');
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw const NoInternetException();
      }

      if (e.response?.statusCode == 400) {
        final detail = _extractErrorMessage(
          e,
          'Invalid or expired code',
        );
        throw InvalidCodeException(message: detail);
      }

      final message = _extractErrorMessage(
        e,
        'Verification failed. Please check the code and try again.',
      );
      throw Exception(message);
    } catch (e) {
      if (e is InvalidCodeException || e is NoInternetException) rethrow;
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.resetPassword,
        data: {
          'reset_token': resetToken,
          'new_password': newPassword,
        },
        options: Options(extra: {'no_auth': true}),
      );

      if (response.data is Map && (response.data as Map).containsKey('message')) {
        return (response.data as Map)['message'].toString();
      }
      return 'Password reset successfully.';
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        throw const NoInternetException();
      }

      if (e.response?.statusCode == 400) {
        final detail = _extractErrorMessage(
          e,
          'Invalid or expired reset token.',
        );
        throw ExpiredTokenException(message: detail);
      }

      final message = _extractErrorMessage(
        e,
        'Failed to reset password. Please try again.',
      );
      throw Exception(message);
    } catch (e) {
      if (e is ExpiredTokenException || e is NoInternetException) rethrow;
      throw Exception(e.toString());
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error is SocketException;
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
          return detail.join(', ');
        }
      }
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return fallback;
  }
}
