import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/post/post_list.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_list.dart';

class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshKey = useState(0);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('posts').tr()),
      body: CustomScrollView(
        key: ValueKey(refreshKey.value),
        slivers: [
          SliverPostList(
            query: PostListQuery(pubName: pubName),
            itemType: PostItemType.creator,
            maxWidth: 640,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ],
      ),
    );
  }
}
