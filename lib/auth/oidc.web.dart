// ignore_for_file: invalid_runtime_check_with_js_interop_types

import 'dart:ui_web' as ui;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class OidcScreen extends ConsumerStatefulWidget {
  final String provider;
  final String? title;

  const OidcScreen({super.key, required this.provider, this.title});

  @override
  ConsumerState<OidcScreen> createState() => _OidcScreenState();
}

class _OidcScreenState extends ConsumerState<OidcScreen> {
  bool _isInitialized = false;
  final String _viewType = 'oidc-iframe';

  void _setupWebListener(String serverUrl) {
    // Listen for messages from the iframe
    web.window.onMessage.listen((event) {
      if (event.data != null && event.data is String) {
        final message = event.data as String;
        if (message.startsWith("token=")) {
          String token = message.replaceFirst("token=", "");
          // Return the token and close the screen
          if (mounted) Navigator.pop(context, token);
        }
      }
    });

    // Create the iframe for the OIDC login
    final token = ref.watch(tokenProvider);
    final iframe = web.HTMLIFrameElement()
      ..src = (token?.token.isNotEmpty ?? false)
          ? '$serverUrl/auth/login/${widget.provider}?tk=${token!.token}'
          : '$serverUrl/auth/login/${widget.provider}'
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    // Add the iframe to the document body
    web.document.body!.append(iframe);

    // Register the iframe as a platform view
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => iframe,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final serverUrl = ref.watch(serverUrlProvider);
      _setupWebListener(serverUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : Text('login').tr(),
      ),
      body: _isInitialized
          ? HtmlElementView(viewType: _viewType)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
