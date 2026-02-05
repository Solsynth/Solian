import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:web/web.dart';

Future<String> getUdid() async {
  final userAgent = window.navigator.userAgent;
  final bytes = utf8.encode(userAgent);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

Future<String> getDeviceName() async {
  final userAgent = window.navigator.userAgent;
  if (userAgent.contains('Chrome') && !userAgent.contains('Edg')) {
    return 'Chrome';
  } else if (userAgent.contains('Firefox')) {
    return 'Firefox';
  } else if (userAgent.contains('Safari') && !userAgent.contains('Chrome')) {
    return 'Safari';
  } else if (userAgent.contains('Edg')) {
    return 'Edge';
  } else {
    return 'Browser';
  }
}
