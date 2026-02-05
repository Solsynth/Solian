import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

import 'create_account_content.dart';

class CreateAccountScreen extends HookConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('createAccount').tr(),
      ),
      body: CreateAccountContent(),
    );
  }
}
