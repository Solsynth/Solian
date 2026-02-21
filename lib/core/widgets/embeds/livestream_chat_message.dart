import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/livestreams/livestream_room.dart';
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

double _awardAmount(ChatMessage msg) {
  final raw = msg.metadata?['amount'];
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? 0;
  return 0;
}

class _SuperchatPalette {
  final Color base;
  final Color accent;
  final Color progress;
  final Color nameColor;
  final Color amountColor;
  final Color messageBg;
  final Color messageText;

  const _SuperchatPalette({
    required this.base,
    required this.accent,
    required this.progress,
    required this.nameColor,
    required this.amountColor,
    required this.messageBg,
    required this.messageText,
  });
}

_SuperchatPalette _paletteForAmount(double amount) {
  if (amount >= 500) {
    return _SuperchatPalette(
      base: Colors.red.shade700,
      accent: Colors.red.shade400,
      progress: Colors.red.shade900,
      nameColor: Colors.white,
      amountColor: Colors.white,
      messageBg: Colors.red.shade500,
      messageText: Colors.white,
    );
  }
  if (amount >= 200) {
    return _SuperchatPalette(
      base: Colors.orange.shade700,
      accent: Colors.orange.shade400,
      progress: Colors.deepOrange.shade900,
      nameColor: Colors.black,
      amountColor: Colors.black,
      messageBg: Colors.orange.shade300,
      messageText: Colors.black,
    );
  }
  if (amount >= 100) {
    return _SuperchatPalette(
      base: Colors.amber.shade700,
      accent: Colors.amber.shade400,
      progress: Colors.amber.shade900,
      nameColor: Colors.black,
      amountColor: Colors.black,
      messageBg: Colors.amber.shade300,
      messageText: Colors.black,
    );
  }
  if (amount >= 50) {
    return _SuperchatPalette(
      base: Colors.green.shade700,
      accent: Colors.green.shade400,
      progress: Colors.green.shade900,
      nameColor: Colors.white,
      amountColor: Colors.white,
      messageBg: Colors.green.shade500,
      messageText: Colors.white,
    );
  }
  if (amount >= 20) {
    return _SuperchatPalette(
      base: Colors.blue.shade700,
      accent: Colors.blue.shade400,
      progress: Colors.blue.shade900,
      nameColor: Colors.white,
      amountColor: Colors.white,
      messageBg: Colors.blue.shade500,
      messageText: Colors.white,
    );
  }
  return _SuperchatPalette(
    base: Colors.teal.shade600,
    accent: Colors.teal.shade300,
    progress: Colors.teal.shade900,
    nameColor: Colors.black,
    amountColor: Colors.black,
    messageBg: Colors.teal.shade300,
    messageText: Colors.black,
  );
}

String _awardAmountText(ChatMessage msg) {
  final amount = _awardAmount(msg);
  if (amount == amount.roundToDouble()) {
    return amount.toStringAsFixed(0);
  }
  return amount.toStringAsFixed(1);
}

String _awardInitial(ChatMessage msg) {
  final sender = msg.sender.trim();
  if (sender.isEmpty) return '?';
  return sender[0].toUpperCase();
}

int _awardHighlightSeconds(ChatMessage msg) {
  final raw = msg.metadata?['highlight_seconds'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

double _awardRemainingProgress(ChatMessage msg, DateTime now) {
  final highlightSeconds = _awardHighlightSeconds(msg);
  final createdAt = msg.createdAt;
  if (highlightSeconds <= 0 || createdAt == null) return 0;
  final endAt = createdAt.add(Duration(seconds: highlightSeconds));
  final remainingMs = endAt.difference(now).inMilliseconds;
  if (remainingMs <= 0) return 0;
  return (remainingMs / (highlightSeconds * 1000)).clamp(0, 1);
}

Future<void> showSuperchatDetailSheet(
  BuildContext context,
  ChatMessage msg, {
  SnAccount? account,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      final messageText = msg.message.trim();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFFF1F9A).withOpacity(0.25),
                  child: ProfilePictureWidget(
                    file: account?.profile.picture,
                    radius: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (account != null)
                        AccountName(
                          account: account,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )
                      else
                        Text(
                          msg.sender,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      Text(
                        '${_awardAmountText(msg)} pts',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF08957C),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (messageText.isNotEmpty) ...[
              const Gap(16),
              Text(messageText, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ],
        ),
      );
    },
  );
}

class LivestreamSuperchatStickyChip extends HookConsumerWidget {
  final ChatMessage message;
  final EdgeInsetsGeometry margin;

  const LivestreamSuperchatStickyChip({
    super.key,
    required this.message,
    this.margin = const EdgeInsets.fromLTRB(8, 8, 8, 6),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderRef = message.senderId.isNotEmpty
        ? message.senderId
        : (message.senderIdentity ?? '');
    final accountAsync = senderRef.isEmpty
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(senderRef));
    final account = message.senderAccount ?? accountAsync.value;

    final now = useState(DateTime.now());
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        now.value = DateTime.now();
      });
      return timer.cancel;
    }, []);

    if (!isSuperchatActive(message, now: now.value)) {
      return const SizedBox.shrink();
    }

    final amountText = _awardAmountText(message);
    final palette = _paletteForAmount(_awardAmount(message));
    final progress = _awardRemainingProgress(message, now.value);
    return Padding(
      padding: margin,
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: () =>
                showSuperchatDetailSheet(context, message, account: account),
            child: Ink(
              decoration: BoxDecoration(
                color: palette.base,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(color: palette.progress),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.accent,
                        ),
                        child: account?.profile.picture != null
                            ? ClipOval(
                                child: ProfilePictureWidget(
                                  file: account?.profile.picture,
                                  radius: 15,
                                ),
                              )
                            : Center(
                                child: Text(
                                  _awardInitial(message),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 2,
                          right: 12,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Text(
                          '$amountText pts',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
      return _buildSystemAwardMessage(context, ref);
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

  Widget _buildSystemAwardMessage(BuildContext context, WidgetRef ref) {
    final awardMessage = msg;
    if (awardMessage == null) return const SizedBox.shrink();
    final messageText = awardMessage.message.trim();
    final amountText = _awardAmountText(awardMessage);
    final palette = _paletteForAmount(_awardAmount(awardMessage));
    final senderRef = awardMessage.senderId.isNotEmpty
        ? awardMessage.senderId
        : (awardMessage.senderIdentity ?? '');
    final accountAsync = senderRef.isEmpty
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(senderRef));
    final account = awardMessage.senderAccount ?? accountAsync.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              showSuperchatDetailSheet(context, awardMessage, account: account),
          child: Ink(
            decoration: BoxDecoration(
              color: palette.base,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(
                          0xFFFF1F9A,
                        ).withOpacity(0.25),
                        child: ProfilePictureWidget(
                          file: account?.profile.picture,
                          radius: 18,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (account != null)
                              AccountName(
                                account: account,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: palette.nameColor,
                                    ),
                              )
                            else
                              Text(
                                awardMessage.sender,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: palette.nameColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            Text(
                              '$amountText pts',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: palette.amountColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (messageText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: palette.messageBg,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      messageText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.messageText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
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
