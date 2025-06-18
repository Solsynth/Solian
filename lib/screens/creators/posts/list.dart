import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_list.dart';

@RoutePage()
class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostListScreen({
    super.key,
    @PathParam('name') required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: Text('posts').tr()),
      body: CustomScrollView(
        slivers: [
          SliverPostList(pubName: pubName, itemType: PostItemType.creator),
        ],
      ),
    );
  }
}
