import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/app_scaffold.dart';

class OidcScreen extends ConsumerStatefulWidget {
  final String provider;

  const OidcScreen({super.key, required this.provider});

  @override
  ConsumerState<OidcScreen> createState() => _OIDCScreenState();
}

class _OIDCScreenState extends ConsumerState<OidcScreen> {
  InAppWebViewController? _webViewController;
  String? authToken;

  @override
  Widget build(BuildContext context) {
    final serverUrl = ref.watch(serverUrlProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('login').tr()),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('$serverUrl/auth/login/${widget.provider}'),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;

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
