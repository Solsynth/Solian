import 'dart:ui_web' as ui;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class CaptchaScreen extends HookConsumerWidget {
  const CaptchaScreen({super.key});

  void _setupWebListener(BuildContext context, String serverUrl) {
    web.window.onMessage.listen((event) {
      if (event.data != null && event.data is String) {
        final message = event.data as String;
        if (message.startsWith("captcha_tk=")) {
          String token = message.replaceFirst("captcha_tk=", "");
          Navigator.pop(context, token);
        }
      }
    });

    final iframe =
        web.HTMLIFrameElement()
          ..src = '$serverUrl/captcha'
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%';

    web.document.body!.append(iframe);
    ui.platformViewRegistry.registerViewFactory(
      'captcha-iframe',
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useCallback(() {
      print('use callback runs once');
      final serverUrl = ref.watch(serverUrlProvider);
      _setupWebListener(context, serverUrl);
    }, []);

    return AppScaffold(
      appBar: AppBar(title: Text("Anti-Robot")),
      body: HtmlElementView(viewType: 'captcha-iframe'),
    );
  }
}
