import 'dart:ui';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

import '../../providers/relationship.dart';
import '../abuse_report.dart';

class PostPublisherScreen extends StatefulWidget {
  final String name;

  const PostPublisherScreen({super.key, required this.name});

  @override
  State<PostPublisherScreen> createState() => _PostPublisherScreenState();
}

class _PostPublisherScreenState extends State<PostPublisherScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final TabController _tabController =
      TabController(length: 5, vsync: this);

  SnPublisher? _publisher;
  SnAccount? _account;
  SnRelationship? _accountRelationship;
  SnRealm? _realm;

  Future<void> _fetchPublisher() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/co/publishers/${widget.name}');
      if (!mounted) return;
      _publisher = SnPublisher.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err).then((_) {
        if (mounted) Navigator.pop(context);
      });
      rethrow;
    } finally {
      setState(() {});
    }

    try {
      final sn = context.read<SnNetworkProvider>();
      final ud = context.read<UserDirectoryProvider>();
      final rel = context.read<SnRelationshipProvider>();
      _account = await ud.getAccount(_publisher?.accountId);
      _accountRelationship = await rel.getRelationship(_account!.id);
      if (_publisher?.realmId != null && _publisher!.realmId != 0) {
        final resp =
            await sn.client.get('/cgi/id/realms/${_publisher!.realmId}');
        _realm = SnRealm.fromJson(resp.data);
      }
    } catch (_) {
      // ignore
    }
  }

  bool _isSubscribing = false;
  SnSubscription? _subscription;

  Future<void> _fetchSubscription() async {
    try {
      setState(() => _isSubscribing = true);

      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/co/subscriptions/users/${_publisher!.id}',
      );
      if (!mounted) return;
      _subscription = SnSubscription.fromJson(resp.data);
    } catch (_) {
      // ignore due to maybe 404
    } finally {
      setState(() => _isSubscribing = false);
    }
  }

  Future<void> _toggleSubscription() async {
    if (_subscription == null) {
      try {
        setState(() => _isSubscribing = true);

        final sn = context.read<SnNetworkProvider>();
        final resp = await sn.client.post(
          '/cgi/co/subscriptions/users/${_publisher!.id}',
        );
        if (!mounted) return;
        _subscription = SnSubscription.fromJson(resp.data);
      } catch (err) {
        if (!mounted) return;
        context.showErrorDialog(err);
      } finally {
        setState(() => _isSubscribing = false);
      }
    } else {
      try {
        setState(() => _isSubscribing = true);

        final sn = context.read<SnNetworkProvider>();
        await sn.client.delete(
          '/cgi/co/subscriptions/users/${_publisher!.id}',
        );
        if (!mounted) return;
        _subscription = null;
      } catch (err) {
        if (!mounted) return;
        context.showErrorDialog(err);
      } finally {
        setState(() => _isSubscribing = false);
      }
    }
  }

  double _appBarBlur = 0.0;

  late final _appBarWidth = MediaQuery.of(context).size.width;
  late final _appBarHeight =
      math.min((_appBarWidth * kBannerAspectRatio), 360).roundToDouble();

  void _updateAppBarBlur() {
    if (_scrollController.offset > _appBarHeight) return;
    setState(() {
      _appBarBlur =
          (_scrollController.offset / _appBarHeight * 10).clamp(0.0, 10.0);
    });
  }

  bool _isBusy = false;

  int? _postCount;
  final List<SnPost> _posts = List.empty(growable: true);

  Future<void> _fetchPosts() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final pt = context.read<SnPostContentProvider>();
      final result = await pt.listPosts(
        offset: _posts.length,
        author: widget.name,
        type: switch (_tabController.index) {
          1 => 'story',
          2 => 'article',
          3 => 'question',
          4 => 'video',
          _ => null,
        },
      );
      _postCount = result.$2;
      _posts.addAll(result.$1);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  bool _isWorking = false;

  Future<void> _blockPublisher() async {
    if (_isWorking) return;

    final confirm = await context.showConfirmDialog(
      'publisherBlockHint'.tr(args: ['@${_publisher?.name ?? 'unknown'.tr()}']),
      'publisherBlockHintDescription'.tr(),
    );
    if (!confirm) return;
    if (!mounted) return;

    setState(() => _isWorking = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/users/me/relations/block', data: {
        'related': _account!.name,
      });
      if (!mounted) return;
      context.showSnackbar(
          'userBlocked'.tr(args: ['@${_account?.name ?? 'unknown'.tr()}']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isWorking = false);
    }
  }

  Future<void> _unblockPublisher() async {
    if (_isWorking) return;

    setState(() => _isWorking = true);

    try {
      final rel = context.read<SnRelationshipProvider>();
      await rel.updateRelationship(
          _account!.id, 1, _accountRelationship?.permNodes ?? {});
      if (!mounted) return;
      context.showSnackbar(
          'userUnblocked'.tr(args: ['@${_account?.name ?? 'unknown'.tr()}']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isWorking = false);
    }
  }

  void _updateFetchType() {
    _posts.clear();
    _fetchPosts();
  }

  void _showAbuseReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AbuseReportDialog(
        resourceLocation: 'pub:${_publisher?.name}',
      ),
    ).then((value) {
      if (value == true && mounted) {
        _fetchPosts();
        context.showSnackbar('abuseReportSubmitted'.tr());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPublisher().then((_) {
      _fetchPosts();
      _fetchSubscription();
    });
    _scrollController.addListener(_updateAppBarBlur);
    _tabController.addListener(_updateFetchType);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateAppBarBlur);
    _scrollController.dispose();
    _tabController.removeListener(_updateFetchType);
    _tabController.dispose();
    super.dispose();
  }

  static const kBannerAspectRatio = 7 / 16;

  @override
  Widget build(BuildContext context) {
    final imageHeight = _appBarHeight + kToolbarHeight + 8;

    const labelShadows = <Shadow>[
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 5.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ];

    final sn = context.read<SnNetworkProvider>();

    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: MultiSliver(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      appBarTheme: Theme.of(context).appBarTheme.copyWith(
                            foregroundColor: Colors.white,
                          ),
                    ),
                    child: SliverAppBar(
                      expandedHeight: _appBarHeight,
                      leading: const PageBackButton(),
                      title: _publisher == null
                          ? Text('loading').tr()
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: _publisher!.nick,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.white,
                                        shadows: labelShadows,
                                      ),
                                ),
                                const TextSpan(text: '\n'),
                                TextSpan(
                                  text: '@${_publisher!.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Colors.white,
                                        shadows: labelShadows,
                                      ),
                                ),
                              ]),
                            ),
                      pinned: true,
                      flexibleSpace: _publisher != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_publisher!.banner.isNotEmpty)
                                  UniversalImage(
                                    sn.getAttachmentUrl(_publisher!.banner),
                                    fit: BoxFit.cover,
                                    height: imageHeight,
                                    width: _appBarWidth,
                                    cacheHeight: imageHeight,
                                    cacheWidth: _appBarWidth,
                                  )
                                else
                                  Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                  ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height:
                                      56 + MediaQuery.of(context).padding.top,
                                  child: ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: _appBarBlur,
                                        sigmaY: _appBarBlur,
                                      ),
                                      child: Container(
                                        color: Colors.black.withOpacity(
                                          clampDouble(
                                              _appBarBlur * 0.1, 0, 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  if (_publisher != null)
                    SliverToBoxAdapter(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AccountImage(
                                  content: _publisher!.avatar,
                                  radius: 28,
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _publisher!.nick,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ).bold(),
                                      Text('@${_publisher!.name}').fontSize(13),
                                    ],
                                  ),
                                ),
                                if (_subscription == null)
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                      elevation: WidgetStatePropertyAll(0),
                                    ),
                                    onPressed: _isSubscribing
                                        ? null
                                        : _toggleSubscription,
                                    label: Text('subscribe').tr(),
                                    icon: const Icon(Symbols.add),
                                  )
                                else
                                  OutlinedButton.icon(
                                    style: ButtonStyle(
                                      elevation: WidgetStatePropertyAll(0),
                                    ),
                                    onPressed: _isSubscribing
                                        ? null
                                        : _toggleSubscription,
                                    label: Text('unsubscribe').tr(),
                                    icon: const Icon(Symbols.remove),
                                  ),
                                PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  style: ButtonStyle(
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          const Icon(Symbols.flag),
                                          const Gap(16),
                                          Text('report').tr(),
                                        ],
                                      ),
                                      onTap: () => _showAbuseReportDialog(),
                                    ),
                                    if (_accountRelationship?.status != 2)
                                      PopupMenuItem(
                                        onTap: _blockPublisher,
                                        child: Row(
                                          children: [
                                            const Icon(Symbols.block),
                                            const Gap(16),
                                            Text('friendBlock').tr(),
                                          ],
                                        ),
                                      )
                                    else
                                      PopupMenuItem(
                                        onTap: _unblockPublisher,
                                        child: Row(
                                          children: [
                                            const Icon(Symbols.block),
                                            const Gap(16),
                                            Text('friendUnblock').tr(),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Gap(12),
                            Text(_publisher!.description)
                                .padding(horizontal: 8),
                            const Gap(12),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Symbols.calendar_add_on),
                                    const Gap(8),
                                    Text('publisherJoinedAt').tr(args: [
                                      DateFormat('y/M/d')
                                          .format(_publisher!.createdAt)
                                    ]),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Symbols.trending_up),
                                    const Gap(8),
                                    Text('publisherSocialPointTotal').plural(
                                      _publisher!.totalUpvote -
                                          _publisher!.totalDownvote,
                                    ),
                                  ],
                                ),
                                if (_realm != null)
                                  Row(
                                    children: [
                                      const Icon(Symbols.group_work),
                                      const Gap(8),
                                      InkWell(
                                        child: Text('publisherAffiliatedBy')
                                            .tr(args: [
                                          '@${_realm?.alias ?? 'unknown'}',
                                        ]),
                                        onTap: () {
                                          GoRouter.of(context).pushNamed(
                                            'realmDetail',
                                            pathParameters: {
                                              'alias': _realm!.alias
                                            },
                                          );
                                        },
                                      ),
                                      const Gap(8),
                                      AccountImage(
                                          content: _realm?.avatar, radius: 8),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    const Icon(Symbols.tools_wrench),
                                    const Gap(8),
                                    InkWell(
                                      child: Text('publisherRunBy').tr(args: [
                                        '@${_account?.name ?? 'unknown'}',
                                      ]),
                                      onTap: () {
                                        GoRouter.of(context).pushNamed(
                                          'accountProfilePage',
                                          pathParameters: {
                                            'name': _account!.name,
                                          },
                                        );
                                      },
                                    ),
                                    const Gap(8),
                                    AccountImage(
                                        content: _account?.avatar, radius: 8),
                                  ],
                                ),
                              ],
                            ).padding(horizontal: 8),
                          ],
                        ).padding(all: 16),
                      ).center(),
                    ),
                  SliverToBoxAdapter(child: const Divider(height: 1)),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: Icon(
                          Symbols.pages,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Symbols.sticky_note_2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Symbols.article,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Symbols.help,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Symbols.video_call,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(child: const Divider(height: 1)),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Gap(math.max(MediaQuery.of(context).padding.top, 64)),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.filled(
                  3,
                  _PublisherPostList(
                    isBusy: _isBusy,
                    postCount: _postCount,
                    posts: _posts,
                    fetchPosts: _fetchPosts,
                    onChanged: (idx, data) {
                      setState(() => _posts[idx] = data);
                    },
                    onDeleted: () {
                      _posts.clear();
                      _fetchPosts();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublisherPostList extends StatelessWidget {
  final bool isBusy;
  final int? postCount;
  final List<SnPost> posts;
  final void Function() fetchPosts;
  final void Function(int index, SnPost data) onChanged;
  final void Function() onDeleted;

  const _PublisherPostList({
    required this.isBusy,
    required this.postCount,
    required this.posts,
    required this.fetchPosts,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return InfiniteList(
      itemCount: posts.length,
      isLoading: isBusy,
      hasReachedMax: postCount != null && posts.length >= postCount!,
      onFetchData: fetchPosts,
      itemBuilder: (context, idx) {
        return OpenablePostItem(
          data: posts[idx],
          maxWidth: 640,
          onChanged: (data) {
            onChanged(idx, data);
          },
          onDeleted: onDeleted,
        );
      },
      separatorBuilder: (_, __) => const Divider().padding(vertical: 2),
    );
  }
}
