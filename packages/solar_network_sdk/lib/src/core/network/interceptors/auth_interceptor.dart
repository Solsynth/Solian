import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/app_token.dart';

abstract class TokenStorage {
  Future<AppToken?> getToken();
  Future<void> setToken(AppToken token);
  Future<void> clearToken();
}

class InMemoryTokenStorage implements TokenStorage {
  AppToken? _token;

  @override
  Future<AppToken?> getToken() async => _token;

  @override
  Future<void> setToken(AppToken token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  _AuthInterceptor({required this.tokenStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'AtField ${token.token}';
      }
    } catch (_) {}

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    return handler.next(error);
  }
}

class _RetryInterceptor extends Interceptor {
  final int retries;
  final List<Duration> retryDelays;

  _RetryInterceptor({required this.retries, required this.retryDelays})
    : assert(retryDelays.length == retries);

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = error.requestOptions;
    if (requestOptions.method != 'GET') {
      return handler.next(error);
    }

    int attempt = 0;
    while (attempt < retries) {
      attempt++;
      await Future.delayed(retryDelays[attempt - 1]);

      try {
        final response = await Dio().fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (attempt == retries) {
          return handler.next(error);
        }
      }
    }
  }
}
