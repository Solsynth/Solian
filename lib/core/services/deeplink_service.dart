import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:protocol_handler/protocol_handler.dart';

import 'package:url_launcher/url_launcher_string.dart';

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  StreamSubscription<SolianDeepLinkEvent>? _solianDeepLinkSub;
  ProtocolListener? _protocolListener;
  static const MethodChannel _nativeChannel = MethodChannel(
    'dev.solsynth.solian/deeplink',
  );
  void Function(Uri uri)? _onDeepLink;

  void initialize({required void Function(Uri uri) onDeepLink}) {
    _onDeepLink = onDeepLink;

    _solianDeepLinkSub?.cancel();
    _solianDeepLinkSub = eventBus.on<SolianDeepLinkEvent>().listen((event) {
      _onDeepLink?.call(event.uri);
    });

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      _nativeChannel.setMethodCallHandler((call) async {
        if (call.method != 'onDeepLink') return;
        final rawUrl =
            await _nativeChannel.invokeMethod<String>(
              'consumePendingDeepLink',
            ) ??
            call.arguments?.toString();
        final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
        if (uri != null) _onDeepLink?.call(uri);
      });

      _nativeChannel.invokeMethod<String>('consumePendingDeepLink').then((
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

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      _nativeChannel.setMethodCallHandler(null);
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
      uri.scheme == 'solian' &&
      (uri.host == 'orders' || uri.host == 'order') &&
      segments.length == 1;
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

class PhysicalPassportDeepLink {
  final String? tagId;
  final Map<String, String>? queryParameters;

  const PhysicalPassportDeepLink({this.tagId, this.queryParameters});

  bool get isPathBased => tagId != null;
  bool get isQueryBased =>
      queryParameters != null && queryParameters!.isNotEmpty;
}

PhysicalPassportDeepLink? parsePhysicalPassportDeepLink(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  final isSolianPhpass = uri.scheme == 'solian' && uri.host == 'phpass';
  final isWebPhpass =
      (uri.host == 'solian.app' || uri.host.endsWith('.solian.app')) &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments[0] == 'phpass';

  if (isSolianPhpass) {
    if (uri.pathSegments.isNotEmpty) {
      final tagId = uri.pathSegments.first.trim();
      if (tagId.isNotEmpty) {
        return PhysicalPassportDeepLink(tagId: tagId);
      }
    }
    if (uri.queryParameters.isNotEmpty) {
      return PhysicalPassportDeepLink(queryParameters: uri.queryParameters);
    }
  }

  if (isWebPhpass) {
    if (uri.pathSegments.length >= 2) {
      final tagId = uri.pathSegments[1].trim();
      if (tagId.isNotEmpty) {
        return PhysicalPassportDeepLink(tagId: tagId);
      }
    }
    if (uri.queryParameters.isNotEmpty) {
      return PhysicalPassportDeepLink(queryParameters: uri.queryParameters);
    }
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

/// True when [uri] points at the Solian web app itself — its routes map 1:1
/// onto in-app routes. Subdomains (api., nt., fs., …) serve other apps and
/// are NOT in-app routes.
bool isSolianWebUri(Uri uri) =>
    (uri.scheme == 'http' || uri.scheme == 'https') && uri.host == 'solian.app';

/// Converts a Solian link — either the `solian://host/path` custom scheme or
/// the web app URL `https://solian.app/path` — into the matching in-app route
/// path (`/host/path` and `/path` respectively). Returns null when [uri] is
/// not a Solian link.
String? solianLinkToRoutePath(Uri uri) {
  String path;
  if (uri.scheme == 'solian') {
    path = '/${uri.host}${uri.path}';
  } else if (isSolianWebUri(uri)) {
    path = uri.path.isEmpty ? '/' : uri.path;
    if (!path.startsWith('/')) path = '/$path';
  } else {
    return null;
  }
  // Normalize trailing slashes so `https://solian.app/orders/123/` matches
  // the `/orders/:id` route instead of the 404 catch-all.
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  // `solian:///posts/123` (empty authority) yields `//posts/123` — collapse
  // it to a regular in-app path.
  if (path.startsWith('//')) {
    path = path.substring(1);
  }
  return path;
}

/// Normalizes a raw action URI to an in-app route path. Handles
/// `solian://…`, `https://solian.app/…` and bare `/…` paths. Returns null
/// when the value should be opened externally instead.
String? actionUriToRoutePath(String rawValue) {
  final value = rawValue.trim();
  if (value.startsWith('/')) return value;
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  return solianLinkToRoutePath(uri);
}

/// The `https://solian.app/…` web URL equivalent of a Solian link, for
/// opening in the browser when the app doesn't implement the route in-app.
/// Returns [uri] itself for `https://solian.app/…` links and null for
/// anything else.
Uri? solianLinkWebUrl(Uri uri) {
  if (isSolianWebUri(uri)) return uri;
  if (uri.scheme != 'solian') return null;
  final path = uri.path.isEmpty ? '' : uri.path;
  final webUrl = Uri.https('solian.app', '${uri.host}$path');
  return uri.queryParameters.isEmpty
      ? webUrl
      : webUrl.replace(queryParameters: uri.queryParameters);
}

/// Returns a Solian web URL on a host that is not claimed by the Android app.
///
/// Android app links can route `solian.app` back into this app even when the
/// caller explicitly requests an external application. Use this URL when a
/// Solian route is not implemented in-app and must be opened in a browser.
Uri? solianLinkBrowserUrl(Uri uri) {
  final webUrl = solianLinkWebUrl(uri);
  return webUrl?.replace(host: 'www.solian.app');
}

/// True when [path] resolves to a concrete route in [router]'s tree — i.e.
/// anything other than the 404 catch-all. Use to guard `navigatePath` so
/// Solian links to pages the app doesn't implement fall back to the browser
/// instead of landing on the in-app 404 page.
///
/// Must be called with the root router: nested routers only match their own
/// sub-collection and would report unknown paths for routes outside the tab.
bool isKnownInAppRoutePath(StackRouter router, String path) {
  final matches = router.matcher.match(path, includePrefixMatches: false);
  if (matches == null || matches.isEmpty) return false;
  return matches.every((m) => m.path != '*');
}

/// Navigates to [path] in-app when it maps to a concrete route; returns false
/// when the page isn't implemented in-app so callers can fall back (typically
/// opening the web URL in the browser) instead of showing the 404 page.
bool tryNavigateToRoutePath(StackRouter router, String path) {
  if (!isKnownInAppRoutePath(router, path)) return false;
  router.navigatePath(path);
  return true;
}

/// Handles an action URI consistently across notifications and deep links.
///
/// Concrete in-app routes are navigated in-app. Unknown Solian routes are
/// opened on the web; Android uses `www.solian.app` to avoid re-entering the
/// app through its verified app link. Other external URLs are passed through
/// unchanged.
Future<bool> handleActionUri(StackRouter router, String rawValue) async {
  final routePath = actionUriToRoutePath(rawValue);
  if (routePath != null && tryNavigateToRoutePath(router, routePath)) {
    return true;
  }

  final uri = rawValue.trim().startsWith('/')
      ? Uri.tryParse('https://solian.app${rawValue.trim()}')
      : Uri.tryParse(rawValue.trim());
  if (uri == null) return false;

  final solianWebUrl = solianLinkWebUrl(uri);
  final launchUri = !kIsWeb && Platform.isAndroid && solianWebUrl != null
      ? solianLinkBrowserUrl(uri)
      : solianWebUrl ?? uri;
  if (launchUri == null) return false;

  return launchUrlString(
    launchUri.toString(),
    mode: LaunchMode.externalApplication,
  );
}
