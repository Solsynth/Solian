import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captcha.config.g.dart';

@riverpod
Future<String> captchaUrl(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/.well-known/services');
  final serviceMapping = await resp.data;
  var baseUrl = serviceMapping['DysonNetwork.Pass'] as String;
  // The backend using self-signed certicates on development
  // Which mobile simulator might not accept, use this to avoid errors
  if (baseUrl.contains('https://localhost')) baseUrl = 'http://localhost:5216';
  return '$baseUrl/captcha';
}
