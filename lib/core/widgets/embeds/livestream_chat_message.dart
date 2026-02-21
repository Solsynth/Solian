import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/widgets/embeds/livestream_room.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

SnAccount? _getSenderAccount(ChatMessage? msg) {
  if (msg?.senderAccount != null) {
    return msg!.senderAccount;
  }
  return null;
}

class LivestreamChatMessage extends ConsumerWidget {
  final ChatMessage? msg;
  final bool dark;
  final bool compact;

  // Individual parameters as alternative to msg
  final String? sender;
  final String? senderIdentity;
  final String? message;
  final bool? isMine;
  final DateTime? createdAt;

  const LivestreamChatMessage({
    super.key,
    this.msg,
    this.dark = false,
    this.compact = false,
    this.sender,
    this.senderIdentity,
    this.message,
    this.isMine,
    this.createdAt,
  }) : assert(
         msg != null || (sender != null && message != null),
         'Either msg or both sender and message must be provided',
       );

  String get _message => message ?? msg!.message;
  String get _sender => sender ?? msg!.sender;
  String? get _senderIdentity => senderIdentity ?? msg?.senderIdentity;
  bool get _isMine => isMine ?? msg?.isMine ?? false;
  DateTime get _createdAt => createdAt ?? msg?.createdAt ?? DateTime.now();
  ChatMessageType get _messageType => msg?.messageType ?? ChatMessageType.chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_messageType == ChatMessageType.systemAward) {
      return _buildSystemAwardMessage(context);
    }

    if (_messageType == ChatMessageType.systemJoin ||
        _messageType == ChatMessageType.systemLeave) {
      return _buildSystemParticipantMessage(context);
    }

    // Check if preloaded sender account is available
    final preloadedAccount = _getSenderAccount(msg);

    // Parse the senderIdentity to get the account ID (fallback)
    final accountId = _parseViewerIdentityToAccountId(_senderIdentity);
    final accountAsync = accountId == null
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(accountId));

    // Use preloaded account if available, otherwise fetch from provider
    final account = preloadedAccount ?? accountAsync.value;
    final displayName = account?.name ?? _sender;

    if (compact) {
      final timestamp =
          '${_createdAt.hour.toString().padLeft(2, '0')}:'
          '${_createdAt.minute.toString().padLeft(2, '0')}';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (account?.profile.picture != null)
              ProfilePictureWidget(file: account!.profile.picture, radius: 10)
            else
              CircleAvatar(
                radius: 10,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            const Gap(6),
            Flexible(
              flex: 0,
              child: account != null
                  ? AccountName(
                      account: account,
                      style:
                          (Theme.of(context).textTheme.labelSmall ??
                                  const TextStyle())
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                      hideOverlay: true,
                    )
                  : Text(
                      displayName,
                      style:
                          Theme.of(context).textTheme.labelSmall ??
                          const TextStyle(),
                    ),
            ),
            const Gap(8),
            Expanded(
              child: MarkdownTextContent(
                content: _message,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
                linesMargin: EdgeInsets.zero,
              ),
            ),
            const Gap(8),
            Text(
              timestamp,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (dark) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePictureWidget(
              file: account?.profile.picture,
              radius: 16,
            ).padding(right: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isMine
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: account != null
                              ? AccountName(
                                  account: account,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                )
                              : Text(
                                  displayName,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                ),
                        ),
                        const Gap(4),
                        Text(
                          _formatTime(_createdAt),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                    MarkdownTextContent(
                      content: _message,
                      linesMargin: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            if (!_isMine) const Spacer(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          AccountPfcRegion(
            uname: displayName,
            child: ProfilePictureWidget(
              radius: 16,
              file: account?.profile.picture,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isMine
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (account != null)
                    AccountName(
                      account: account,
                      style: const TextStyle(fontSize: 11),
                    ),
                  MarkdownTextContent(
                    content: _message,
                    linesMargin: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _parseViewerIdentityToAccountId(String? identity) {
    // Identity is now the username itself, return as-is
    return identity;
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _buildSystemAwardMessage(BuildContext context) {
    final metadata = msg?.metadata;
    final amount = metadata?['amount'] as double? ?? 0;
    final senderName = _sender;
    final messageText = _message;

    const color = Colors.amber;
    const icon = Icons.star;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(icon, color: color, size: 20),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'awardStreamAwarded'.tr(
                      args: [senderName, amount.toStringAsFixed(0)],
                    ),
                    style: const TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (messageText.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      messageText,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemParticipantMessage(BuildContext context) {
    final isJoin = _messageType == ChatMessageType.systemJoin;
    final color = isJoin
        ? Colors.green
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final icon = isJoin ? Icons.person_add : Icons.person_remove;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          const Gap(6),
          Text(
            _message,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
