import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/messages_notifier.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/message_list_tile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

// Class to represent the result when popping from search messages
class SearchMessagesResult {
  final String messageId;
  const SearchMessagesResult(this.messageId);
}

class SearchMessagesScreen extends HookConsumerWidget {
  final String roomId;

  const SearchMessagesScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final withLinks = useState(false);
    final withAttachments = useState(false);

    final messagesNotifier = ref.read(
      messagesNotifierProvider(roomId).notifier,
    );
    final messages = ref.watch(messagesNotifierProvider(roomId));

    useEffect(() {
      // Clear search when screen is disposed
      return () {
        messagesNotifier.clearSearch();
      };
    }, []);

    return AppScaffold(
      appBar: AppBar(title: const Text('searchMessages').tr()),
      body: Column(
        children: [
          Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'searchMessagesHint'.tr(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 16,
                  ),
                  suffix: IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      messagesNotifier.clearSearch();
                    },
                  ),
                ),
                onChanged: (query) {
                  messagesNotifier.searchMessages(
                    query,
                    withLinks: withLinks.value,
                    withAttachments: withAttachments.value,
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      secondary: const Icon(Symbols.link),
                      title: const Text('searchLinks').tr(),
                      value: withLinks.value,
                      onChanged: (bool? value) {
                        withLinks.value = value!;
                        messagesNotifier.searchMessages(
                          searchController.text,
                          withLinks: withLinks.value,
                          withAttachments: withAttachments.value,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      secondary: const Icon(Symbols.file_copy),
                      title: const Text('searchAttachments').tr(),
                      value: withAttachments.value,
                      onChanged: (bool? value) {
                        withAttachments.value = value!;
                        messagesNotifier.searchMessages(
                          searchController.text,
                          withLinks: withLinks.value,
                          withAttachments: withAttachments.value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: messages.when(
              data:
                  (messageList) =>
                      messageList.isEmpty
                          ? Center(child: Text('noMessagesFound'.tr()))
                          : SuperListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            reverse: false, // Show newest messages at the top
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              final message = messageList[index];
                              return MessageListTile(
                                message: message,
                                onJump: (messageId) {
                                  // Return the search result and pop back to room detail
                                  context.pop(SearchMessagesResult(messageId));
                                },
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Center(
                    child: Text('errorGeneric'.tr(args: [error.toString()])),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
