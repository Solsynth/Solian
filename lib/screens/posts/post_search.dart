import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/posts/post_filter.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/post/post_list.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kSearchPostListId = 'search';

class PostSearchScreen extends HookConsumerWidget {
  const PostSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debounce = useMemoized(() => Duration(milliseconds: 500));
    final debounceTimer = useRef<Timer?>(null);
    final showFilters = useState(false);
    final pubNameController = useTextEditingController();
    final realmController = useTextEditingController();

    // State variables for PostFilterWidget
    final categoryTabController = useTabController(initialLength: 3);

    // Single query state
    final queryState = useState(const PostListQuery());

    final noti = ref.read(postListProvider(kSearchPostListId).notifier);

    useEffect(() {
      return () {
        searchController.dispose();
        pubNameController.dispose();
        realmController.dispose();
        debounceTimer.value?.cancel();
      };
    }, []);

    void onSearchChanged(String query, {bool skipDebounce = false}) {
      queryState.value = queryState.value.copyWith(queryTerm: query);

      if (skipDebounce) {
        noti.applyFilter(queryState.value);
        return;
      }

      if (debounceTimer.value?.isActive ?? false) debounceTimer.value!.cancel();
      debounceTimer.value = Timer(debounce, () {
        noti.applyFilter(queryState.value);
      });
    }

    void toggleFilterDisplay() {
      showFilters.value = !showFilters.value;
    }

    Widget buildFilterPanel() {
      return PostFilterWidget(
        categoryTabController: categoryTabController,
        initialQuery: queryState.value,
        onQueryChanged: (newQuery) {
          queryState.value = newQuery;
          noti.applyFilter(newQuery);
        },
        hideSearch: true,
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: isWideScreen(context)
          ? null
          : AppBar(
              title: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'search'.tr(),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      onChanged: onSearchChanged,
                      onSubmitted: (value) {
                        onSearchChanged(value, skipDebounce: true);
                      },
                      autofocus: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      showFilters.value
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    onPressed: toggleFilterDisplay,
                    tooltip: 'toggleFilters'.tr(),
                  ),
                ],
              ),
            ),
      body: Consumer(
        builder: (context, ref, child) {
          final searchState = ref.watch(postListProvider(kSearchPostListId));

          return isWideScreen(context)
              ? Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: ExtendedRefreshIndicator(
                        onRefresh: noti.refresh,
                        child: CustomScrollView(
                          slivers: [
                            SliverGap(16),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: SearchBar(
                                  elevation: WidgetStateProperty.all(4),
                                  controller: searchController,
                                  hintText: 'search'.tr(),
                                  leading: const Icon(Icons.search),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  onChanged: onSearchChanged,
                                  onSubmitted: (value) {
                                    onSearchChanged(value, skipDebounce: true);
                                  },
                                ),
                              ),
                            ),
                            const SliverGap(16),
                            if (showFilters.value && !isWideScreen(context))
                              SliverToBoxAdapter(child: buildFilterPanel()),
                            // Use PaginationList with isSliver=true
                            PaginationList(
                              provider: postListProvider(kSearchPostListId),
                              notifier: postListProvider(
                                kSearchPostListId,
                              ).notifier,
                              isSliver: true,
                              isRefreshable: false,
                              itemBuilder: (context, index, post) {
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: PostActionableItem(
                                    item: post,
                                    borderRadius: 8,
                                  ),
                                );
                              },
                            ),
                            if (searchState.value?.isEmpty == true &&
                                searchController.text.isNotEmpty &&
                                !searchState.isLoading)
                              SliverFillRemaining(
                                child: Center(
                                  child: Text('noResultsFound'.tr()),
                                ),
                              ),
                            SliverGap(
                              MediaQuery.of(context).padding.bottom + 16,
                            ),
                          ],
                        ).padding(left: 8),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Gap(16),
                              Card(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Symbols.tune,
                                      ).padding(horizontal: 8),
                                      Expanded(
                                        child: Text(
                                          'filters'.tr(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Symbols.filter_alt,
                                          fill: showFilters.value ? 1 : null,
                                        ),
                                        onPressed: toggleFilterDisplay,
                                        tooltip: 'toggleFilters'.tr(),
                                      ),
                                      const Gap(4),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(8),
                              if (showFilters.value) buildFilterPanel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    if (showFilters.value)
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: buildFilterPanel(),
                          ),
                        ),
                      ),
                    // Use PaginationList with isSliver=true
                    PaginationList(
                      provider: postListProvider(kSearchPostListId),
                      notifier: postListProvider(kSearchPostListId).notifier,
                      isSliver: true,
                      isRefreshable: false,
                      itemBuilder: (context, index, post) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 600),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: PostActionableItem(
                                item: post,
                                borderRadius: 8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (searchState.value?.isEmpty == true &&
                        searchController.text.isNotEmpty &&
                        !searchState.isLoading)
                      SliverFillRemaining(
                        child: Center(child: Text('noResultsFound'.tr())),
                      ),
                  ],
                );
        },
      ),
    );
  }
}
