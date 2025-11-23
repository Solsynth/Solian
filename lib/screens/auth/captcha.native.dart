import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/screens/auth/captcha.config.dart';
import 'package:island/widgets/content/sheet.dart';

class CaptchaScreen extends ConsumerWidget {
  static Future<String?> show(BuildContext context) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CaptchaScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  const CaptchaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captchaUrl = ref.watch(captchaUrlProvider);

    if (!captchaUrl.hasValue) return Center(child: CircularProgressIndicator());

    return SheetScaffold(
      titleText: "Anti-Robot",
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('${captchaUrl.value}?redirect_uri=solian://captcha'),
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
