import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/services/deeplink_service.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'login_content.dart';

final Map<int, (String, String, IconData)> kFactorTypes = {
  0: ('authFactorPassword', 'authFactorPasswordDescription', Symbols.password),
  1: ('authFactorEmail', 'authFactorEmailDescription', Symbols.email),
  2: (
    'authFactorInAppNotify',
    'authFactorInAppNotifyDescription',
    Symbols.notifications_active,
  ),
  3: ('authFactorTOTP', 'authFactorTOTPDescription', Symbols.timer),
  4: ('authFactorPin', 'authFactorPinDescription', Symbols.nest_secure_alarm),
  5: (
    'authFactorRecoveryCode',
    'authFactorRecoveryCodeDescription',
    Symbols.key,
  ),
  6: (
    'authFactorPhysicalPassport',
    'authFactorPhysicalPassportDescription',
    Symbols.badge,
  ),
  7: ('authFactorPasskey', 'authFactorPasskeyDescription', Symbols.fingerprint),
  8: ('authFactorQrLogin', 'authFactorQrLoginDescription', Symbols.qr_code_2),
};

@RoutePage()
class LoginScreen extends HookConsumerWidget {
  final String? redirectUri;

  const LoginScreen({super.key, this.redirectUri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider).value;

    // ponytail: if already logged in and a redirectUri exists, skip login
    useEffect(() {
      if (user == null || redirectUri == null || redirectUri!.isEmpty) {
        return null;
      }
      final router = context.router;
      final uri = redirectUri!;
      Future.microtask(() async {
        // Try in-app navigation first; unsupported routes go to the browser.
        await handleActionUri(router, uri);
        if (context.mounted) {
          Navigator.of(context).pop(); // dismiss login screen
        }
      });
      return null;
    }, [user != null, redirectUri]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('login').tr(),
      ),
      body: LoginContent(),
    );
  }
}
