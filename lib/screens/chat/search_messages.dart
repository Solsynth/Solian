import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/messages_notifier.dart';
import 'package:island/pods/chat/chat_rooms.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/message_list_tile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'dart:async';

// Class to represent the result when popping from search messages
class SearchMessagesResult {
  final String messageId;
  const SearchMessagesResult(this.messageId);
}

// Search states for better UX
enum SearchState { idle, searching, results, noResults, error }

class SearchMessagesScreen extends HookConsumerWidget {
  final String roomId;

  const SearchMessagesScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final withLinks = useState(false);
    final withAttachments = useState(false);
    final searchState = useState(SearchState.idle);
    final searchResultCount = useState<int?>(null);
    final searchResults = useState<AsyncValue<List<dynamic>>>(
      const AsyncValue.data([]),
    );

    // Debounce timer for search optimization
    final debounceTimer = useRef<Timer?>(null);

    final messagesNotifier = ref.read(
      messagesNotifierProvider(roomId).notifier,
    );

    // Optimized search function with debouncing
    void performSearch(String query) async {
      if (query.trim().isEmpty) {
        searchState.value = SearchState.idle;
        searchResultCount.value = null;
        searchResults.value = const AsyncValue.data([]);
        return;
      }

      searchState.value = SearchState.searching;
      searchResults.value = const AsyncValue.loading();

      // Cancel previous search if still active
      debounceTimer.value?.cancel();

      // Debounce search to avoid excessive API calls
      debounceTimer.value = Timer(const Duration(milliseconds: 300), () async {
        try {
          final results = await messagesNotifier.getSearchResults(
            query.trim(),
            withLinks: withLinks.value,
            withAttachments: withAttachments.value,
          );
          searchResults.value = AsyncValue.data(results);
          searchState.value =
              results.isEmpty ? SearchState.noResults : SearchState.results;
          searchResultCount.value = results.length;
        } catch (error, stackTrace) {
          searchResults.value = AsyncValue.error(error, stackTrace);
          searchState.value = SearchState.error;
        }
      });
    }

    // Search state is now managed locally in performSearch

    useEffect(() {
      // Clear search when screen is disposed
      return () {
        debounceTimer.value?.cancel();
        // Note: Don't access ref here as widget may be disposed
        // Flashing messages will be cleared by the next screen or jump operation
      };
    }, []);

    // Clear flashing messages when screen initializes (safer than in dispose)
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear flashing messages when entering search screen
        ref.read(flashingMessagesProvider.notifier).state = {};
      });
      return null;
    }, []);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('searchMessages').tr(),
        bottom:
            searchState.value == SearchState.searching
                ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(),
                )
                : null,
      ),
      body: Column(
        children: [
          // Search input section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'searchMessagesHint'.tr(),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 16,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              performSearch('');
                            },
                          ),
                        if (searchResultCount.value != null &&
                            searchState.value == SearchState.results)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${searchResultCount.value}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onChanged: performSearch,
                ),
                // Search filters
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          avatar: const Icon(Symbols.link, size: 16),
                          label: const Text('searchLinks').tr(),
                          selected: withLinks.value,
                          onSelected: (bool? value) {
                            withLinks.value = value!;
                            performSearch(searchController.text);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterChip(
                          avatar: const Icon(Symbols.file_copy, size: 16),
                          label: const Text('searchAttachments').tr(),
                          selected: withAttachments.value,
                          onSelected: (bool? value) {
                            withAttachments.value = value!;
                            performSearch(searchController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search results section
          Expanded(
            child: searchResults.value.when(
              data: (messageList) {
                switch (searchState.value) {
                  case SearchState.idle:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'searchMessagesHint'.tr(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    );

                  case SearchState.noResults:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'noMessagesFound'.tr(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'tryDifferentKeywords'.tr(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    );

                  case SearchState.results:
                    return SuperListView.builder(
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
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
              loading: () {
                if (searchState.value == SearchState.searching) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching...'),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, _) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'searchError'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => performSearch(searchController.text),
                        icon: const Icon(Icons.refresh),
                        label: const Text('retry').tr(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
