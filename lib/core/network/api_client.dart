import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService storageService;

  ApiClient({required this.dio, required this.storageService}) {
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
          final token = await storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final path = e.requestOptions.path;
            // Prevent loops on login or refresh requests
            if (!path.contains(ApiConstants.login) &&
                !path.contains(ApiConstants.refresh)) {
              final refreshToken = await storageService.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  final refreshDio = Dio(BaseOptions(
                    baseUrl: ApiConstants.baseUrl,
                    headers: {'Content-Type': 'application/json'},
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

                    // Retry original request with newly refreshed token
                    e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                    final cloneReq = await dio.fetch(e.requestOptions);
                    return handler.resolve(cloneReq);
                  }
                } catch (_) {
                  await storageService.clearAuth();
                }
              } else {
                await storageService.clearAuth();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
