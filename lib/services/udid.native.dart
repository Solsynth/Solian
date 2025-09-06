import 'package:flutter_udid/flutter_udid.dart';

String? _cachedUdid;

Future<String> getUdid() async {
  if (_cachedUdid != null) {
    return _cachedUdid!;
  }
  _cachedUdid = await FlutterUdid.consistentUdid;
  return _cachedUdid!;
}
