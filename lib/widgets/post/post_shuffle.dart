import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_list.dart';

class PostShuffleScreen extends HookConsumerWidget {
  const PostShuffleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: const Text('postShuffle').tr()),
      body: CustomScrollView(slivers: [SliverPostList(shuffle: true)]),
    );
  }
}
