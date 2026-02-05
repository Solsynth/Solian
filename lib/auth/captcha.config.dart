import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captcha.config.g.dart';

@riverpod
Future<String> captchaUrl(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final baseUrl = await apiClient.get('/config/site');
  return '$baseUrl/auth/captcha';
}
