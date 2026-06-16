import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
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
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
