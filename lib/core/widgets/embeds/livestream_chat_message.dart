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
  }) : assert(msg != null || (sender != null && message != null),
            'Either msg or both sender and message must be provided');

  String get _message => message ?? msg!.message;
  String get _sender => sender ?? msg!.sender;
  String? get _senderIdentity => senderIdentity ?? msg?.senderIdentity;
  bool get _isMine => isMine ?? msg?.isMine ?? false;
  DateTime get _createdAt => createdAt ?? msg!.createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse the senderIdentity to get the account ID
    final accountId = _parseViewerIdentityToAccountId(_senderIdentity);
    final accountAsync = accountId == null
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(accountId));

    final displayName = accountAsync.value?.name ?? _sender;
    final account = accountAsync.value;

    if (compact) {
      final timestamp =
          '${_createdAt.hour.toString().padLeft(2, '0')}:'
          '${_createdAt.minute.toString().padLeft(2, '0')}';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (account?.profile.picture != null)
              ProfilePictureWidget(
                file: account!.profile.picture,
                radius: 10,
              )
            else
              CircleAvatar(
                radius: 10,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            const Gap(6),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 0,
                    child: account != null
                        ? AccountName(
                            account: account,
                            style:
                                (Theme.of(context).textTheme.labelSmall ??
                                        const TextStyle())
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                            hideOverlay: true,
                          )
                        : Text(
                            displayName,
                            style: Theme.of(context).textTheme.labelSmall ??
                                const TextStyle(),
                          ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: MarkdownTextContent(
                      content: _message,
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
    if (identity == null) return null;
    // Handle both 'viewer_' and 'streamer_' prefixes
    String? prefix;
    if (identity.startsWith('viewer_')) {
      prefix = 'viewer_';
    } else if (identity.startsWith('streamer_')) {
      prefix = 'streamer_';
    }
    
    if (prefix == null) return null;
    final raw = identity.substring(prefix.length).toLowerCase();
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(raw)) return null;
    return '${raw.substring(0, 8)}-'
        '${raw.substring(8, 12)}-'
        '${raw.substring(12, 16)}-'
        '${raw.substring(16, 20)}-'
        '${raw.substring(20, 32)}';
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
