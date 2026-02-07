import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WebAuthClient {
  int _port;
  final String _webUrl;

  WebAuthClient({
    required String baseUrl,
    required int port,
    required String webUrl,
  }) : _port = port,
       _webUrl = webUrl;

  void setPort(int port) {
    _port = port;
  }

  Future<String> getAuthenticationUrl() async {
    return '$_webUrl/auth/web?port=$_port';
  }

  Future<WebAuthResult> waitForAuth() async {
    final client = Dio();
    try {
      final response = await client.get('http://127.0.0.1:$_port/alive');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'denied') {
          return const WebAuthResult(status: WebAuthStatus.denied);
        }

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
    final client = Dio();
    try {
      final response = await client.post(
        'http://127.0.0.1:$_port/exchange',
        data: jsonEncode({
          'signed_challenge': signedChallenge,
          'device_info': ?deviceInfo,
        }),
      );

      debugPrint(
        'Exchange response: statusCode=${response.statusCode} data=${jsonEncode(response.data)}',
      );

      if (response.statusCode == 200) {
        return WebAuthResult(
          status: WebAuthStatus.success,
          token: response.data['token'] as String?,
        );
      } else {
        return WebAuthResult(
          status: WebAuthStatus.error,
          error: response.data['error'] as String?,
        );
      }
    } finally {
      client.close();
    }
  }
}

enum WebAuthStatus { challenge, success, error, denied }

class WebAuthResult {
  final WebAuthStatus status;
  final String? challenge;
  final String? token;
  final String? error;

  WebAuthResult({required this.status, this.challenge, this.token, this.error});
}
