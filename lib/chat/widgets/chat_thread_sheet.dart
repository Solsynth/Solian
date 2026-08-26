import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Bottom sheet showing the flattened thread replies of a message.
///
/// Fetches [ThreadReplyListResponse] from
/// `/messager/chat/{roomId}/messages/{messageId}/thread` and renders the
/// depth-first flattened reply list with indentation matching each node's
/// depth. Tapping a reply jumps to it in the main timeline via [onJump].
class ChatThreadSheet extends ConsumerStatefulWidget {
  final String roomId;
  final String messageId;
  final String rootContent;
  final String rootSenderName;
  final void Function(String messageId) onJump;

  const ChatThreadSheet({
    super.key,
    required this.roomId,
    required this.messageId,
    required this.rootContent,
    required this.rootSenderName,
    required this.onJump,
  });

  @override
  ConsumerState<ChatThreadSheet> createState() => _ChatThreadSheetState();
}

class _ChatThreadSheetState extends ConsumerState<ChatThreadSheet> {
  late Future<ThreadReplyListResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<ThreadReplyListResponse> _fetch() {
    final apiClient = ref.read(apiClientProvider);
    return apiClient
        .get<Map<String, dynamic>>(
          '/messager/chat/${widget.roomId}/messages/${widget.messageId}/thread',
        )
        .then(
          (response) => ThreadReplyListResponse.fromJson(response.data!),
        );
  }

  void _refresh() {
    setState(() {
      _future = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      heightFactor: 0.8,
      titleText: 'thread'.tr(),
      child: FutureBuilder<ThreadReplyListResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('threadLoadFailed'.tr()),
                  const Gap(8),
                  OutlinedButton(
                    onPressed: _refresh,
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final response = snapshot.data!;
          final replies = [...response.replies]
            ..sort((a, b) => a.message.createdAt.compareTo(b.message.createdAt));

          return Column(
            children: [
              _RootHeader(
                senderName: widget.rootSenderName,
                content: widget.rootContent,
              ),
              const Divider(height: 1),
              Expanded(
                child: replies.isEmpty
                    ? Center(
                        child: Text('threadNoReplies'.tr()).textColor(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final node = replies[index];
                          return ThreadReplyTile(
                            node: node,
                            onJump: widget.onJump,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RootHeader extends StatelessWidget {
  final String senderName;
  final String content;

  const _RootHeader({required this.senderName, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.forum,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(2),
                Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThreadReplyTile extends StatelessWidget {
  final ThreadReplyNode node;
  final void Function(String messageId) onJump;

  const ThreadReplyTile({
    super.key,
    required this.node,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final message = node.message;
    final indent = (node.depth * 16.0).clamp(0.0, 64.0);

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        dense: true,
        leading: ProfilePictureWidget(
          file: message.sender.account.profile.picture,
          fallbackName: message.sender.account.nick,
          radius: 16,
        ),
        title: Text(
          message.sender.account.nick,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          message.content ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          onJump(message.id);
        },
      ),
    );
  }
}

/// Tappable chip showing the thread reply count on a message bubble.
///
/// Shows the openable-thread affordance on the main message list. Only shown
/// when the server reports [SnChatMessage.threadRepliesCount] > 0 (or the
/// message is a thread root with replies). Tapping opens the thread panel
/// (right sidebar on wide screens, bottom sheet on narrow) via the same
/// "reply in thread" action as the message menu.
class ThreadRepliesChip extends HookConsumerWidget {
  final String roomId;
  final String messageId;
  final int replyCount;
  final String rootContent;
  final String rootSenderName;
  final void Function(String messageId) onJump;
  final VoidCallback? onOpenThread;
  final Color? color;

  const ThreadRepliesChip({
    super.key,
    required this.roomId,
    required this.messageId,
    required this.replyCount,
    required this.rootContent,
    required this.rootSenderName,
    required this.onJump,
    this.onOpenThread,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (replyCount <= 0) return const SizedBox.shrink();

    final chipColor =
        color ?? Theme.of(context).colorScheme.primaryContainer;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpenThread ?? () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.forum,
                    size: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const Gap(4),
                  Text(
                    'threadRepliesCount'.plural(replyCount),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
