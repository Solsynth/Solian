import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'captcha.native.dart'
    if (dart.library.html) 'captcha.web.dart';

@RoutePage()
class CaptchaScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return const CaptchaScreenContent();
  }
}
