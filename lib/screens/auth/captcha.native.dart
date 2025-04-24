import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/app_scaffold.dart';

class CaptchaScreen extends ConsumerWidget {
  const CaptchaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);

    return AppScaffold(
      appBar: AppBar(title: Text("Anti-Robot")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('$serverUrl/auth/captcha?redirect_uri=solink://captcha'),
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
