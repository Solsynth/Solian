import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/chat_message_controller.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/chat_call.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/websocket.dart';
import 'package:surface/widgets/chat/call/call_prejoin.dart';
import 'package:surface/widgets/chat/chat_message.dart';
import 'package:surface/widgets/chat/chat_message_input.dart';
import 'package:surface/widgets/chat/chat_typing_indicator.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
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
  bool _isCalling = false;
  bool _isJoining = false;

  SnChannel? _channel;
  SnChannelMember? _currentMember;
  SnChannelMember? _otherMember;
  SnChatCall? _ongoingCall;

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

  Future<void> _fetchOngoingCall() async {
    setState(() => _isCalling = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/im/channels/${_messageController.channel!.keyPath}/calls/ongoing',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      if (resp.statusCode == 200) {
        _ongoingCall = SnChatCall.fromJson(resp.data);
      }
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isCalling = false);
    }
  }

  Future<void> _makeCall() async {
    setState(() => _isCalling = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/im/channels/${_messageController.channel!.keyPath}/calls',
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      if (_ongoingCall == null) {
        // ignore the error because the call is already ongoing
        context.showErrorDialog(err);
      }
    } finally {
      setState(() => _isCalling = false);
    }
  }

  Future<void> _endCall() async {
    setState(() => _isCalling = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete(
        '/cgi/im/channels/${_messageController.channel!.keyPath}/calls/ongoing',
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isCalling = false);
    }
  }

  Future<void> _onCallJoin() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => ChatCallPrejoinPopup(
        ongoingCall: _ongoingCall!,
        channel: _channel!,
        onJoin: _onCallResume,
      ),
    );
  }

  void _onCallResume() {
    GoRouter.of(context).pushNamed(
      'chatCallRoom',
      pathParameters: {
        'scope': _channel!.realm?.alias ?? 'global',
        'alias': _channel!.alias,
      },
    );
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

      await Future.wait([
        _messageController.checkUpdate(),
        _fetchOngoingCall(),
      ]);
    });
  }

  @override
  void initState() {
    super.initState();
    _messageController = ChatMessageController(context);
    _initializeChat();

    _wsSubscription = _ws.pk.stream.listen((event) {
      switch (event.method) {
        case 'calls.new':
          final payload = SnChatCall.fromJson(event.payload!);
          if (payload.channelId == _channel?.id) {
            setState(() => _ongoingCall = payload);
          }
          break;
        case 'calls.end':
          final payload = SnChatCall.fromJson(event.payload!);
          if (payload.channelId == _channel?.id) {
            setState(() => _ongoingCall = null);
          }
          break;
      }
    });
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
    final call = context.watch<ChatCallProvider>();
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
              icon: _ongoingCall == null
                  ? const Icon(Symbols.call)
                  : const Icon(Symbols.call_end),
              onPressed: _isCalling
                  ? null
                  : _ongoingCall == null
                      ? _makeCall
                      : _endCall,
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
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: MaterialBanner(
                  dividerColor: Colors.transparent,
                  leading: const Icon(Symbols.call_received),
                  content: Text('callOngoingNotice').tr().padding(top: 2),
                  actions: [
                    if (call.current == null)
                      TextButton(
                        onPressed: _onCallJoin,
                        child: Text('callJoin').tr(),
                      )
                    else if (call.current?.channelId == _channel?.id)
                      TextButton(
                        onPressed: _onCallResume,
                        child: Text('callResume').tr(),
                      )
                  ],
                ),
              ).height(_ongoingCall != null ? 54 : 0, animate: true).animate(
                  const Duration(milliseconds: 300),
                  Curves.fastLinearToSlowEaseIn),
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
