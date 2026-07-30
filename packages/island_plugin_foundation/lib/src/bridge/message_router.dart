import 'dart:convert';
import 'package:logging/logging.dart';

final _log = Logger('MessageRouter');

class MessageRouter {
  final Map<String, dynamic Function(Map<String, dynamic>)> _handlers = {};

  void on(String channel, dynamic Function(Map<String, dynamic>) handler) {
    _handlers[channel] = handler;
  }

  void off(String channel) => _handlers.remove(channel);

  void removeAll() => _handlers.clear();

  Map<String, dynamic> decode(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    if (raw is String) {
      try {
        final d = jsonDecode(raw);
        if (d is Map<String, dynamic>) return d;
        if (d is Map) return d.map((k, v) => MapEntry(k.toString(), v));
      } catch (_) {}
    }
    return {};
  }
}
