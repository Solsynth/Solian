import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PinnedMessagesSheet extends HookConsumerWidget {
  final String roomId;
  final void Function(String messageId)? onJumpToMessage;

  const PinnedMessagesSheet({
    super.key,
    required this.roomId,
    this.onJumpToMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(messagesProvider(roomId).notifier);
    final pins = useState<List<SnChatMessagePin>>([]);
    final messages = useState<Map<String, LocalChatMessage>>({});
    final isLoading = useState(true);
    final error = useState<String?>(null);

    useEffect(() {
      Future.microtask(() async {
        try {
          isLoading.value = true;
          final result = await notifier.fetchPinnedMessages();
          if (!context.mounted) return;
          pins.value = result;

          final map = <String, LocalChatMessage>{};
          for (final pin in result) {
            final msg = await notifier.fetchMessageById(pin.messageId);
            if (msg != null) map[pin.messageId] = msg;
          }
          if (context.mounted) {
            messages.value = map;
            isLoading.value = false;
          }
        } catch (e) {
          if (context.mounted) {
            error.value = e.toString();
            isLoading.value = false;
          }
        }
      });
      return null;
    }, []);

    return SheetScaffold(
      titleText: 'pinnedMessages'.tr(),
      child: isLoading.value
          ? Center(
              child: ConfuseSpinner(
                size: 34,
                speed: 6,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.65),
              ),
            )
          : error.value != null
              ? Center(child: Text(error.value!))
              : pins.value.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.push_pin,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'noPinnedMessages'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: pins.value.length,
                      itemBuilder: (context, index) {
                        final pin = pins.value[index];
                        final message = messages.value[pin.messageId];
                        return _PinnedMessageTile(
                          message: message,
                          onTap: onJumpToMessage != null
                              ? () {
                                  Navigator.pop(context);
                                  onJumpToMessage!(pin.messageId);
                                }
                              : null,
                          onUnpin: () async {
                            await notifier.unpinMessage(pin.messageId);
                            pins.value = pins.value
                                .where((p) => p.id != pin.id)
                                .toList();
                            final updated = Map.of(messages.value)
                              ..remove(pin.messageId);
                            messages.value = updated;
                          },
                        );
                      },
                    ),
    );
  }
}

class _PinnedMessageTile extends StatelessWidget {
  final LocalChatMessage? message;
  final VoidCallback? onTap;
  final VoidCallback? onUnpin;

  const _PinnedMessageTile({
    required this.message,
    this.onTap,
    this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    final sender = message?.sender;
    final content = message?.content ?? '';
    final createdAt = message?.createdAt;

    final timestamp = createdAt != null
        ? (DateTime.now().difference(createdAt).inDays > 365
            ? DateFormat('yyyy/MM/dd HH:mm').format(createdAt.toLocal())
            : DateTime.now().difference(createdAt).inDays > 0
                ? DateFormat('MM/dd HH:mm').format(createdAt.toLocal())
                : DateFormat('HH:mm').format(createdAt.toLocal()))
        : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sender != null)
              ProfilePictureWidget(
                file: sender.account.profile.picture,
                radius: 18,
              )
            else
              CircleAvatar(radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (sender != null)
                        Flexible(
                          child: AccountName(
                            account: sender.account,
                            textOverride: sender.nick?.isNotEmpty == true
                                ? sender.nick
                                : sender.account.nick,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            hideVerificationMark: true,
                            hideOverlay: true,
                          ),
                        ),
                      if (timestamp.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          timestamp,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (message == null)
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                    )
                  else if (content.isNotEmpty)
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else if (message!.attachments.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.attach_file,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'hasAttachments'.plural(message!.attachments.length),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.push_pin_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onUnpin,
              tooltip: 'unpinMessage'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
