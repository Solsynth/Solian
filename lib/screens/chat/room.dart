import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/chat_message_controller.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/websocket.dart';
import 'package:surface/widgets/chat/chat_message.dart';
import 'package:surface/widgets/chat/chat_message_input.dart';
import 'package:surface/widgets/chat/chat_typing_indicator.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatRoomScreenExtra {
  final String? initialText;
  final List<PostWriteMedia>? initialAttachments;

  ChatRoomScreenExtra({this.initialText, this.initialAttachments});
}

class ChatRoomScreen extends StatefulWidget {
  final String scope;
  final String alias;
  final ChatRoomScreenExtra? extra;

  const ChatRoomScreen(
      {super.key, required this.scope, required this.alias, this.extra});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  bool _isBusy = false;
  bool _isJoining = false;

  SnChannel? _channel;
  SnChannelMember? _currentMember;
  SnChannelMember? _otherMember;

  final GlobalKey<ChatMessageInputState> _inputGlobalKey = GlobalKey();
  late final ChatMessageController _messageController;

  late final NotificationProvider _nty = context.read<NotificationProvider>();
  late final WebSocketProvider _ws = context.read<WebSocketProvider>();

  bool _isEncrypted = false;

  StreamSubscription? _wsSubscription;

  Future<void> _joinChannel() async {
    try {
      setState(() => _isJoining = true);
      final sn = context.read<SnNetworkProvider>();
      final ua = context.read<UserProvider>();
      await sn.client
          .post('/cgi/im/channels/${_channel!.keyPath}/members', data: {
        'related': ua.user?.name,
      });
      _initializeChat();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isJoining = true);
    }
  }

  Future<void> _fetchChannel() async {
    setState(() => _isBusy = true);

    try {
      final chan = context.read<ChatChannelProvider>();
      _channel = await chan.getChannel('${widget.scope}:${widget.alias}');

      if (!mounted || _channel == null) return;
      final ct = context.read<ChatChannelProvider>();
      try {
        _currentMember = await ct.getChannelProfile(_channel!);
      } catch (_) {}

      if (!mounted || _currentMember == null) return;
      final ud = context.read<UserDirectoryProvider>();
      final ua = context.read<UserProvider>();
      if (_channel!.type == 1) {
        await ud.listAccount(
          _channel!.members
                  ?.cast<SnChannelMember?>()
                  .map((ele) => ele?.accountId)
                  .where((ele) => ele != null && ele != ua.user?.id)
                  .toSet() ??
              {},
        );
        _otherMember = _channel!.members?.cast<SnChannelMember?>().firstWhere(
              (ele) => ele?.accountId != ua.user?.id,
              orElse: () => null,
            );
      }

      if (!mounted) return;
      _nty.skippableNotifyChannel = _channel!.id;
      final ws = context.read<WebSocketProvider>();
      if (_channel != null) {
        ws.conn?.sink.add(
          jsonEncode(WebSocketPackage(
              method: 'events.subscribe',
              endpoint: 'im',
              payload: {
                'channel_id': _channel!.id,
              })),
        );
      }
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _joinCall() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) {
      return await _joinCallWeb();
    }
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    final meet = JitsiMeet();
    final confOpts = JitsiMeetConferenceOptions(
      room: 'sn-chat-${_channel!.alias}-${_channel!.id}',
      serverURL:
          'https://meet.element.io', // TODO fetch this as config from remote
      configOverrides: {
        "subject": _channel!.name,
      },
      userInfo: JitsiMeetUserInfo(
        avatar: ua.user!.avatar.isNotEmpty
            ? sn.getAttachmentUrl(ua.user!.avatar)
            : null,
        displayName: _currentMember!.nick ?? ua.user!.nick,
      ),
    );
    meet.join(confOpts);
  }

  Future<void> _joinCallWeb() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    final url =
        '${sn.client.options.baseUrl}/meet/${_channel!.alias}-${_channel!.id}?tk=${await ua.atk}';
    launchUrlString(url);
  }

  bool _checkMessageMergeable(SnChatMessage? a, SnChatMessage? b) {
    if (a == null || b == null) return false;
    if (a.sender.accountId != b.sender.accountId) return false;
    return a.createdAt.difference(b.createdAt).inMinutes <= 3;
  }

  Future<void> _initializeChat() async {
    _fetchChannel().then((_) async {
      if (_currentMember == null) return;
      await _messageController.initialize(_channel!);

      if (widget.extra != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          log('[ChatInput] Setting initial text and attachments...');
          if (widget.extra!.initialText != null) {
            _inputGlobalKey.currentState
                ?.setInitialText(widget.extra!.initialText!);
          }
          if (widget.extra!.initialAttachments != null) {
            _inputGlobalKey.currentState
                ?.setInitialAttachments(widget.extra!.initialAttachments!);
          }
        });
      }

      await _messageController.checkUpdate();
    });
  }

  @override
  void initState() {
    super.initState();
    _messageController = ChatMessageController(context);
    _initializeChat();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _messageController.dispose();
    _nty.skippableNotifyChannel = null;
    if (_channel != null) {
      _ws.conn?.sink.add(
        jsonEncode(WebSocketPackage(
          method: 'events.unsubscribe',
          endpoint: 'im',
          payload: {
            'channel_id': _channel!.id,
          },
        )),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();

    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        title: Text(
          _channel?.type == 1
              ? ud.getFromCache(_otherMember?.accountId)?.nick ?? _channel!.name
              : _channel?.name ?? 'loading'.tr(),
        ),
        actions: [
          if (_currentMember != null)
            IconButton(
              onPressed: () {
                setState(() => _isEncrypted = !_isEncrypted);
                _inputGlobalKey.currentState?.setEncrypted(_isEncrypted);
              },
              icon: _isEncrypted
                  ? const Icon(Symbols.lock)
                  : const Icon(Symbols.no_encryption),
            ),
          if (_currentMember != null)
            IconButton(
              icon: const Icon(Symbols.video_call),
              onPressed: _joinCall,
              onLongPress: _joinCallWeb,
            ),
          IconButton(
            icon: const Icon(Symbols.more_vert),
            onPressed: () {
              GoRouter.of(context).pushNamed('channelDetail', pathParameters: {
                'scope': widget.scope,
                'alias': widget.alias,
              }).then((value) {
                if (value == false && context.mounted) {
                  Navigator.pop(context, true);
                } else if (value != null && context.mounted) {
                  _fetchChannel();
                }
              });
            },
          ),
          const Gap(8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _messageController,
        builder: (context, _) {
          return Column(
            children: [
              LoadingIndicator(
                isActive: _isBusy || _messageController.isAggressiveLoading,
              ),
              if (_currentMember == null && !_isBusy)
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Symbols.person_remove, size: 40, fill: 1),
                          const Gap(8),
                          Text('chatUnjoined'.tr(), textAlign: TextAlign.center)
                              .fontSize(16)
                              .bold(),
                          Text('chatUnjoinedDescription'.tr(),
                                  textAlign: TextAlign.center)
                              .fontSize(13),
                          if (_channel!.isPublic)
                            Text('chatUnjoinedPublicDescription'.tr(),
                                    textAlign: TextAlign.center)
                                .fontSize(13)
                                .padding(top: 8),
                          if (_channel!.isPublic)
                            TextButton(
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _isJoining ? null : _joinChannel,
                              child: Text('chatJoin').tr(),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_messageController.isPending)
                Expanded(
                  child: const CircularProgressIndicator().center(),
                )
              else
                Expanded(
                  child: InfiniteList(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 12),
                    hasReachedMax: _messageController.isAllLoaded,
                    itemCount: _messageController.messages.length,
                    isLoading: _messageController.isLoading,
                    onFetchData: () {
                      _messageController.loadMessages();
                    },
                    itemBuilder: (context, idx) {
                      final message = _messageController.messages[idx];
                      _messageController.readEvent(message.id);

                      bool canMerge = false, canMergePrevious = false;
                      if (idx > 0) {
                        canMergePrevious = _checkMessageMergeable(
                          _messageController.messages[idx - 1],
                          _messageController.messages[idx],
                        );
                      }
                      if (idx + 1 < _messageController.messages.length) {
                        canMerge = _checkMessageMergeable(
                          _messageController.messages[idx],
                          _messageController.messages[idx + 1],
                        );
                      }

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: ChatMessage(
                          data: message,
                          isMerged: canMerge,
                          hasMerged: canMergePrevious,
                          isPending: _messageController.unconfirmedMessages
                              .contains(message.uuid),
                          onReply: (value) {
                            _inputGlobalKey.currentState?.setReply(value);
                          },
                          onEdit: (value) {
                            _inputGlobalKey.currentState?.setEdit(value);
                          },
                          onDelete: (value) {
                            _inputGlobalKey.currentState?.deleteMessage(value);
                          },
                        ),
                      );
                    },
                  ),
                ),
              if (!_messageController.isPending && _currentMember != null)
                Material(
                  elevation: 2,
                  child: Column(
                    children: [
                      ChatTypingIndicator(controller: _messageController),
                      ChatMessageInput(
                        key: _inputGlobalKey,
                        otherMember: _otherMember,
                        controller: _messageController,
                      ),
                      Gap(MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
