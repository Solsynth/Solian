import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/screens/chat/room.dart';
import 'package:surface/screens/post/post_editor.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';

class AppSharingListener extends StatefulWidget {
  final Widget child;

  const AppSharingListener({super.key, required this.child});

  @override
  State<AppSharingListener> createState() => _AppSharingListenerState();
}

class _AppSharingListenerState extends State<AppSharingListener> {
  late StreamSubscription _shareIntentSubscription;

  void _gotoPost(Iterable<SharedMediaFile> value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('shareIntent').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('shareIntentDescription').tr(),
              const Gap(8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      leading: Icon(Icons.post_add),
                      trailing: const Icon(Icons.chevron_right),
                      title: Text('shareIntentPostStory').tr(),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          'postEditor',
                          pathParameters: {
                            'mode': 'stories',
                          },
                          extra: PostEditorExtra(
                            text: value
                                .where((e) => [
                                      SharedMediaType.text,
                                      SharedMediaType.url
                                    ].contains(e.type))
                                .map((e) => e.path)
                                .join('\n'),
                            attachments: value
                                .where((e) => [
                                      SharedMediaType.video,
                                      SharedMediaType.file,
                                      SharedMediaType.image
                                    ].contains(e.type))
                                .map((e) =>
                                    PostWriteMedia.fromFile(XFile(e.path)))
                                .toList(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      leading: Icon(Icons.chat_outlined),
                      trailing: const Icon(Icons.chevron_right),
                      title: Text('shareIntentSendChannel').tr(),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              _ShareIntentChannelSelect(value: value),
                        ).then((val) {
                          if (!context.mounted) return;
                          if (val == true) Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ).width(280),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('dialogDismiss').tr(),
            )
          ],
        ),
      );
    });
  }

  void _initialize() async {
    _shareIntentSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isEmpty) return;
      if (mounted) {
        _gotoPost(value);
      }
    }, onError: (err) {
      log("[ShareIntent] Unable to subscribe: $err");
    });
  }

  void _initialHandle() {
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isEmpty) return;
      if (mounted) {
        _gotoPost(value);
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _initialize();
      _initialHandle();
    }
  }

  @override
  void dispose() {
    _shareIntentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ShareIntentChannelSelect extends StatefulWidget {
  final Iterable<SharedMediaFile> value;

  const _ShareIntentChannelSelect({required this.value});

  @override
  State<_ShareIntentChannelSelect> createState() =>
      _ShareIntentChannelSelectState();
}

class _ShareIntentChannelSelectState extends State<_ShareIntentChannelSelect> {
  bool _isBusy = true;

  List<SnChannel>? _channels;
  Map<int, SnChatMessage>? _lastMessages;

  void _refreshChannels() {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) {
      setState(() => _isBusy = false);
      return;
    }

    final chan = context.read<ChatChannelProvider>();
    chan.fetchChannels().listen((channels) async {
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
      for (final channel in channels) {
        if (channel.type == 1) {
          await ud.listAccount(
            channel.members
                    ?.cast<SnChannelMember?>()
                    .map((ele) => ele?.accountId)
                    .where((ele) => ele != null)
                    .toSet() ??
                {},
          );
        }
      }

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

  @override
  void initState() {
    super.initState();
    _refreshChannels();
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.read<UserProvider>();
    final ud = context.read<UserDirectoryProvider>();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.chat, size: 24),
            const Gap(16),
            Text('shareIntentSendChannel',
                    style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        LoadingIndicator(isActive: _isBusy),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _refreshChannels()),
              child: ListView.builder(
                itemCount: _channels?.length ?? 0,
                itemBuilder: (context, idx) {
                  final channel = _channels![idx];
                  final lastMessage = _lastMessages?[channel.id];

                  if (channel.type == 1) {
                    final otherMember =
                        channel.members?.cast<SnChannelMember?>().firstWhere(
                              (ele) => ele?.accountId != ua.user?.id,
                              orElse: () => null,
                            );

                    return ListTile(
                      title: Text(
                          ud.getFromCache(otherMember?.accountId)?.nick ??
                              channel.name),
                      subtitle: lastMessage != null
                          ? Text(
                              '${ud.getFromCache(lastMessage.sender.accountId)?.nick}: ${lastMessage.body['text'] ?? 'Unable preview'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              'channelDirectMessageDescription'.tr(args: [
                                '@${ud.getFromCache(otherMember?.accountId)?.name}',
                              ]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      leading: AccountImage(
                        content:
                            ud.getFromCache(otherMember?.accountId)?.avatar,
                      ),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          'chatRoom',
                          pathParameters: {
                            'scope': channel.realm?.alias ?? 'global',
                            'alias': channel.alias,
                          },
                        ).then((value) {
                          if (mounted) _refreshChannels();
                        });
                      },
                    );
                  }

                  return ListTile(
                    title: Text(channel.name),
                    subtitle: lastMessage != null
                        ? Text(
                            '${ud.getFromCache(lastMessage.sender.accountId)?.nick}: ${lastMessage.body['text'] ?? 'Unable preview'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            channel.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: AccountImage(
                      content: null,
                      fallbackWidget: const Icon(Symbols.chat, size: 20),
                    ),
                    onTap: () {
                      Navigator.pop(context, true);
                      GoRouter.of(context)
                          .pushNamed(
                        'chatRoom',
                        pathParameters: {
                          'scope': channel.realm?.alias ?? 'global',
                          'alias': channel.alias,
                        },
                        extra: ChatRoomScreenExtra(
                          initialText: widget.value
                              .where((e) => [
                                    SharedMediaType.text,
                                    SharedMediaType.url
                                  ].contains(e.type))
                              .map((e) => e.path)
                              .join('\n'),
                          initialAttachments: widget.value
                              .where((e) => [
                                    SharedMediaType.video,
                                    SharedMediaType.file,
                                    SharedMediaType.image
                                  ].contains(e.type))
                              .map(
                                  (e) => PostWriteMedia.fromFile(XFile(e.path)))
                              .toList(),
                        ),
                      )
                          .then((value) {
                        if (value == true) _refreshChannels();
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
