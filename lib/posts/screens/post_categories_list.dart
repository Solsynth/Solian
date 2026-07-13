import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_categories.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
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
              title: Text(category.categoryTranslationKey).tr(),
              subtitle: Text('postCount'.plural(category.usage)),
              onTap: () {
                context.router.push(
                  PostCategoryDetailRoute(
                    slug: category.slug,
                    isCategory: true,
                  ),
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
              leading: Icon(
                tag.isProtected ? Symbols.lock : Symbols.label,
              ),
              trailing: const Icon(Symbols.chevron_right),
              subtitle: Text('postCount'.plural(tag.usage)),
              onTap: () {
                context.router.push(
                  PostCategoryDetailRoute(slug: tag.slug, isCategory: false),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
