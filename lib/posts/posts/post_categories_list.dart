import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/post/post_categories.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostCategoriesListScreen extends HookConsumerWidget {
  const PostCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          title: const Text('categoriesAndTags').tr(),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'categories'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'tags'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_CategoriesTab(), _TagsTab()]),
      ),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      provider: postCategoriesProvider,
      notifier: postCategoriesProvider.notifier,
      footerSkeletonMaxWidth: 640,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, category) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListTile(
              leading: const Icon(Symbols.category),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              trailing: const Icon(Symbols.chevron_right),
              title: Text(category.categoryDisplayTitle),
              subtitle: Text('postCount'.plural(category.usage)),
              onTap: () {
                context.pushNamed(
                  'postCategoryDetail',
                  pathParameters: {'slug': category.slug},
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TagsTab extends ConsumerWidget {
  const _TagsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      provider: postTagsProvider,
      notifier: postTagsProvider.notifier,
      footerSkeletonMaxWidth: 640,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, tag) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListTile(
              title: Text(tag.name ?? '#${tag.slug}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.label),
              trailing: const Icon(Symbols.chevron_right),
              subtitle: Text('postCount'.plural(tag.usage)),
              onTap: () {
                context.pushNamed(
                  'postTagDetail',
                  pathParameters: {'slug': tag.slug},
                );
              },
            ),
          ),
        );
      },
    );
  }
}
