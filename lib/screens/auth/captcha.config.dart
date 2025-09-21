import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captcha.config.g.dart';

@riverpod
Future<String> captchaUrl(Ref ref) async {
  const baseUrl = "https://solian.app";
  return '$baseUrl/auth/captcha';
}
