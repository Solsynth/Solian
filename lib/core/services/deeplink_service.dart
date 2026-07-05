import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:protocol_handler/protocol_handler.dart';

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  StreamSubscription<SolianDeepLinkEvent>? _solianDeepLinkSub;
  ProtocolListener? _protocolListener;
  static const MethodChannel _iosChannel = MethodChannel(
    'dev.solsynth.solian/deeplink',
  );
  void Function(Uri uri)? _onDeepLink;

  void initialize({required void Function(Uri uri) onDeepLink}) {
    _onDeepLink = onDeepLink;

    _solianDeepLinkSub?.cancel();
    _solianDeepLinkSub = eventBus.on<SolianDeepLinkEvent>().listen((event) {
      _onDeepLink?.call(event.uri);
    });

    if (!kIsWeb && Platform.isIOS) {
      _iosChannel.setMethodCallHandler((call) async {
        if (call.method != 'onDeepLink') return;
        final rawUrl =
            await _iosChannel.invokeMethod<String>('consumePendingDeepLink') ??
            call.arguments?.toString();
        final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
        if (uri != null) _onDeepLink?.call(uri);
      });

      _iosChannel.invokeMethod<String>('consumePendingDeepLink').then((
        initialUrl,
      ) {
        if (initialUrl == null) return;
        final uri = Uri.tryParse(initialUrl);
        if (uri != null) _onDeepLink?.call(uri);
      });
    }

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

    if (!kIsWeb && Platform.isIOS) {
      _iosChannel.setMethodCallHandler(null);
    }

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows) &&
        _protocolListener != null) {
      protocolHandler.removeListener(_protocolListener!);
      _protocolListener = null;
    }
  }
}

String? parseWalletTransferRequestId(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final segments = uri.pathSegments;
  final isWalletTransferRequest =
      uri.scheme == 'solian' &&
      uri.host == 'wallet' &&
      segments.length == 3 &&
      segments[0] == 'transfer' &&
      segments[1] == 'requests';
  final isWebWalletTransferRequest =
      (uri.host == 'solian.app' || uri.host.endsWith('.solian.app')) &&
      segments.length >= 3 &&
      segments[0] == 'wallet' &&
      segments[1] == 'transfer' &&
      segments[2] == 'requests';

  if (isWalletTransferRequest) {
    final id = segments[2].trim();
    return id.isEmpty ? null : id;
  }

  if (isWebWalletTransferRequest && segments.length >= 4) {
    final id = segments[3].trim();
    return id.isEmpty ? null : id;
  }

  return null;
}

String? parseAuthQrChallengeId(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final segments = uri.pathSegments;
  final isSolianQrLogin =
      uri.scheme == 'solian' &&
      uri.host == 'auth' &&
      segments.length == 2 &&
      segments[0] == 'qr';
  final isWebQrLogin =
      (uri.host == 'solian.app' || uri.host.endsWith('.solian.app')) &&
      segments.length >= 3 &&
      segments[0] == 'auth' &&
      segments[1] == 'qr';

  if (isSolianQrLogin) {
    final id = segments[1].trim();
    return id.isEmpty ? null : id;
  }

  if (isWebQrLogin) {
    final id = segments[2].trim();
    return id.isEmpty ? null : id;
  }

  return null;
}

String? parseWalletOrderId(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final segments = uri.pathSegments;
  final isSolianOrder =
      uri.scheme == 'solian' && uri.host == 'orders' && segments.length == 1;
  final isWebOrder =
      (uri.host == 'solian.app' || uri.host.endsWith('.solian.app')) &&
      segments.length >= 2 &&
      segments[0] == 'orders';

  if (isSolianOrder) {
    final id = segments[0].trim();
    return id.isEmpty ? null : id;
  }

  if (isWebOrder) {
    final id = segments[1].trim();
    return id.isEmpty ? null : id;
  }

  return null;
}

class _ProtocolListener implements ProtocolListener {
  final void Function(String) _onProtocolUrlReceived;

  _ProtocolListener({required void Function(String) onProtocolUrlReceived})
    : _onProtocolUrlReceived = onProtocolUrlReceived;

  @override
  void onProtocolUrlReceived(String url) => _onProtocolUrlReceived(url);
}
