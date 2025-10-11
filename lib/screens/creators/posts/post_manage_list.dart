import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';

class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshKey = useState(0);

    void showCreatePostSheet() {
      showModalBottomSheet(
        context: context,
        builder:
            (context) => SheetScaffold(
              titleText: 'create'.tr(),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Symbols.edit),
                    title: Text('Post'),
                    subtitle: Text('Create a regular post'),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await context.pushNamed(
                        'postCompose',
                        queryParameters: {'type': '0'},
                      );
                      if (result == true) {
                        refreshKey.value++;
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Symbols.article),
                    title: Text('Article'),
                    subtitle: Text('Create a detailed article'),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await context.pushNamed(
                        'postCompose',
                        queryParameters: {'type': '1'},
                      );
                      if (result == true) {
                        refreshKey.value++;
                      }
                    },
                  ),
                ],
              ),
            ),
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('posts').tr()),
      body: CustomScrollView(
        key: ValueKey(refreshKey.value),
        slivers: [
          SliverPostList(pubName: pubName, itemType: PostItemType.creator),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreatePostSheet,
        child: const Icon(Symbols.add),
      ),
    );
  }
}
