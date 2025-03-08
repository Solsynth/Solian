import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

const Map<String, IconData> kCategoryIcons = {
  'technology': Symbols.tools_wrench,
  'gaming': Symbols.gamepad,
  'life': Symbols.nightlife,
  'arts': Symbols.format_paint,
  'sports': Symbols.sports_soccer,
  'music': Symbols.music_note,
  'news': Symbols.newspaper,
  'knowledge': Symbols.library_books,
  'literature': Symbols.book,
  'funny': Symbols.attractions,
};

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

// You know what? I'm not going to make this a global variable.
// Cuz the global key make the selected category not update to child widget when the category is changed.
SnPostCategory? _selectedCategory;

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  final _fabKey = GlobalKey<ExpandableFabState>();
  final _listKeys = List.generate(4, (_) => GlobalKey<_PostListWidgetState>());

  final List<SnPostCategory> _categories = List.empty(growable: true);

  Future<void> _fetchCategories() async {
    _categories.clear();
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/co/categories?take=100');
      setState(() {
        _categories.addAll(resp.data
                .map((e) => SnPostCategory.fromJson(e))
                .cast<SnPostCategory>() ??
            []);
      });
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    }
  }

  void _clearFilter() {
    _selectedCategory = null;
  }

  @override
  void initState() {
    _fetchCategories();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshPosts() async {
    await _listKeys[_tabController.index].currentState?.refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _fabKey,
        distance: 75,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(context)
              .colorScheme
              .surface
              .withAlpha((255 * 0.5).round()),
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Symbols.add, size: 28),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Symbols.close, size: 28),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
        ),
        children: [
          Row(
            children: [
              Text('writePost').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'writePost'.tr(),
                onPressed: () {
                  GoRouter.of(context).pushNamed('postEditor').then((value) {
                    if (value == true) {
                      refreshPosts();
                    }
                  });
                  _fabKey.currentState!.toggle();
                },
                child: const Icon(Symbols.edit),
              ),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                leading: AutoAppBarLeading(),
                title: Text('screenExplore').tr(),
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Symbols.category),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _PostCategoryPickerPopup(
                          categories: _categories,
                          selected: _selectedCategory,
                        ),
                      ).then((value) {
                        if (value != null && context.mounted) {
                          _selectedCategory = value == false ? null : value;
                          refreshPosts();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Symbols.search),
                    onPressed: () {
                      GoRouter.of(context).pushNamed('postSearch');
                    },
                  ),
                  const Gap(8),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Symbols.globe,
                              size: 20,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              'postChannelGlobal',
                              maxLines: 1,
                            ).tr().textColor(
                                Theme.of(context).appBarTheme.foregroundColor),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Symbols.group,
                              size: 20,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              'postChannelFriends',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ).tr().textColor(
                                Theme.of(context).appBarTheme.foregroundColor),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Symbols.subscriptions,
                              size: 20,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              'postChannelFollowing',
                              maxLines: 1,
                            ).tr().textColor(
                                Theme.of(context).appBarTheme.foregroundColor),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Symbols.workspaces,
                              size: 20,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              'postChannelRealm',
                              maxLines: 1,
                            ).tr().textColor(
                                Theme.of(context).appBarTheme.foregroundColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _PostListWidget(
              key: _listKeys[0],
              onClearFilter: _clearFilter,
            ),
            _PostListWidget(
              key: _listKeys[1],
              channel: 'friends',
              onClearFilter: _clearFilter,
            ),
            _PostListWidget(
              key: _listKeys[2],
              channel: 'following',
              onClearFilter: _clearFilter,
            ),
            _PostListWidget(
              key: _listKeys[3],
              withRealm: true,
              onClearFilter: _clearFilter,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListWidget extends StatefulWidget {
  final String? channel;
  final bool withRealm;
  final Function onClearFilter;

  const _PostListWidget(
      {super.key,
      this.channel,
      this.withRealm = false,
      required this.onClearFilter});

  @override
  State<_PostListWidget> createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<_PostListWidget> {
  bool _isBusy = false;

  final List<SnPost> _posts = List.empty(growable: true);
  final List<SnRealm> _realms = List.empty(growable: true);
  SnRealm? _selectedRealm;
  int? _postCount;

  Future<void> _fetchRealms() async {
    try {
      final rels = context.read<SnRealmProvider>();
      final out = await rels.listAvailableRealms();
      setState(() {
        _realms.addAll(out);
        _selectedRealm = out.firstOrNull;
      });
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      rethrow;
    }
  }

  Future<void> _fetchPosts() async {
    if (_postCount != null && _posts.length >= _postCount!) return;

    setState(() => _isBusy = true);

    final pt = context.read<SnPostContentProvider>();
    final result = await pt.listPosts(
      take: 10,
      offset: _posts.length,
      categories: _selectedCategory != null ? [_selectedCategory!.alias] : null,
      channel: widget.channel,
      realm: _selectedRealm?.alias,
    );
    final out = result.$1;

    if (!mounted) return;

    _postCount = result.$2;
    _posts.addAll(out);

    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> refreshPosts() {
    _postCount = null;
    _posts.clear();
    return _fetchPosts();
  }

  @override
  void initState() {
    super.initState();
    if (widget.withRealm) {
      _fetchRealms().then((_) {
        _fetchPosts();
      });
    } else {
      _fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedCategory != null)
          MaterialBanner(
            content: Text(
              'postFilterWithCategory'.tr(args: [
                'postCategory${_selectedCategory!.alias.capitalize()}'.trExists()
                    ? 'postCategory${_selectedCategory!.alias.capitalize()}'
                        .tr()
                    : _selectedCategory!.name,
              ]),
            ),
            leading: Icon(kCategoryIcons[_selectedCategory!.alias] ??
                Symbols.question_mark),
            actions: [
              IconButton(
                icon: const Icon(Symbols.clear),
                onPressed: () {
                  widget.onClearFilter.call();
                  refreshPosts();
                },
              ),
            ],
            padding: const EdgeInsets.only(left: 20, right: 4),
          ),
        if (widget.withRealm)
          DropdownButtonHideUnderline(
            child: DropdownButton2<SnRealm>(
              isExpanded: true,
              items: _realms
                  .map(
                    (ele) => DropdownMenuItem<SnRealm>(
                      value: ele,
                      child: Row(
                        children: [
                          AccountImage(
                            content: ele.avatar,
                            fallbackWidget: const Icon(Symbols.group, size: 16),
                            radius: 14,
                          ),
                          const Gap(8),
                          Text(
                            ele.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              value: _selectedRealm,
              onChanged: (SnRealm? value) {
                setState(() => _selectedRealm = value);
                refreshPosts();
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(left: 4, right: 12),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 48,
              ),
            ),
          ),
        if (widget.withRealm) const Divider(height: 1),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: RefreshIndicator(
              displacement: 40 + MediaQuery.of(context).padding.top,
              onRefresh: () => refreshPosts(),
              child: InfiniteList(
                itemCount: _posts.length,
                isLoading: _isBusy,
                centerLoading: true,
                hasReachedMax:
                    _postCount != null && _posts.length >= _postCount!,
                onFetchData: _fetchPosts,
                itemBuilder: (context, idx) {
                  return OpenablePostItem(
                    data: _posts[idx],
                    maxWidth: 640,
                    onChanged: (data) {
                      setState(() => _posts[idx] = data);
                    },
                    onDeleted: () {
                      refreshPosts();
                    },
                  );
                },
                separatorBuilder: (_, __) => const Gap(8),
              ),
            ),
          ).padding(top: 8),
        ),
      ],
    );
  }
}

class _PostCategoryPickerPopup extends StatelessWidget {
  final List<SnPostCategory> categories;
  final SnPostCategory? selected;

  const _PostCategoryPickerPopup({required this.categories, this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.category, size: 24),
            const Gap(16),
            Text('postCategory')
                .tr()
                .textStyle(Theme.of(context).textTheme.titleLarge!),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        ListTile(
          leading: const Icon(Symbols.clear),
          title: Text('postFilterReset').tr(),
          subtitle: Text('postFilterResetDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          onTap: () {
            Navigator.pop(context, false);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: categories
                .map(
                  (ele) => InkWell(
                    onTap: () {
                      _selectedCategory = ele;
                      Navigator.pop(context, ele);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          kCategoryIcons[ele.alias] ?? Symbols.question_mark,
                          color: selected == ele
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const Gap(4),
                        Text(
                          'postCategory${ele.alias.capitalize()}'.trExists()
                              ? 'postCategory${ele.alias.capitalize()}'.tr()
                              : ele.name,
                        )
                            .textStyle(Theme.of(context).textTheme.titleMedium!)
                            .textColor(selected == ele
                                ? Theme.of(context).colorScheme.primary
                                : null),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
