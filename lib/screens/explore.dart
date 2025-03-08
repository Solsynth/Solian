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

const kPostChannels = ['Global', 'Friends', 'Following'];
const kPostChannelIcons = [Symbols.globe, Symbols.group, Symbols.subscriptions];

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

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController = TabController(
    length: kPostChannels.length,
    vsync: this,
  );

  final _fabKey = GlobalKey<ExpandableFabState>();
  final _listKey = GlobalKey<_PostListWidgetState>();

  bool _showCategories = false;

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

  final List<SnRealm> _realms = List.empty(growable: true);

  Future<void> _fetchRealms() async {
    try {
      final rels = context.read<SnRealmProvider>();
      final out = await rels.listAvailableRealms();
      setState(() {
        _realms.addAll(out);
      });
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      rethrow;
    }
  }

  void _toggleShowCategories() {
    _showCategories = !_showCategories;
    if (_showCategories) {
      _tabController = TabController(length: _categories.length, vsync: this);
    } else {
      _tabController = TabController(length: kPostChannels.length, vsync: this);
    }
    _tabListen();
    setState(() {});
  }

  void _tabListen() {
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_showCategories) {
          _listKey.currentState?.setCategory(_categories[_tabController.index]);
          _listKey.currentState?.refreshPosts();
          return;
        }
        switch (_tabController.index) {
          case 0:
          case 3:
            _listKey.currentState?.setChannel(null);
            break;
          case 1:
            _listKey.currentState?.setChannel('friends');
            break;
          case 2:
            _listKey.currentState?.setChannel('following');
            break;
        }
        _listKey.currentState?.refreshPosts();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabListen();
    _fetchCategories();
    _fetchRealms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshPosts() async {
    await _listKey.currentState?.refreshPosts();
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
          Row(
            children: [
              Text('postDraftBox').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'postDraftBox'.tr(),
                onPressed: () {
                  GoRouter.of(context).pushNamed('postDraftBox');
                  _fabKey.currentState!.toggle();
                },
                child: const Icon(Symbols.box_edit),
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
                titleSpacing: 0,
                title: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: _listKey.currentState?.realm != null
                          ? AccountImage(
                              content: _listKey.currentState!.realm!.avatar,
                              radius: 14,
                            )
                          : const Icon(Symbols.group),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _PostListRealmPopup(
                            realms: _realms,
                            onUpdate: (realm) {
                              _listKey.currentState?.setRealm(realm);
                              _listKey.currentState?.refreshPosts();
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text('screenExplore').tr(),
                      ),
                    ),
                  ],
                ),
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Symbols.category),
                    style: _showCategories
                        ? ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondaryContainer,
                            ),
                          )
                        : null,
                    onPressed: () {
                      _toggleShowCategories();
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
                  isScrollable: _showCategories,
                  controller: _tabController,
                  tabs: _showCategories
                      ? [
                          for (final category in _categories)
                            Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                      kCategoryIcons[category.alias] ??
                                          Symbols.question_mark,
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .foregroundColor!),
                                  const Gap(8),
                                  Flexible(
                                    child: Text(
                                      'postCategory${category.alias.capitalize()}'
                                              .trExists()
                                          ? 'postCategory${category.alias.capitalize()}'
                                              .tr()
                                          : category.name,
                                      maxLines: 1,
                                    ).textColor(
                                      Theme.of(context)
                                          .appBarTheme
                                          .foregroundColor!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ]
                      : [
                          for (final channel in kPostChannels)
                            Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    kPostChannelIcons[
                                        kPostChannels.indexOf(channel)],
                                    size: 20,
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .foregroundColor,
                                  ),
                                  const Gap(8),
                                  Flexible(
                                    child: Text(
                                      'postChannel$channel',
                                      maxLines: 1,
                                    ).tr().textColor(
                                          Theme.of(context)
                                              .appBarTheme
                                              .foregroundColor,
                                        ),
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
        body: _PostListWidget(
          key: _listKey,
        ),
      ),
    );
  }
}

class _PostListWidget extends StatefulWidget {
  const _PostListWidget({super.key});

  @override
  State<_PostListWidget> createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<_PostListWidget> {
  bool _isBusy = false;

  SnRealm? get realm => _selectedRealm;

  final List<SnPost> _posts = List.empty(growable: true);
  SnRealm? _selectedRealm;
  String? _selectedChannel;
  SnPostCategory? _selectedCategory;
  int? _postCount;

  Future<void> _fetchPosts() async {
    if (_postCount != null && _posts.length >= _postCount!) return;

    setState(() => _isBusy = true);

    final pt = context.read<SnPostContentProvider>();
    final result = await pt.listPosts(
      take: 10,
      offset: _posts.length,
      categories: _selectedCategory != null ? [_selectedCategory!.alias] : null,
      channel: _selectedChannel,
      realm: _selectedRealm?.alias,
    );
    final out = result.$1;

    if (!mounted) return;

    _postCount = result.$2;
    _posts.addAll(out);

    if (mounted) setState(() => _isBusy = false);
  }

  void setChannel(String? channel) {
    _selectedChannel = channel;
    setState(() {});
  }

  void setRealm(SnRealm? realm) {
    _selectedRealm = realm;
    setState(() {});
  }

  void setCategory(SnPostCategory? category) {
    _selectedCategory = category;
    setState(() {});
  }

  Future<void> refreshPosts() {
    _postCount = null;
    _posts.clear();
    return _fetchPosts();
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
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
                  setState(() => _selectedCategory = null);
                  refreshPosts();
                },
              ),
            ],
            padding: const EdgeInsets.only(left: 20, right: 4),
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: RefreshIndicator(
              displacement: 40 + MediaQuery.of(context).padding.top,
              onRefresh: () => refreshPosts(),
              child: InfiniteList(
                padding: EdgeInsets.only(top: 8),
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
          ),
        ),
      ],
    );
  }
}

class _PostListRealmPopup extends StatelessWidget {
  final List<SnRealm>? realms;
  final Function(SnRealm?) onUpdate;

  const _PostListRealmPopup({
    required this.realms,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.face, size: 24),
            const Gap(16),
            Text('accountRealms', style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        ListTile(
          leading: const Icon(Symbols.close),
          title: Text('postInGlobal').tr(),
          subtitle: Text('postViewInGlobalDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          onTap: () {
            onUpdate.call(null);
            Navigator.pop(context);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: realms?.length ?? 0,
            itemBuilder: (context, idx) {
              final realm = realms![idx];
              return ListTile(
                title: Text(realm.name),
                subtitle: Text('@${realm.alias}'),
                leading: AccountImage(content: realm.avatar, radius: 18),
                onTap: () {
                  onUpdate.call(realm);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
