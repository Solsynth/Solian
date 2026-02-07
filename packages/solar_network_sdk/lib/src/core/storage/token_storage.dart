import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> setToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

class SharedPreferencesTokenStorage implements TokenStorage {
  final String _key;

  SharedPreferencesTokenStorage({required String key}) : _key = key;

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
