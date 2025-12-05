import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';

import 'package:island/pods/paging.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';

final postSearchNotifierProvider =
    AsyncNotifierProvider.autoDispose<PostSearchNotifier, List<SnPost>>(
      PostSearchNotifier.new,
    );

class PostSearchNotifier extends AutoDisposeAsyncNotifier<List<SnPost>>
    with AutoDisposeAsyncPaginationController<SnPost> {
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

  Future<void> search(
    String query, {
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool shuffle = false,
    bool? pinned,
  }) async {
    _currentQuery = query.trim();
    _pubName = pubName;
    _realm = realm;
    _type = type;
    _categories = categories;
    _tags = tags;
    _shuffle = shuffle;
    _pinned = pinned;

    final hasFilters =
        pubName != null ||
        realm != null ||
        type != null ||
        categories != null ||
        tags != null ||
        shuffle ||
        pinned != null;

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
        ref.read(postSearchNotifierProvider.notifier).search(query);
      });
    }

    void onSearchWithFilters(String query) {
      if (debounceTimer.value?.isActive ?? false) debounceTimer.value!.cancel();

      debounceTimer.value = Timer(debounce, () {
        ref
            .read(postSearchNotifierProvider.notifier)
            .search(
              query,
              pubName:
                  pubNameController.text.isNotEmpty
                      ? pubNameController.text
                      : null,
              realm:
                  realmController.text.isNotEmpty ? realmController.text : null,
              type: typeValue.value,
              categories:
                  selectedCategories.value.isNotEmpty
                      ? selectedCategories.value
                      : null,
              tags: selectedTags.value.isNotEmpty ? selectedTags.value : null,
              shuffle: shuffleValue.value,
              pinned: pinnedValue.value,
            );
      });
    }

    void toggleFilters() {
      showFilters.value = !showFilters.value;
    }

    void applyFilters() {
      onSearchWithFilters(searchController.text);
    }

    void clearFilters() {
      pubNameController.clear();
      realmController.clear();
      typeValue.value = null;
      selectedCategories.value = [];
      selectedTags.value = [];
      shuffleValue.value = false;
      pinnedValue.value = null;
      onSearchChanged(searchController.text);
    }

    Widget buildFilterPanel() {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filters'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ).padding(left: 4),
                  Row(
                    children: [
                      TextButton(
                        onPressed: applyFilters,
                        child: Text('apply'.tr()),
                      ),
                      TextButton(
                        onPressed: clearFilters,
                        child: Text('clear'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: pubNameController,
                decoration: InputDecoration(
                  labelText: 'pubName'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged:
                    (value) => onSearchWithFilters(searchController.text),
              ),
              SizedBox(height: 8),
              TextField(
                controller: realmController,
                decoration: InputDecoration(
                  labelText: 'realm'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged:
                    (value) => onSearchWithFilters(searchController.text),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: shuffleValue.value,
                    onChanged: (value) {
                      shuffleValue.value = value ?? false;
                      onSearchWithFilters(searchController.text);
                    },
                  ),
                  Text('shuffle'.tr()),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: pinnedValue.value ?? false,
                    onChanged: (value) {
                      pinnedValue.value = value;
                      onSearchWithFilters(searchController.text);
                    },
                  ),
                  Text('pinned'.tr()),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
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
          final searchState = ref.watch(postSearchNotifierProvider);

          return CustomScrollView(
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
                provider: postSearchNotifierProvider,
                notifier: postSearchNotifierProvider.notifier,
                isSliver: true,
                isRefreshable:
                    false, // CustomScrollView handles refreshing usually, but here we don't have PullToRefresh
                itemBuilder: (context, index, post) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: PostActionableItem(item: post, borderRadius: 8),
                      ),
                    ),
                  );
                },
              ),
              if (searchState.valueOrNull?.isEmpty == true &&
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
