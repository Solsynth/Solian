import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  bool isChinese(String text) {
    final chineseRegex = RegExp(r'[\u4e00-\u9fff]');
    return chineseRegex.hasMatch(text);
  }

  bool isEnglish(String text) {
    final englishRegex = RegExp(r'[a-zA-Z]');
    return englishRegex.hasMatch(text) && !isChinese(text);
  }

  if (isChinese(text)) return "zh";
  if (isEnglish(text)) return "en";
  return null;
}
