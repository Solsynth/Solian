import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/account_select.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class RealmDetailScreen extends StatefulWidget {
  final String alias;

  const RealmDetailScreen({super.key, required this.alias});

  @override
  State<RealmDetailScreen> createState() => _RealmDetailScreenState();
}

class _RealmDetailScreenState extends State<RealmDetailScreen> {
  SnRealm? _realm;

  Future<void> _fetchRealm() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/realms/${widget.alias}');
      _realm = SnRealm.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  List<SnPublisher>? _publishers;

  Future<void> _fetchPublishers() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/co/publishers?realm=${widget.alias}');
      _publishers = List<SnPublisher>.from(
        resp.data?.map((e) => SnPublisher.fromJson(e)) ?? [],
      );
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  List<SnChannel>? _channels;

  Future<void> _fetchChannels() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/im/channels/${widget.alias}/public');
      _channels = List<SnChannel>.from(
        resp.data.map((e) => SnChannel.fromJson(e)).cast<SnChannel>(),
      );
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRealm().then((_) {
      _fetchPublishers();
      _fetchChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: AppScaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: Text(_realm?.name ?? 'loading'.tr()),
                  bottom: TabBar(
                    tabs: [
                      Tab(
                          icon: Icon(Symbols.home,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                      Tab(
                          icon: Icon(Symbols.explore,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                      Tab(
                          icon: Icon(Symbols.group,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                      Tab(
                          icon: Icon(Symbols.settings,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _RealmDetailHomeWidget(
                  realm: _realm, publishers: _publishers, channels: _channels),
              _RealmPostListWidget(realm: _realm),
              _RealmMemberListWidget(realm: _realm),
              _RealmSettingsWidget(
                realm: _realm,
                onUpdate: () {
                  _fetchRealm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealmDetailHomeWidget extends StatelessWidget {
  final SnRealm? realm;
  final List<SnPublisher>? publishers;
  final List<SnChannel>? channels;

  const _RealmDetailHomeWidget(
      {required this.realm, this.publishers, this.channels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(24),
        if (realm != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                realm!.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                realm!.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ).padding(horizontal: 24),
        const Gap(16),
        const Divider(height: 1),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (publishers?.isNotEmpty ?? false)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Text('realmCommunityPublishersHint'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium)
                        .padding(horizontal: 24, vertical: 8),
                  ),
                ),
              SliverList.builder(
                itemCount: publishers?.length ?? 0,
                itemBuilder: (context, idx) {
                  final ele = publishers![idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: AccountImage(
                      content: ele.avatar,
                      fallbackWidget: const Icon(Symbols.group, size: 24),
                    ),
                    title: Text(ele.nick),
                    subtitle: Text('@${ele.name}'),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () {
                      GoRouter.of(context).pushNamed(
                        'postPublisher',
                        pathParameters: {'name': ele.name},
                      );
                    },
                  );
                },
              ),
              if (channels?.isNotEmpty ?? false)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Text('realmCommunityPublicChannelsHint'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium)
                        .padding(horizontal: 24, vertical: 8),
                  ),
                ),
              SliverList.builder(
                itemCount: channels?.length ?? 0,
                itemBuilder: (context, idx) {
                  final ele = channels![idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: AccountImage(
                      content: null,
                      fallbackWidget: const Icon(Symbols.chat, size: 20),
                    ),
                    title: Text(ele.name),
                    subtitle: Text('#${ele.alias}'),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () {
                      GoRouter.of(context).pushNamed(
                        'chatRoom',
                        pathParameters: {
                          'scope': realm?.alias ?? 'global',
                          'alias': ele.alias,
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealmPostListWidget extends StatefulWidget {
  final SnRealm? realm;

  const _RealmPostListWidget({this.realm});

  @override
  State<_RealmPostListWidget> createState() => _RealmPostListWidgetState();
}

class _RealmPostListWidgetState extends State<_RealmPostListWidget> {
  bool _isBusy = false;
  int? _totalCount;
  final List<SnPost> _posts = List.empty(growable: true);

  Future<void> _fetchPosts() async {
    setState(() => _isBusy = true);

    try {
      final pt = context.read<SnPostContentProvider>();
      final out = await pt.listPosts(
        take: 10,
        offset: _posts.length,
        realm: widget.realm?.id.toString(),
      );
      _totalCount = out.$2;
      _posts.addAll(out.$1);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: InfiniteList(
          itemCount: _posts.length,
          isLoading: _isBusy,
          hasReachedMax: _totalCount != null && _posts.length >= _totalCount!,
          onFetchData: _fetchPosts,
          itemBuilder: (context, idx) {
            final post = _posts[idx];
            return OpenablePostItem(
              data: post,
              maxWidth: 640,
              onChanged: (data) {
                setState(() => _posts[idx] = data);
              },
              onDeleted: () {
                setState(() => _posts.removeAt(idx));
              },
            );
          },
          separatorBuilder: (_, __) => const Divider().padding(vertical: 2),
        ),
      ),
    ).padding(top: 8);
  }
}

class _RealmMemberListWidget extends StatefulWidget {
  final SnRealm? realm;

  const _RealmMemberListWidget({this.realm});

  @override
  State<_RealmMemberListWidget> createState() => _RealmMemberListWidgetState();
}

class _RealmMemberListWidgetState extends State<_RealmMemberListWidget> {
  bool _isBusy = false;

  int? _totalCount;
  final List<SnRealmMember> _members = List.empty(growable: true);

  Future<void> _fetchMembers() async {
    setState(() => _isBusy = true);

    try {
      final ud = context.read<UserDirectoryProvider>();
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
          '/cgi/id/realms/${widget.realm!.alias}/members',
          queryParameters: {
            'take': 10,
            'offset': _members.length,
          });

      final out = List<SnRealmMember>.from(
        resp.data['data']?.map((e) => SnRealmMember.fromJson(e)) ?? [],
      );

      await ud.listAccount(out.map((ele) => ele.accountId).toSet());

      _totalCount = resp.data['count'];
      _members.addAll(out);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  bool _isUpdating = false;

  Future<void> _deleteMember(SnRealmMember member) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete(
        '/cgi/id/realms/${widget.realm!.alias}/members/${member.id}',
      );
      if (!mounted) return;
      _members.clear();
      _fetchMembers();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _addMember(SnAccount related) async {
    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/id/realms/${widget.realm!.alias}/members',
        data: {'related': related.name},
      );
      if (!mounted) return;
      context.showSnackbar('realmMemberAdded'.tr());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _showMemberAdd() async {
    final user = await showModalBottomSheet<SnAccount?>(
      context: context,
      builder: (context) => AccountSelect(
        title: 'realmMemberAdd'.tr(),
      ),
    );
    if (!mounted) return;
    if (user == null) return;
    _addMember(user);
  }

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.group_add),
            trailing: const Icon(Symbols.chevron_right),
            title: Text('realmMemberAdd').tr(),
            subtitle: Text('realmMemberAddDescription').tr(),
            onTap: _showMemberAdd,
          ),
        ),
        SliverToBoxAdapter(child: const Divider(height: 1)),
        SliverInfiniteList(
          // padding: EdgeInsets.zero,
          itemCount: _members.length,
          isLoading: _isBusy,
          hasReachedMax: _totalCount != null && _members.length >= _totalCount!,
          onFetchData: _fetchMembers,
          itemBuilder: (context, index) {
            final member = _members[index];
            return ListTile(
              contentPadding: const EdgeInsets.only(right: 24, left: 16),
              leading: AccountImage(
                content: ud.getFromCache(member.accountId)?.avatar,
                fallbackWidget: const Icon(Symbols.group, size: 24),
              ),
              title: Text(
                ud.getFromCache(member.accountId)?.nick ?? 'unknown'.tr(),
              ),
              subtitle: Text(
                ud.getFromCache(member.accountId)?.name ?? 'unknown'.tr(),
              ),
              trailing: IconButton(
                icon: const Icon(Symbols.person_remove),
                onPressed: _isUpdating ? null : () => _deleteMember(member),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RealmSettingsWidget extends StatefulWidget {
  final SnRealm? realm;
  final Function() onUpdate;

  const _RealmSettingsWidget({required this.realm, required this.onUpdate});

  @override
  State<_RealmSettingsWidget> createState() => _RealmSettingsWidgetState();
}

class _RealmSettingsWidgetState extends State<_RealmSettingsWidget> {
  bool _isBusy = false;

  Future<void> _deleteRealm() async {
    final confirm = await context.showConfirmDialog(
      'realmDelete'.tr(args: ['#${widget.realm!.alias}']),
      'realmDeleteDescription'.tr(),
    );
    if (!confirm) return;

    if (!mounted) return;
    final sn = context.read<SnNetworkProvider>();

    setState(() => _isBusy = true);

    try {
      await sn.client.delete('/cgi/id/realms/${widget.realm!.id}');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _leaveRealm() async {
    final confirm = await context.showConfirmDialog(
      'realmLeave'.tr(),
      'realmLeaveDescription'.tr(),
    );
    if (!confirm) return;
    if (!mounted) return;

    final sn = context.read<SnNetworkProvider>();

    try {
      await sn.client.delete('/cgi/id/realms/${widget.realm!.alias}/me');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();

    final isOwned = ua.isAuthorized && widget.realm?.accountId == ua.user?.id;

    return Column(
      children: [
        const Gap(8),
        ListTile(
          leading: const Icon(Symbols.logout),
          trailing: const Icon(Symbols.chevron_right),
          title: Text('realmLeave').tr(),
          subtitle: Text('realmLeaveDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          onTap: _isBusy ? null : () => _leaveRealm(),
        ),
        if (isOwned)
          ListTile(
            leading: const Icon(Symbols.edit),
            trailing: const Icon(Symbols.chevron_right),
            title: Text('realmEdit').tr(),
            subtitle: Text('realmEditDescription').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              GoRouter.of(context).pushNamed(
                'realmManage',
                queryParameters: {'editing': widget.realm!.alias},
              ).then((value) {
                if (value != null) {
                  widget.onUpdate();
                }
              });
            },
          ),
        if (isOwned)
          ListTile(
            leading: const Icon(Symbols.delete),
            trailing: const Icon(Symbols.chevron_right),
            title: Text('realmActionDelete').tr(),
            subtitle: Text('realmActionDeleteDescription').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: _isBusy ? null : _deleteRealm,
          ),
      ],
    );
  }
}
