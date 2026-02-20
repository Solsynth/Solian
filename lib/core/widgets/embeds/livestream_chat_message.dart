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
  final ChatMessage msg;
  final bool dark;

  const LivestreamChatMessage({
    super.key,
    required this.msg,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse the senderIdentity to get the account ID
    final accountId = _parseViewerIdentityToAccountId(msg.senderIdentity);
    final accountAsync = accountId == null
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(accountId));

    final displayName = accountAsync.value?.name ?? msg.sender;
    final account = accountAsync.value;

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
                  color: msg.isMine
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
                          _formatTime(msg.createdAt),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                    MarkdownTextContent(
                      content: msg.message,
                      linesMargin: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            if (!msg.isMine) const Spacer(),
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
                color: msg.isMine
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
                    content: msg.message,
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
    if (identity == null || !identity.startsWith('viewer_')) return null;
    final raw = identity.substring('viewer_'.length).toLowerCase();
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
