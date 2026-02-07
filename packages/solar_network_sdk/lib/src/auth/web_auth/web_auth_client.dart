import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WebAuthClient {
  final String _baseUrl;
  final int _port;
  final String _webUrl;

  WebAuthClient({
    required String baseUrl,
    required int port,
    required String webUrl,
  }) : _baseUrl = baseUrl,
       _port = port,
       _webUrl = webUrl;

  Future<String> getAuthenticationUrl() async {
    return '$_webUrl/auth/web?port=$_port';
  }

  Future<WebAuthResult> waitForAuth() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('http://127.0.0.1:$_port/alive'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WebAuthResult(
          status: WebAuthStatus.challenge,
          challenge: data['challenge'] as String?,
        );
      }

      throw Exception('Failed to get challenge');
    } finally {
      client.close();
    }
  }

  Future<WebAuthResult> exchangeToken(
    String signedChallenge, [
    Map<String, dynamic>? deviceInfo,
  ]) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('http://127.0.0.1:$_port/exchange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'signedChallenge': signedChallenge,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WebAuthResult(
          status: WebAuthStatus.success,
          token: data['token'] as String?,
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return WebAuthResult(
          status: WebAuthStatus.error,
          error: errorData['error'] as String?,
        );
      }
    } finally {
      client.close();
    }
  }
}

enum WebAuthStatus { challenge, success, error }

class WebAuthResult {
  final WebAuthStatus status;
  final String? challenge;
  final String? token;
  final String? error;

  WebAuthResult({required this.status, this.challenge, this.token, this.error});
}
