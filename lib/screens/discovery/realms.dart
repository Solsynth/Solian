import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/realm/realm_list.dart';

class DiscoveryRealmsScreen extends HookConsumerWidget {
  const DiscoveryRealmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: Text('discoverRealms'.tr())),
      body: CustomScrollView(
        slivers: [
          SliverGap(16),
          SliverRealmList(),
          SliverGap(MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
