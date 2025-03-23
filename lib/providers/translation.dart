import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:surface/logger.dart';

const kTranslateApiBaseUrl = 'https://translate.solsynth.dev';

class SnTranslator {
  final Dio client = Dio(
    BaseOptions(
      baseUrl: kTranslateApiBaseUrl,
      connectTimeout: Duration(seconds: 3),
      sendTimeout: Duration(seconds: 3),
      receiveTimeout: Duration(seconds: 3),
    ),
  );

  final Map<String, String> _cache = {};

  Future<String> translate(
    String text, {
    required String to,
    String from = 'auto',
    bool skipCache = false,
  }) async {
    if (text.isEmpty) return text;

    final cacheKey = md5.convert(utf8.encode('$text$from$to')).toString();
    if (!skipCache && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    logging.info('[Translator] Translate $text from $from to $to');

    final resp = await client.post(
      '/translate',
      data: {
        'q': text,
        'source': from,
        'target': to,
        'format': 'text',
      },
    );
    if (resp.statusCode == 200) {
      final out = resp.data['translatedText'];
      if (out.isNotEmpty) {
        logging.info('[Translator] Translated $text from $from to $to');
        _cache[cacheKey] = out;
        return out;
      }
    }
    throw Exception('translate failed: $resp');
  }
}
