import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/screens/chat/room.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/account_select.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_background.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/unauthorized_hint.dart';
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

  Future<void> _fetchWhatsNew() async {
    final sn = context.read<SnNetworkProvider>();
    final resp = await sn.client.get('/cgi/im/whats-new');
    if (resp.data == null) return;
    final List<dynamic> out = resp.data;
    setState(() {
      _unreadCounts = {for (var v in out) v['channel_id']: v['count']};
    });
  }

  void _refreshChannels({bool noRemote = false}) {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) {
      setState(() => _isBusy = false);
      return;
    }

    final chan = context.read<ChatChannelProvider>();
    chan.fetchChannels(noRemote: noRemote).listen((channels) async {
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

  SnChannel? _focusChannel;

  @override
  void initState() {
    super.initState();
    _refreshChannels();
    _fetchWhatsNew();
  }

  void _onTapChannel(SnChannel channel) {
    final doExpand = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    if (doExpand) {
      setState(() => _focusChannel = channel);
      return;
    }
    GoRouter.of(context).pushNamed(
      'chatRoom',
      pathParameters: {
        'scope': channel.realm?.alias ?? 'global',
        'alias': channel.alias,
      },
    ).then((value) {
      if (mounted) {
        _unreadCounts?[channel.id] = 0;
        setState(() => _unreadCounts?[channel.id] = 0);
        _refreshChannels(noRemote: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();

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

    final doExpand = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    final chatList = AppScaffold(
      noBackground: doExpand,
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
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Symbols.close, size: 28),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
          shape: const CircleBorder(),
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
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: RefreshIndicator(
                onRefresh: () => Future.wait([
                  Future.sync(() => _refreshChannels()),
                  _fetchWhatsNew(),
                ]),
                child: ListView.builder(
                  itemCount: _channels?.length ?? 0,
                  itemBuilder: (context, idx) {
                    final channel = _channels![idx];
                    final lastMessage = _lastMessages?[channel.id];

                    return _ChatChannelEntry(
                      channel: channel,
                      lastMessage: lastMessage,
                      unreadCount: _unreadCounts?[channel.id],
                      onTap: () {
                        if (doExpand) {
                          _unreadCounts?[channel.id] = 0;
                          setState(() => _focusChannel = channel);
                          return;
                        }
                        _onTapChannel(channel);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (doExpand) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            SizedBox(width: 340, child: chatList),
            const VerticalDivider(width: 1),
            if (_focusChannel != null)
              Expanded(
                child: ChatRoomScreen(
                  key: ValueKey(_focusChannel!.id),
                  scope: _focusChannel!.realm?.alias ?? 'global',
                  alias: _focusChannel!.alias,
                ),
              ),
          ],
        ),
      );
    }

    return chatList;
  }
}

class _ChatChannelEntry extends StatelessWidget {
  final SnChannel channel;
  final int? unreadCount;
  final SnChatMessage? lastMessage;
  final Function? onTap;
  const _ChatChannelEntry({
    required this.channel,
    this.unreadCount,
    this.lastMessage,
    this.onTap,
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
        ? ud.getAccountFromCache(otherMember.accountId)?.nick ?? channel.name
        : channel.name;

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
                  label: Text(ud
                          .getAccountFromCache(lastMessage!.sender.accountId)
                          ?.nick ??
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
            ? ud.getAccountFromCache(otherMember.accountId)?.avatar
            : channel.realm?.avatar,
        fallbackWidget: const Icon(Symbols.chat, size: 20),
      ),
      onTap: () => onTap?.call(),
    );
  }
}
