import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/udid.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

class OidcScreen extends ConsumerStatefulWidget {
  final String provider;
  final String? title;

  const OidcScreen({super.key, required this.provider, this.title});

  @override
  ConsumerState<OidcScreen> createState() => _OidcScreenState();
}

class _OidcScreenState extends ConsumerState<OidcScreen> {
  String? authToken;
  String? currentUrl;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;
  late Future<String> _deviceIdFuture;

  @override
  void initState() {
    super.initState();
    _deviceIdFuture = getUdid();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = ref.watch(serverUrlProvider);
    final token = ref.watch(tokenProvider);

    return AppScaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : Text('login').tr(),
      ),
      body: FutureBuilder<String>(
        future: _deviceIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('somethingWentWrong').tr());
          }

          final deviceId = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: InAppWebView(
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
                    url: WebUri('$serverUrl/auth/login/${widget.provider}'),
                    headers: {
                      if (token?.token.isNotEmpty ?? false)
                        'Authorization': 'AtField ${token!.token}',
                      'X-Device-Id': deviceId,
                    },
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
                  shouldOverrideUrlLoading: (
                    controller,
                    navigationAction,
                  ) async {
                    final url = navigationAction.request.url;
                    if (url != null) {
                      setState(() {
                        currentUrl = url.toString();
                        _urlController.text = currentUrl ?? '';
                        _isLoading = true;
                      });

                      final path = url.path;
                      final queryParams = url.queryParameters;

                      // Check if we're on the token page
                      if (path.endsWith('/auth/callback')) {
                        // Extract token from URL
                        final challenge = queryParams['challenge'];
                        // Return the token and close the webview
                        Navigator.of(context).pop(challenge);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    if (url != null) {
                      setState(() {
                        currentUrl = url.toString();
                        _urlController.text = currentUrl ?? '';
                      });
                    }
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
              // Loading progress indicator
              if (_isLoading)
                LinearProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.zero,
                  stopIndicatorRadius: 0,
                  minHeight: 2,
                )
              else
                ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ).height(2),
              // Debug location bar (only visible in debug mode)
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 0,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  top: 8,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          hintText: 'URL',
                        ),
                        style: const TextStyle(fontSize: 12),
                        readOnly: true,
                      ),
                    ),
                    const Gap(4),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (currentUrl != null) {
                          Clipboard.setData(ClipboardData(text: currentUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('copyToClipboard').tr(),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
