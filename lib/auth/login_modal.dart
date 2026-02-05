import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/widgets/content/sheet.dart';

import 'login_content.dart';

class LoginModal extends HookConsumerWidget {
  const LoginModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'login'.tr(),
      heightFactor: 0.9,
      child: LoginContent(),
    );
  }
}
