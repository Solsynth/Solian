import 'dart:convert';
import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

part 'translate.freezed.dart';
part 'translate.g.dart';

@freezed
sealed class TranslateQuery with _$TranslateQuery {
  const factory TranslateQuery({required String text, required String lang}) =
      _TranslateQuery;
}

@riverpod
Future<String> translateString(Ref ref, TranslateQuery query) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.post(
    '/sphere/translate',
    queryParameters: {'to': query.lang},
    data: jsonEncode(query.text),
  );
  return response.data as String;
}

@riverpod
String? detectStringLanguage(Ref ref, String text) {
  try {
    return langdetect.detectLangs(text).firstOrNull?.lang;
  } catch (err) {
    log('[Language] Unable to detect text\'s language: $text');
    return null;
  }
}
