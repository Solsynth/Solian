import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigProvider>();

    return AppScaffold(
      appBar: AppBar(title: Text("reCaptcha").tr()),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('${cfg.serverUrl}/captcha?redirect_uri=solink://captcha'),
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          Uri? url = navigationAction.request.url;
          if (url != null && url.queryParameters.containsKey('captcha_tk')) {
            Navigator.pop(context, url.queryParameters['captcha_tk']!);
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}