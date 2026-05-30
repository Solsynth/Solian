import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/messages_notifier.dart';
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
    final isLoading = useState(true);
    final error = useState<String?>(null);

    useEffect(() {
      Future.microtask(() async {
        try {
          isLoading.value = true;
          final result = await notifier.fetchPinnedMessages();
          if (context.mounted) {
            pins.value = result;
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
              ? Center(
                  child: Text(error.value!),
                )
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
                        return _PinnedMessageTile(
                          pin: pin,
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
                          },
                        );
                      },
                    ),
    );
  }
}

class _PinnedMessageTile extends StatelessWidget {
  final SnChatMessagePin pin;
  final VoidCallback? onTap;
  final VoidCallback? onUnpin;

  const _PinnedMessageTile({
    required this.pin,
    this.onTap,
    this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    final message = pin.message;
    final sender = message?.sender;
    final senderName = sender?.nick?.isNotEmpty == true
        ? sender!.nick!
        : sender?.account.nick ?? 'Unknown';
    final content = message?.content ?? '';
    final createdAt = message?.createdAt;

    return ListTile(
      leading: Icon(
        Symbols.push_pin,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        senderName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (content.isNotEmpty)
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (createdAt != null)
            Text(
              DateFormat.yMMMd().add_jm().format(createdAt.toLocal()),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.6),
                  ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.push_pin_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.error,
        ),
        onPressed: onUnpin,
        tooltip: 'unpinMessage'.tr(),
      ),
      onTap: onTap,
    );
  }
}
