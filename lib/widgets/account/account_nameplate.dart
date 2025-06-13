import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountNameplate extends HookConsumerWidget {
  final String name;
  const AccountNameplate({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountProvider(name));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1 / MediaQuery.of(context).devicePixelRatio,
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.all(16),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: user.when(
          data: (account) => ListTile(
            leading: ProfilePictureWidget(
              fileId: account.profile.picture?.id,
            ),
            title: Text(account.nick).bold(),
            subtitle: Text('@${account.name}'),
          ),
          loading: () => ListTile(
            leading: const CircularProgressIndicator(),
            title: const Text('loading').bold().tr(),
            subtitle: const Text('...'),
          ),
          error: (error, stackTrace) => ListTile(
            leading: Icon(Icons.error_outline, color: Colors.red),
            title: Text('somethingWentWrong').bold().tr(),
            subtitle: Text(error.toString()),
          ),
        ),
      ),
    );
  }
}
