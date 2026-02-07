import 'package:dio/dio.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AuthService {
  final TokenStorage _tokenStorage;

  AuthService({
    required Dio dio,
    required String serverUrl,
    required TokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<String?> getCurrentToken() async {
    return _tokenStorage.getToken();
  }
}
