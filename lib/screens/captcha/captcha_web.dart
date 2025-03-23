import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class CaptchaScreen extends StatefulWidget {
  const CaptchaScreen({super.key});

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  @override
  void initState() {
    super.initState();
    _setupWebListener();
  }

  void _setupWebListener() {
    html.window.onMessage.listen((event) {
      if (event.data != null && event.data is String) {
        final message = event.data as String;
        if (message.startsWith("captcha_tk=")) {
          String token = message.replaceFirst("captcha_tk=", "");
          Navigator.pop(context, token);
        }
      }
    });

    final iframe = html.IFrameElement()
      ..src = '${context.read<ConfigProvider>().serverUrl}/captcha?redirect_uri=web'
      ..style.border = 'none'
      ..width = '100%'
      ..height = '100%';

    html.document.body!.append(iframe);
    ui.platformViewRegistry.registerViewFactory(
      'captcha-iframe',
          (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text("reCaptcha").tr()),
      body: HtmlElementView(viewType: 'captcha-iframe'),
    );
  }
}