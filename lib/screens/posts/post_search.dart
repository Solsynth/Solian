import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/posts/post_filter.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/paging.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

final postSearchProvider = AsyncNotifierProvider.autoDispose(
  PostSearchNotifier.new,
);

class PostSearchNotifier extends AsyncNotifier<List<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int _pageSize = 20;
  String _currentQuery = '';
  String? _pubName;
  String? _realm;
  int? _type;
  List<String>? _categories;
  List<String>? _tags;
  bool _shuffle = false;
  bool? _pinned;

  @override
  FutureOr<List<SnPost>> build() async {
    // Initial state is empty if no query/filters, or fetch if needed
    // But original logic allowed initial empty state.
    // Let's replicate original logic: return empty list initially if no query.
    return [];
  }

  bool? _includeReplies;
  bool _mediaOnly = false;
  String? _queryTerm;
  String? _order;
  bool _orderDesc = true;
  int? _periodStart;
  int? _periodEnd;

  Future<void> search(
    String query, {
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool shuffle = false,
    bool? pinned,
    bool? includeReplies,
    bool mediaOnly = false,
    String? queryTerm,
    String? order,
    bool orderDesc = true,
    int? periodStart,
    int? periodEnd,
  }) async {
    _currentQuery = query.trim();
    _pubName = pubName;
    _realm = realm;
    _type = type;
    _categories = categories;
    _tags = tags;
    _shuffle = shuffle;
    _pinned = pinned;
    _includeReplies = includeReplies;
    _mediaOnly = mediaOnly;
    _queryTerm = queryTerm;
    _order = order;
    _orderDesc = orderDesc;
    _periodStart = periodStart;
    _periodEnd = periodEnd;

    final hasFilters =
        pubName != null ||
        realm != null ||
        type != null ||
        categories != null ||
        tags != null ||
        shuffle ||
        pinned != null ||
        includeReplies != null ||
        mediaOnly ||
        queryTerm != null ||
        order != null ||
        periodStart != null ||
        periodEnd != null;

    if (_currentQuery.isEmpty && !hasFilters) {
      state = const AsyncData([]);
      totalCount = null;
      return;
    }

    await refresh();
  }

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts',
      queryParameters: {
        'query': _currentQuery,
        'offset': fetchedCount,
        'take': _pageSize,
        'vector': false,
        if (_pubName != null) 'pub': _pubName,
        if (_realm != null) 'realm': _realm,
        if (_type != null) 'type': _type,
        if (_tags != null) 'tags': _tags,
        if (_categories != null) 'categories': _categories,
        if (_shuffle) 'shuffle': true,
        if (_pinned != null) 'pinned': _pinned,
        if (_includeReplies != null) 'includeReplies': _includeReplies,
        if (_mediaOnly) 'mediaOnly': true,
        if (_queryTerm != null) 'queryTerm': _queryTerm,
        if (_order != null) 'order': _order,
        if (_orderDesc) 'orderDesc': true,
        if (_periodStart != null) 'periodStart': _periodStart,
        if (_periodEnd != null) 'periodEnd': _periodEnd,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final data = response.data as List;
    return data.map((json) => SnPost.fromJson(json)).toList();
  }
}

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
    final typeValue = useState<int?>(null);
    final selectedCategories = useState<List<String>>([]);
    final selectedTags = useState<List<String>>([]);
    final shuffleValue = useState(false);
    final pinnedValue = useState<bool?>(null);

    // State variables for PostFilterWidget
    final categoryTabController = useTabController(initialLength: 3);
    final includeReplies = useState<bool?>(null);
    final mediaOnly = useState(false);
    final queryTerm = useState<String?>(null);
    final order = useState<String?>('date');
    final orderDesc = useState(true);
    final periodStart = useState<int?>(null);
    final periodEnd = useState<int?>(null);
    final showAdvancedFilters = useState(false);

    useEffect(() {
      return () {
        searchController.dispose();
        pubNameController.dispose();
        realmController.dispose();
        debounceTimer.value?.cancel();
      };
    }, []);

    void onSearchChanged(String query) {
      if (debounceTimer.value?.isActive ?? false) debounceTimer.value!.cancel();

      debounceTimer.value = Timer(debounce, () {
        ref
            .read(postSearchProvider.notifier)
            .search(
              query,
              type: categoryTabController.index == 1
                  ? 0
                  : (categoryTabController.index == 2 ? 1 : null),
              includeReplies: includeReplies.value,
              mediaOnly: mediaOnly.value,
              queryTerm: queryTerm.value,
              order: order.value,
              orderDesc: orderDesc.value,
              periodStart: periodStart.value,
              periodEnd: periodEnd.value,
            );
      });
    }

    void onSearchWithFilters(String query) {
      if (debounceTimer.value?.isActive ?? false) debounceTimer.value!.cancel();

      debounceTimer.value = Timer(debounce, () {
        ref
            .read(postSearchProvider.notifier)
            .search(
              query,
              pubName: pubNameController.text.isNotEmpty
                  ? pubNameController.text
                  : null,
              realm: realmController.text.isNotEmpty
                  ? realmController.text
                  : null,
              type: categoryTabController.index == 1
                  ? 0
                  : (categoryTabController.index == 2 ? 1 : null),
              categories: selectedCategories.value.isNotEmpty
                  ? selectedCategories.value
                  : null,
              tags: selectedTags.value.isNotEmpty ? selectedTags.value : null,
              shuffle: shuffleValue.value,
              pinned: pinnedValue.value,
              includeReplies: includeReplies.value,
              mediaOnly: mediaOnly.value,
              queryTerm: queryTerm.value,
              order: order.value,
              orderDesc: orderDesc.value,
              periodStart: periodStart.value,
              periodEnd: periodEnd.value,
            );
      });
    }

    void toggleFilters() {
      showFilters.value = !showFilters.value;
    }

    Widget buildFilterPanel() {
      return PostFilterWidget(
        categoryTabController: categoryTabController,
        includeReplies: includeReplies,
        mediaOnly: mediaOnly,
        queryTerm: queryTerm,
        order: order,
        orderDesc: orderDesc,
        periodStart: periodStart,
        periodEnd: periodEnd,
        showAdvancedFilters: showAdvancedFilters,
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
                        onSearchWithFilters(value);
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
                    onPressed: toggleFilters,
                    tooltip: 'toggleFilters'.tr(),
                  ),
                ],
              ),
            ),
      body: Consumer(
        builder: (context, ref, child) {
          final searchState = ref.watch(postSearchProvider);

          return isWideScreen(context)
              ? Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: CustomScrollView(
                        slivers: [
                          SliverGap(16),
                          SliverToBoxAdapter(
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
                                onSearchWithFilters(value);
                              },
                            ),
                          ),
                          const SliverGap(16),
                          if (showFilters.value && !isWideScreen(context))
                            SliverToBoxAdapter(child: buildFilterPanel()),
                          // Use PaginationList with isSliver=true
                          PaginationList(
                            provider: postSearchProvider,
                            notifier: postSearchProvider.notifier,
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
                              child: Center(child: Text('noResultsFound'.tr())),
                            ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ).padding(left: 8),
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
                                        onPressed: toggleFilters,
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
                      provider: postSearchProvider,
                      notifier: postSearchProvider.notifier,
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
