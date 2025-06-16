import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';

class OidcScreen extends ConsumerStatefulWidget {
  final String provider;
  final String? title;

  const OidcScreen({super.key, required this.provider, this.title});

  @override
  ConsumerState<OidcScreen> createState() => _OidcScreenState();
}

class _OidcScreenState extends ConsumerState<OidcScreen> {
  String? authToken;

  @override
  Widget build(BuildContext context) {
    final serverUrl = ref.watch(serverUrlProvider);
    final token = ref.watch(tokenProvider);

    return AppScaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : Text('login').tr(),
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          userAgent:
              kIsWeb
                  ? null
                  : Platform.isIOS
                  ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
                  : Platform.isAndroid
                  ? 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36'
                  : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
        ),
        initialUrlRequest: URLRequest(
          url: WebUri(
            (token?.token.isNotEmpty ?? false)
                ? '$serverUrl/auth/login/${widget.provider}?tk=${token!.token}'
                : '$serverUrl/auth/login/${widget.provider}',
          ),
        ),
        onWebViewCreated: (controller) {
          // Register a handler to receive the token from JavaScript
          controller.addJavaScriptHandler(
            handlerName: 'tokenHandler',
            callback: (args) {
              // args[0] will be the token string
              if (args.isNotEmpty && args[0] is String) {
                setState(() {
                  authToken = args[0];
                });

                // Return the token and close the webview
                Navigator.of(context).pop(authToken);
              }
            },
          );
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url;
          if (url != null) {
            final path = url.path;
            final queryParams = url.queryParameters;

            // Check if we're on the token page
            if (path.contains('/auth/token') &&
                queryParams.containsKey('token')) {
              // Extract token from URL
              final token = queryParams['token']!;

              // Return the token and close the webview
              Navigator.of(context).pop(token);
              return NavigationActionPolicy.CANCEL;
            }
          }
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, url) async {
          if (url != null && url.path.contains('/auth/token')) {
            // Inject JavaScript to call our handler with the token
            await controller.evaluateJavascript(
              source: '''
              const urlParams = new URLSearchParams(window.location.search);
              const token = urlParams.get('token');
              if (token) {
                window.flutter_inappwebview.callHandler('tokenHandler', token);
              }
            ''',
            );
          }
        },
      ),
    );
  }
}
