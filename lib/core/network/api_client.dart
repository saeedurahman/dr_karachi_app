import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService storageService;
  final VoidCallback? onAuthExpired;

  Completer<String?>? _refreshCompleter;

  ApiClient({
    required this.dio,
    required this.storageService,
    this.onAuthExpired,
  }) {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublic = options.extra['no_auth'] == true ||
              options.path.contains(ApiConstants.login) ||
              options.path.contains(ApiConstants.register) ||
              options.path.contains(ApiConstants.refresh) ||
              options.path.contains(ApiConstants.forgotPassword) ||
              options.path.contains(ApiConstants.forgotPasswordVerify) ||
              options.path.contains(ApiConstants.resetPassword);

          if (!isPublic) {
            final token = await storageService.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final path = e.requestOptions.path;
          final statusCode = e.response?.statusCode;
          final isPublic = e.requestOptions.extra['no_auth'] == true ||
              path.contains(ApiConstants.login) ||
              path.contains(ApiConstants.register) ||
              path.contains(ApiConstants.refresh) ||
              path.contains(ApiConstants.forgotPassword) ||
              path.contains(ApiConstants.forgotPasswordVerify) ||
              path.contains(ApiConstants.resetPassword);

          // Only attempt refresh on 401 for non-auth/non-public requests
          if (statusCode == 401 && !isPublic) {
            
            // If another request is currently refreshing the token, await it
            if (_refreshCompleter != null) {
              try {
                final newAccess = await _refreshCompleter!.future;
                if (newAccess != null && newAccess.isNotEmpty) {
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final cloneReq = await dio.fetch(e.requestOptions);
                  return handler.resolve(cloneReq);
                }
              } catch (_) {
                // If the queued refresh failed, pass along the original error
                return handler.next(e);
              }
              return handler.next(e);
            }

            // Start a new in-flight refresh mutex
            final completer = Completer<String?>();
            _refreshCompleter = completer;

            try {
              final refreshToken = await storageService.getRefreshToken();
              if (refreshToken == null || refreshToken.isEmpty) {
                completer.complete(null);
                await storageService.clearAuth();
                onAuthExpired?.call();
                return handler.next(e);
              }

              final refreshDio = Dio(BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                headers: {'Content-Type': 'application/json'},
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ));

              final res = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );

              if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
                final newAccess = res.data['access_token'] as String;
                final newRefresh = res.data['refresh_token'] as String?;
                await storageService.saveTokens(
                  accessToken: newAccess,
                  refreshToken: newRefresh ?? refreshToken,
                );
                completer.complete(newAccess);

                // Retry original request
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                final cloneReq = await dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                completer.complete(null);
                await storageService.clearAuth();
                onAuthExpired?.call();
                return handler.next(e);
              }
            } on DioException catch (refreshErr) {
              completer.complete(null);
              // Only clear auth if refresh was specifically rejected by the backend
              final refreshStatus = refreshErr.response?.statusCode;
              if (refreshStatus != null && refreshStatus >= 400 && refreshStatus < 500) {
                await storageService.clearAuth();
                onAuthExpired?.call();
              }
              return handler.next(e);
            } catch (_) {
              completer.complete(null);
              await storageService.clearAuth();
              onAuthExpired?.call();
              return handler.next(e);
            } finally {
              _refreshCompleter = null;
            }
          }

          return handler.next(e);
        },
      ),
    );
  }
}
