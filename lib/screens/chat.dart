import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/account_select.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/unauthorized_hint.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();

  bool _isBusy = true;

  List<SnChannel>? _channels;
  Map<int, SnChatMessage>? _lastMessages;
  Map<int, int>? _unreadCounts;
  Map<int, int>? _unreadCountsGrouped;

  Future<void> _fetchWhatsNew() async {
    final sn = context.read<SnNetworkProvider>();
    final resp = await sn.client.get('/cgi/im/whats-new');
    if (resp.data == null) return;
    final List<dynamic> out = resp.data;
    setState(() {
      _unreadCounts ??= {};
      _unreadCountsGrouped ??= {};
      for (var v in out) {
        _unreadCounts![v['channel_id']] = v['count'];
        final channel =
            _channels?.firstWhereOrNull((ele) => ele.id == v['channel_id']);
        if (channel != null) {
          if (channel.realmId != null) {
            _unreadCountsGrouped![channel.realmId!] ??= 0;
            _unreadCountsGrouped![channel.realmId!] =
                (_unreadCountsGrouped![channel.realmId!]! + v['count']).toInt();
          }
          if (channel.type == 1) {
            _unreadCountsGrouped![0] ??= 0;
            _unreadCountsGrouped![0] =
                (_unreadCountsGrouped![0]! + v['count']).toInt();
          }
        }
      }
    });
  }

  void _refreshChannels({bool withBoost = false, bool noRemote = false}) {
    final ct = context.read<ChatChannelProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) {
      setState(() => _isBusy = false);
      return;
    }

    if (!withBoost) {
      if (!noRemote) {
        ct.refreshAvailableChannels();
      }
    } else {
      setState(() {
        _channels = ct.availableChannels;
      });
    }

    final chan = context.read<ChatChannelProvider>();
    chan.fetchChannels(noRemote: true).listen((channels) async {
      final lastMessages = await chan.getLastMessages(channels);
      _lastMessages = {for (final val in lastMessages) val.channelId: val};
      channels.sort((a, b) {
        if (_lastMessages!.containsKey(a.id) &&
            _lastMessages!.containsKey(b.id)) {
          return _lastMessages![b.id]!
              .createdAt
              .compareTo(_lastMessages![a.id]!.createdAt);
        }
        if (_lastMessages!.containsKey(a.id)) return -1;
        if (_lastMessages!.containsKey(b.id)) return 1;
        return 0;
      });

      if (!mounted) return;
      final ud = context.read<UserDirectoryProvider>();
      final idSet = <int>{};
      for (final channel in channels) {
        if (channel.type == 1) {
          idSet.addAll(
            channel.members
                    ?.cast<SnChannelMember?>()
                    .map((ele) => ele?.accountId)
                    .where((ele) => ele != null)
                    .cast<int>() ??
                [],
          );
        }
      }
      if (idSet.isNotEmpty) await ud.listAccount(idSet);

      if (mounted) setState(() => _channels = channels);
    })
      ..onError((err) {
        if (!mounted) return;
        context.showErrorDialog(err);
        setState(() => _isBusy = false);
      })
      ..onDone(() {
        if (!mounted) return;
        setState(() => _isBusy = false);
        _fetchWhatsNew();
      });
  }

  void _newDirectMessage() async {
    final user = await showModalBottomSheet(
      context: context,
      builder: (context) =>
          AccountSelect(title: 'channelNewDirectMessage'.tr()),
    );
    if (user == null) return;
    if (!mounted) return;

    try {
      const uuid = Uuid();
      final sn = context.read<SnNetworkProvider>();
      final ua = context.read<UserProvider>();
      await sn.client.post('/cgi/im/channels/global/dm', data: {
        'alias': uuid.v4().replaceAll('-', '').substring(0, 12),
        'name': 'DM',
        'description':
            'A direct message channel between @${ua.user?.name} and @${user.name}',
        'related_user': user.id,
      });
      _fabKey.currentState!.toggle();
      _refreshChannels();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshChannels(withBoost: true);
  }

  void _onTapChannel(SnChannel channel) {
    setState(() => _unreadCounts?[channel.id] = 0);
    if (ResponsiveScaffold.getIsExpand(context)) {
      GoRouter.of(context).pushReplacementNamed(
        'chatRoom',
        pathParameters: {
          'scope': channel.realm?.alias ?? 'global',
          'alias': channel.alias,
        },
      ).then((value) {
        if (mounted) {
          setState(() => _unreadCounts?[channel.id] = 0);
          _refreshChannels(noRemote: true);
        }
      });
    } else {
      GoRouter.of(context).pushNamed(
        'chatRoom',
        pathParameters: {
          'scope': channel.realm?.alias ?? 'global',
          'alias': channel.alias,
        },
      ).then((value) {
        if (mounted) {
          setState(() => _unreadCounts?[channel.id] = 0);
          _refreshChannels(noRemote: true);
        }
      });
    }
  }

  SnRealm? _focusedRealm;
  bool _isDirect = false;

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();
    final sn = context.read<SnNetworkProvider>();
    final rel = context.read<SnRealmProvider>();

    if (!ua.isAuthorized) {
      return AppScaffold(
        appBar: AppBar(
          leading: AutoAppBarLeading(),
          title: Text('screenChat').tr(),
        ),
        body: Center(
          child: UnauthorizedHint(),
        ),
      );
    }

    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        leading: AutoAppBarLeading(),
        title: Text('screenChat').tr(),
      ),
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
              Text('channelNewChannel').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'channelNewChannel'.tr(),
                onPressed: () {
                  _fabKey.currentState!.toggle();
                  GoRouter.of(context).pushNamed('chatManage').then((value) {
                    if (value != null && context.mounted) _refreshChannels();
                  });
                },
                child: const Icon(Symbols.chat_add_on),
              ),
            ],
          ),
          Row(
            children: [
              Text('channelNewDirectMessage').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'channelNewDirectMessage'.tr(),
                onPressed: _newDirectMessage,
                child: const Icon(Symbols.communication),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          if (_channels != null && ResponsiveScaffold.getIsExpand(context))
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _refreshChannels()),
                child: Builder(builder: (context) {
                  final scopeList = ListView(
                    key: const Key('realm-list-view'),
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        minTileHeight: 48,
                        leading:
                            const Icon(Symbols.inbox_text).padding(right: 4),
                        contentPadding: EdgeInsets.only(left: 24, right: 24),
                        title: Text('chatDirect').tr(),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_unreadCountsGrouped?[0] != null &&
                                (_unreadCountsGrouped?[0] ?? 0) > 0)
                              Badge(
                                label: Text(
                                  _unreadCountsGrouped![0].toString(),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() => _isDirect = true);
                        },
                      ),
                      ...rel.availableRealms.map((ele) {
                        return ListTile(
                          minTileHeight: 48,
                          contentPadding: EdgeInsets.only(left: 20, right: 24),
                          leading: AccountImage(
                            content: ele.avatar,
                            radius: 16,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_unreadCountsGrouped?[ele.id] != null &&
                                  (_unreadCountsGrouped?[ele.id] ?? 0) > 0)
                                Badge(
                                  label: Text(
                                    _unreadCountsGrouped![ele.id].toString(),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(ele.name),
                          onTap: () {
                            setState(() => _focusedRealm = ele);
                          },
                        );
                      }),
                    ],
                  );

                  final directChatList = ListView(
                    key: Key('direct-chat-list-view'),
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        minTileHeight: 48,
                        leading: const Icon(Symbols.arrow_left_alt),
                        contentPadding: EdgeInsets.only(left: 24),
                        title: Text('back').tr(),
                        onTap: () {
                          setState(() => _isDirect = false);
                        },
                      ),
                      const Divider(height: 1),
                      ..._channels!.where((ele) => ele.type == 1).map(
                        (ele) {
                          return _ChatChannelEntry(
                            channel: ele,
                            unreadCount: _unreadCounts?[ele.id],
                            lastMessage: _lastMessages?[ele.id],
                            isCompact: true,
                            onTap: () => _onTapChannel(ele),
                          );
                        },
                      )
                    ],
                  );

                  final realmScopedChatList = _focusedRealm == null
                      ? const SizedBox.shrink()
                      : ListView(
                          key: ValueKey(_focusedRealm),
                          padding: EdgeInsets.zero,
                          children: [
                            if (_focusedRealm!.banner != null)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: AutoResizeUniversalImage(
                                  sn.getAttachmentUrl(
                                    _focusedRealm!.banner!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ListTile(
                              minTileHeight: 48,
                              tileColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              leading: AccountImage(
                                content: _focusedRealm!.avatar,
                                radius: 16,
                              ),
                              contentPadding: EdgeInsets.only(
                                left: 20,
                                right: 16,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Symbols.close),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setState(() => _focusedRealm = null);
                                },
                              ),
                              title: Text(_focusedRealm!.name),
                            ),
                            ...(_channels!
                                .where(
                                    (ele) => ele.realmId == _focusedRealm?.id)
                                .map(
                              (ele) {
                                return _ChatChannelEntry(
                                  channel: ele,
                                  unreadCount: _unreadCounts?[ele.id],
                                  lastMessage: _lastMessages?[ele.id],
                                  onTap: () => _onTapChannel(ele),
                                  isCompact: true,
                                );
                              },
                            ))
                          ],
                        );

                  return PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child,
                        Animation<double> primaryAnimation,
                        Animation<double> secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        fillColor: Colors.transparent,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    child: (_focusedRealm == null && !_isDirect)
                        ? scopeList
                        : _isDirect
                            ? directChatList
                            : realmScopedChatList,
                  );
                }),
              ),
            )
          else if (_channels != null)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _refreshChannels()),
                child: ListView(
                  key: const Key('chat-list-view'),
                  padding: EdgeInsets.zero,
                  children: [
                    ...(_channels!.map((ele) {
                      return _ChatChannelEntry(
                        channel: ele,
                        unreadCount: _unreadCounts?[ele.id],
                        lastMessage: _lastMessages?[ele.id],
                        onTap: () => _onTapChannel(ele),
                      );
                    }))
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatChannelEntry extends StatelessWidget {
  final SnChannel channel;
  final int? unreadCount;
  final SnChatMessage? lastMessage;
  final Function? onTap;
  final bool isCompact;
  const _ChatChannelEntry({
    required this.channel,
    this.unreadCount,
    this.lastMessage,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();
    final ua = context.read<UserProvider>();

    final otherMember = channel.type == 1
        ? channel.members?.cast<SnChannelMember?>().firstWhere(
              (ele) => ele?.accountId != ua.user?.id,
              orElse: () => null,
            )
        : null;

    final title = otherMember != null
        ? ud.getFromCache(otherMember.accountId)?.nick ?? channel.name
        : channel.name;

    if (isCompact) {
      return ListTile(
        minTileHeight: 48,
        contentPadding:
            EdgeInsets.only(left: otherMember != null ? 20 : 24, right: 24),
        leading: otherMember != null
            ? AccountImage(
                content: ud.getFromCache(otherMember.accountId)?.avatar,
                radius: 16,
              )
            : const Icon(Symbols.tag),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (unreadCount != null && (unreadCount ?? 0) > 0)
              Badge(
                label: Text(unreadCount.toString()),
              ),
          ],
        ),
        title: Text(title),
        onTap: () {
          onTap?.call();
        },
      );
    }

    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(title)),
          const Gap(8),
          if (unreadCount != null && unreadCount! > 0)
            Badge(
              label: Text(unreadCount.toString()),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Row(
              children: [
                Badge(
                  label: Text(
                      ud.getFromCache(lastMessage!.sender.accountId)?.nick ??
                          'unknown'.tr()),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    lastMessage!.body['algorithm'] == 'plain'
                        ? lastMessage!.body['text'] ??
                            'messageUnablePreview'.tr()
                        : 'messageUnablePreviewEncrypted'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: lastMessage!.body['algorithm'] != 'plain' ||
                            lastMessage!.body['text'] == null
                        ? TextStyle(fontStyle: FontStyle.italic)
                        : null,
                  ),
                ),
                const Gap(4),
                Text(
                  DateFormat(
                    lastMessage!.createdAt.toLocal().day == DateTime.now().day
                        ? 'HH:mm'
                        : lastMessage!.createdAt.toLocal().year ==
                                DateTime.now().year
                            ? 'MM/dd'
                            : 'yy/MM/dd',
                  ).format(lastMessage!.createdAt.toLocal()),
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                  ),
                ),
              ],
            )
          : Text(
              channel.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: AccountImage(
        content: otherMember != null
            ? ud.getFromCache(otherMember.accountId)?.avatar
            : channel.realm?.avatar,
        fallbackWidget: const Icon(Symbols.tag, size: 20),
      ),
      onTap: () => onTap?.call(),
    );
  }
}
