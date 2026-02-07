import 'package:dio/dio.dart';
import '../../core/storage/token_storage.dart';

class AuthService {
  final Dio _dio;
  final String _serverUrl;
  final TokenStorage _tokenStorage;

  AuthService({
    required Dio dio,
    required String serverUrl,
    required TokenStorage tokenStorage,
  }) : _dio = dio,
       _serverUrl = serverUrl,
       _tokenStorage = tokenStorage;

  Future<String> loginWithSession(
    String signedChallenge,
    String challenge,
  ) async {
    final response = await _dio.post(
      '$_serverUrl/pass/auth/login/session',
      data: {'signedChallenge': signedChallenge, 'challenge': challenge},
    );

    if (response.statusCode == 200 && response.data != null) {
      final token = response.data['token'] as String;
      await _tokenStorage.setToken(token);
      return token;
    }

    throw Exception('Login failed');
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<String?> getCurrentToken() async {
    return _tokenStorage.getToken();
  }
}
