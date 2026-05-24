import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: Retrieve your actual token from local storage (e.g., Hive) or secure storage.
    // For now, this is a placeholder implementation.
    const String? token = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4MjViNzExMDk4YzBmY2E5YjA5ZWMzMWJlNjVlZDU5NiIsIm5iZiI6MTc3OTU5MjExMy4yMzQsInN1YiI6IjZhMTI2YmIxNDM4MjRiY2ViYjZkNzg2OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._7IQjM4SEKBiC7X2Ve3VaGeivJD_PVyfE3hgEn6XXvA';

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add other default headers if needed
    options.headers['Accept'] = 'application/json';

    if (kDebugMode) {
      print('=============================================');
      print('🚀 REQUEST [${options.method}]');
      print('URL: ${options.baseUrl}${options.path}');
      if (options.queryParameters.isNotEmpty) {
        print('QUERY PARAMETERS: ${options.queryParameters}');
      }
      print('HEADERS:');
      options.headers.forEach((key, value) {
        // Print token clearly or mask it partially if preferred (printing full here as requested)
        print('  $key: $value');
      });
      if (options.data != null) {
        print('BODY: ${options.data}');
      }
      print('=============================================');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ [${response.statusCode}] ${response.requestOptions.path}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ [${err.response?.statusCode}] ${err.requestOptions.path}');
      print('Error Message: ${err.message}');
    }

    // Handle token expiration globally (e.g., 401 Unauthorized)
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic or trigger user logout
      print('Token expired or unauthorized. Please log in again.');
    }

    super.onError(err, handler);
  }
}
