import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:protocol_handler/protocol_handler.dart';

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  StreamSubscription<SolianDeepLinkEvent>? _solianDeepLinkSub;
  ProtocolListener? _protocolListener;
  void Function(Uri uri)? _onDeepLink;

  void initialize({required void Function(Uri uri) onDeepLink}) {
    _onDeepLink = onDeepLink;

    _solianDeepLinkSub?.cancel();
    _solianDeepLinkSub = eventBus.on<SolianDeepLinkEvent>().listen((event) {
      _onDeepLink?.call(event.uri);
    });

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      if (_protocolListener != null) {
        protocolHandler.removeListener(_protocolListener!);
      }
      _protocolListener = _ProtocolListener(
        onProtocolUrlReceived: (url) {
          final uri = Uri.tryParse(url);
          if (uri != null) _onDeepLink?.call(uri);
        },
      );
      protocolHandler.addListener(_protocolListener!);

      protocolHandler.getInitialUrl().then((initialUrl) {
        if (initialUrl == null) return;
        final uri = Uri.tryParse(initialUrl);
        if (uri != null) _onDeepLink?.call(uri);
      });
    }
  }

  void dispose() {
    _solianDeepLinkSub?.cancel();
    _solianDeepLinkSub = null;
    _onDeepLink = null;

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows) &&
        _protocolListener != null) {
      protocolHandler.removeListener(_protocolListener!);
      _protocolListener = null;
    }
  }
}

class _ProtocolListener implements ProtocolListener {
  final void Function(String) _onProtocolUrlReceived;

  _ProtocolListener({required void Function(String) onProtocolUrlReceived})
    : _onProtocolUrlReceived = onProtocolUrlReceived;

  @override
  void onProtocolUrlReceived(String url) => _onProtocolUrlReceived(url);
}
