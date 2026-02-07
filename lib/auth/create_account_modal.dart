import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';

import 'create_account_content.dart';

class CreateAccountModal extends HookConsumerWidget {
  const CreateAccountModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'createAccount'.tr(),
      heightFactor: 0.9,
      child: CreateAccountContent(),
    );
  }
}
