// ignore_for_file: invalid_runtime_check_with_js_interop_types

import 'dart:ui_web' as ui;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/config.dart';
import 'package:island/screens/auth/captcha.config.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class CaptchaScreen extends ConsumerStatefulWidget {
  const CaptchaScreen({super.key});

  @override
  ConsumerState<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends ConsumerState<CaptchaScreen> {
  bool _isInitialized = false;

  void _setupWebListener(String serverUrl) async {
    web.window.onMessage.listen((event) {
      if (event.data != null && event.data is String) {
        final message = event.data as String;
        if (message.startsWith("captcha_tk=")) {
          String token = message.replaceFirst("captcha_tk=", "");
          // ignore: use_build_context_synchronously
          if (context.mounted) Navigator.pop(context, token);
        }
      }
    });

    final captchaUrl = await ref.watch(captchaUrlProvider.future);

    final iframe =
        web.HTMLIFrameElement()
          ..src = captchaUrl
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%';

    web.document.body!.append(iframe);
    ui.platformViewRegistry.registerViewFactory(
      'captcha-iframe',
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
      appBar: AppBar(title: Text("Anti-Robot")),
      body:
          _isInitialized
              ? HtmlElementView(viewType: 'captcha-iframe')
              : Center(child: CircularProgressIndicator()),
    );
  }
}
