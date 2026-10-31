import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/e2ee_message_display.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/utils/message_search.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:island/chat/widgets/message_content.dart';
import 'package:island/chat/widgets/message_sender_info.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/mapping.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/core/widgets/embeds/link.dart';
import 'package:island/data/message.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/discovery/search_navigation.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// Width the results keep on a wide window: the list reads as one column of
/// matches, so the bands and rows stop widening once the line length would.
const kChatSearchLedgerWidth = 860.0;

class SearchMessagesResult {
  final String messageId;
  const SearchMessagesResult(this.messageId);
}

// Search states for better UX
enum SearchState { idle, searching, results, noResults, error }

// ---------------------------------------------------------------------------
// Cloud search (matches DysonNetwork CHAT_MESSAGE_SEARCH.md)
// ---------------------------------------------------------------------------

/// One page of cloud search results, already grouped by room.
class _CloudSearchPage {
  final List<_SearchRoomGroup> groups;
  final int total;

  const _CloudSearchPage({required this.groups, required this.total});

  List<LocalChatMessage> get messages => [
    for (final group in groups) ...group.messages,
  ];
}

/// Calls `GET /messager/chat/messages/search`.
///
/// Server returns room groups ordered by newest match, messages newest-first.
/// Total matching count (pre-pagination) is in the `X-Total` header.
Future<_CloudSearchPage> _searchMessagesCloud(
  Dio client, {
  required String query,
  List<String>? roomIds,
  String? sender,
  DateTime? after,
  DateTime? before,
  int offset = 0,
  int take = 20,
}) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('query is required for cloud search');
  }

  final queryParameters = <String, dynamic>{
    'query': trimmed,
    'offset': offset,
    'take': take.clamp(1, 100),
  };

  if (roomIds != null && roomIds.isNotEmpty) {
    queryParameters['room_ids'] = roomIds;
  }
  final senderTrimmed = sender?.trim();
  if (senderTrimmed != null && senderTrimmed.isNotEmpty) {
    queryParameters['sender'] = senderTrimmed;
  }
  if (after != null) {
    queryParameters['after'] = after.toUtc().toIso8601String();
  }
  if (before != null) {
    queryParameters['before'] = before.toUtc().toIso8601String();
  }

  final response = await client.get<List<dynamic>>(
    '/messager/chat/messages/search',
    queryParameters: queryParameters,
    options: Options(listFormat: ListFormat.multi),
  );

  final total =
      int.tryParse(response.headers.value('X-Total') ?? '') ??
      _countMessagesInSearchPayload(response.data);
  final groups = _parseCloudSearchGroups(response.data);
  return _CloudSearchPage(groups: groups, total: total);
}

int _countMessagesInSearchPayload(List<dynamic>? data) {
  if (data == null) return 0;
  var count = 0;
  for (final group in data.whereType<Map>()) {
    final entries = group['messages'];
    if (entries is List) count += entries.length;
  }
  return count;
}

List<_SearchRoomGroup> _parseCloudSearchGroups(List<dynamic>? data) {
  if (data == null) return const [];
  final groups = <_SearchRoomGroup>[];

  for (final raw in data.whereType<Map>()) {
    final group = Map<String, dynamic>.from(raw);
    SnChatRoom? room;
    final roomRaw = group['room'];
    if (roomRaw is Map) {
      try {
        room = SnChatRoom.fromJson(Map<String, dynamic>.from(roomRaw));
      } catch (_) {
        // Keep going; messages may still be usable without room metadata.
      }
    }

    final entries = group['messages'];
    if (entries is! List) continue;

    final messages = <LocalChatMessage>[];
    for (final entry in entries.whereType<Map>()) {
      try {
        final message = SnChatMessage.fromJson(
          Map<String, dynamic>.from(entry),
        );
        messages.add(
          LocalChatMessage.fromRemoteMessage(message, MessageStatus.sent),
        );
      } catch (_) {
        // A malformed result should not discard other valid search results.
      }
    }
    if (messages.isEmpty) continue;

    final roomId = room?.id ?? messages.first.roomId;
    groups.add(
      _SearchRoomGroup(roomId: roomId, room: room, messages: messages),
    );
  }

  return groups;
}

// ---------------------------------------------------------------------------
// Shared filter / status UI
// ---------------------------------------------------------------------------

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData? stateIcon;
  final bool emphasized;
  final int? badge;
  final VoidCallback? onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    this.stateIcon,
    required this.emphasized,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final enabled = onTap != null;
    // Outlined when idle, filled when on: the ribbon stays quiet until a
    // filter actually narrows the search.
    final selected = emphasized && enabled;
    final foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final outline = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? Colors.transparent : colorScheme.outlineVariant,
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        shape: outline,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const Gap(6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (badge != null && badge! > 0) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badge',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10.5,
                        height: 1.2,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
                if (stateIcon != null) ...[
                  const Gap(4),
                  Icon(stateIcon, size: 14, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single filter bar: cloud toggle, local-only chips (links/attachments),
/// and advanced filters (account sender via [AccountPickerSheet] / date range).
///
/// Links & attachments are local-cache only — the cloud index is plaintext
/// `text` messages and does not support those filters.
class _ChatSearchFilterBar extends HookWidget {
  final bool cloudSearch;
  final ValueChanged<bool> onCloudSearchChanged;
  final bool withLinks;
  final bool withAttachments;
  final ValueChanged<bool> onLinksChanged;
  final ValueChanged<bool> onAttachmentsChanged;
  final SnAccount? sender;
  final ValueChanged<SnAccount?> onSenderChanged;
  final DateTime? after;
  final DateTime? before;
  final ValueChanged<DateTime?> onAfterChanged;
  final ValueChanged<DateTime?> onBeforeChanged;
  final VoidCallback onFiltersChanged;

  const _ChatSearchFilterBar({
    required this.cloudSearch,
    required this.onCloudSearchChanged,
    required this.withLinks,
    required this.withAttachments,
    required this.onLinksChanged,
    required this.onAttachmentsChanged,
    required this.sender,
    required this.onSenderChanged,
    required this.after,
    required this.before,
    required this.onAfterChanged,
    required this.onBeforeChanged,
    required this.onFiltersChanged,
  });

  int get _activeCount =>
      (withLinks ? 1 : 0) +
      (withAttachments ? 1 : 0) +
      (sender != null ? 1 : 0) +
      (after != null ? 1 : 0) +
      (before != null ? 1 : 0);

  int get _advancedCount =>
      (sender != null ? 1 : 0) +
      (after != null ? 1 : 0) +
      (before != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Local-only filters are unavailable while cloud search is active.
    final localFiltersEnabled = !cloudSearch;
    final showAdvanced = useState(_advancedCount > 0);

    Future<void> pickDate({required bool isStart}) async {
      final current = isStart ? after : before;
      final picked = await showDatePicker(
        context: context,
        initialDate: current ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 1)),
      );
      if (picked == null) return;
      final normalized = isStart
          ? DateTime(picked.year, picked.month, picked.day)
          : DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      if (isStart) {
        onAfterChanged(normalized);
      } else {
        onBeforeChanged(normalized);
      }
      onFiltersChanged();
    }

    Future<void> pickSender() async {
      final result = await showModalBottomSheet<SnAccount>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      onSenderChanged(result);
      onFiltersChanged();
    }

    void clearAll() {
      if (withLinks) onLinksChanged(false);
      if (withAttachments) onAttachmentsChanged(false);
      if (sender != null) onSenderChanged(null);
      if (after != null) onAfterChanged(null);
      if (before != null) onBeforeChanged(null);
      onFiltersChanged();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FilterChipButton(
              icon: cloudSearch ? Symbols.cloud : Symbols.cloud_off,
              label: cloudSearch
                  ? 'chatSearchCloud'.tr()
                  : 'chatSearchLocal'.tr(),
              stateIcon: cloudSearch
                  ? Symbols.check_circle
                  : Symbols.radio_button_unchecked,
              emphasized: cloudSearch,
              onTap: () {
                final next = !cloudSearch;
                onCloudSearchChanged(next);
                // Cloud index has no links/attachments filters.
                if (next) {
                  if (withLinks) onLinksChanged(false);
                  if (withAttachments) onAttachmentsChanged(false);
                }
                onFiltersChanged();
              },
            ),
            _FilterChipButton(
              icon: Symbols.link,
              label: 'searchLinks'.tr(),
              stateIcon: withLinks
                  ? Symbols.check_circle
                  : Symbols.radio_button_unchecked,
              emphasized: withLinks && localFiltersEnabled,
              onTap: localFiltersEnabled
                  ? () {
                      onLinksChanged(!withLinks);
                      onFiltersChanged();
                    }
                  : null,
            ),
            _FilterChipButton(
              icon: Symbols.file_copy,
              label: 'searchAttachments'.tr(),
              stateIcon: withAttachments
                  ? Symbols.check_circle
                  : Symbols.radio_button_unchecked,
              emphasized: withAttachments && localFiltersEnabled,
              onTap: localFiltersEnabled
                  ? () {
                      onAttachmentsChanged(!withAttachments);
                      onFiltersChanged();
                    }
                  : null,
            ),
            _FilterChipButton(
              icon: Symbols.tune,
              label: 'advancedFilters'.tr(),
              badge: _advancedCount,
              stateIcon: showAdvanced.value
                  ? Symbols.expand_less
                  : Symbols.expand_more,
              emphasized: showAdvanced.value,
              onTap: () => showAdvanced.value = !showAdvanced.value,
            ),
            if (_activeCount > 0)
              _FilterChipButton(
                icon: Symbols.restart_alt,
                label: 'clear'.tr(),
                emphasized: false,
                onTap: clearAll,
              ),
          ],
        ),
        const Gap(8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SenderAccountField(
                    account: sender,
                    onPick: pickSender,
                    onClear: sender == null
                        ? null
                        : () {
                            onSenderChanged(null);
                            onFiltersChanged();
                          },
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateFieldButton(
                          label: 'fromDate'.tr(),
                          value: after,
                          enabled: true,
                          onTap: () => pickDate(isStart: true),
                          onClear: after == null
                              ? null
                              : () {
                                  onAfterChanged(null);
                                  onFiltersChanged();
                                },
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _DateFieldButton(
                          label: 'toDate'.tr(),
                          value: before,
                          enabled: true,
                          onTap: () => pickDate(isStart: false),
                          onClear: before == null
                              ? null
                              : () {
                                  onBeforeChanged(null);
                                  onFiltersChanged();
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: showAdvanced.value
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}

/// Opens [AccountPickerSheet] to choose a sender account.
class _SenderAccountField extends StatelessWidget {
  final SnAccount? account;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _SenderAccountField({
    required this.account,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = account != null;

    return Material(
      color: selected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              if (selected)
                ProfilePictureWidget(
                  file: account!.profile.picture,
                  fallbackName: account!.nick,
                  radius: 16,
                )
              else
                Icon(
                  Symbols.person_search,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              const Gap(10),
              Expanded(
                child: selected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account!.nick,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${account!.name}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer
                                  .withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Text(
                        'searchAccounts'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: onClear,
                )
              else
                Icon(
                  Symbols.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFieldButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateFieldButton({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatted = value != null
        ? DateFormat('yyyy-MM-dd').format(value!)
        : 'selectDate'.tr();

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      formatted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: value != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: enabled ? onClear : null,
                )
              else
                Icon(
                  Symbols.calendar_today,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _messageHasLink(LocalChatMessage message) =>
    RegExp(r'https?://', caseSensitive: false).hasMatch(message.content ?? '');

/// Query string for cloud `sender` param (matches name or nickname on server).
String? _senderQuery(SnAccount? account) {
  if (account == null) return null;
  // Prefer handle/name for a stable match; fall back to nick.
  final name = account.name.trim();
  if (name.isNotEmpty) return name;
  final nick = account.nick.trim();
  return nick.isEmpty ? null : nick;
}

bool _messageMatchesSender(LocalChatMessage message, SnAccount? account) {
  if (account == null) return true;
  if (message.senderId == account.id) return true;
  final nick = message.sender?.account.nick.toLowerCase() ?? '';
  final name = message.sender?.account.name.toLowerCase() ?? '';
  final qNick = account.nick.toLowerCase();
  final qName = account.name.toLowerCase();
  return nick == qNick ||
      name == qName ||
      nick.contains(qNick) ||
      name.contains(qName);
}

/// Show filters only while the results list is scrolled to the top.
bool _updateFilterVisibilityFromScroll(
  ScrollNotification notification,
  ValueNotifier<bool> isFilterVisible,
) {
  if (notification.depth != 0) return false;
  // Ignore pure scroll-start noise; react to position changes/end.
  if (notification is! ScrollUpdateNotification &&
      notification is! ScrollEndNotification &&
      notification is! OverscrollNotification) {
    return false;
  }
  final atTop = notification.metrics.pixels <= 0;
  if (isFilterVisible.value != atTop) {
    isFilterVisible.value = atTop;
  }
  return false;
}

// ---------------------------------------------------------------------------
// Single-room search
// ---------------------------------------------------------------------------

@RoutePage()
class SearchMessagesScreen extends HookConsumerWidget {
  final String roomId;

  const SearchMessagesScreen({
    super.key,
    @PathParam("id") required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    useListenable(searchController);

    final withLinks = useState(false);
    final withAttachments = useState(false);
    final cloudSearch = useState(true);
    final sender = useState<SnAccount?>(null);
    final after = useState<DateTime?>(null);
    final before = useState<DateTime?>(null);
    final isFilterVisible = useState(true);
    final searchState = useState(SearchState.idle);
    final searchResultCount = useState<int?>(null);
    final searchResults = useState<AsyncValue<List<LocalChatMessage>>>(
      const AsyncValue.data([]),
    );

    final debounceTimer = useRef<Timer?>(null);
    final messagesNotifier = ref.read(messagesProvider(roomId).notifier);
    final client = ref.read(apiClientProvider);
    final database = ref.read(databaseProvider);

    Future<void> performSearch(String query) async {
      final trimmedQuery = query.trim();
      final hasLocalFilters = withLinks.value || withAttachments.value;
      final hasCloudFilters =
          sender.value != null || after.value != null || before.value != null;

      if (trimmedQuery.isEmpty && !hasLocalFilters && !hasCloudFilters) {
        searchState.value = SearchState.idle;
        searchResultCount.value = null;
        searchResults.value = const AsyncValue.data([]);
        return;
      }

      searchState.value = SearchState.searching;
      searchResults.value = const AsyncValue.loading();
      debounceTimer.value?.cancel();

      debounceTimer.value = Timer(const Duration(milliseconds: 300), () async {
        try {
          List<LocalChatMessage> messages = [];

          // Cloud path: server indexes plaintext text messages only.
          // Requires a non-empty query per CHAT_MESSAGE_SEARCH.md.
          final useCloud =
              cloudSearch.value &&
              trimmedQuery.isNotEmpty &&
              !withAttachments.value;

          if (useCloud) {
            try {
              final page = await _searchMessagesCloud(
                client,
                query: trimmedQuery,
                roomIds: [roomId],
                sender: _senderQuery(sender.value),
                after: after.value,
                before: before.value,
                take: 100,
              );
              messages = page.messages;
              if (messages.isNotEmpty) {
                await database.saveMessagesWithSenders(messages);
              }
              if (withLinks.value) {
                messages = messages.where(_messageHasLink).toList();
                // X-Total is pre-filter; prefer filtered length when narrowing.
              }
            } on DioException {
              // Fall through to local cache.
            }
          }

          // Local path: always available for filters / offline / cloud miss.
          if (messages.isEmpty || !useCloud || hasLocalFilters) {
            final local = await messagesNotifier.getSearchResults(
              trimmedQuery,
              withLinks: withLinks.value,
              withAttachments: withAttachments.value,
            );
            if (!useCloud || messages.isEmpty) {
              messages = local;
            } else if (hasLocalFilters) {
              // Prefer cloud hits that also satisfy local filters; fill gaps.
              final cloudIds = messages.map((m) => m.id).toSet();
              final extra = local.where((m) => !cloudIds.contains(m.id));
              messages = [...messages, ...extra];
            }
          }

          // Apply sender/date client-side when on local-only path.
          if (!useCloud) {
            if (sender.value != null) {
              messages = messages
                  .where((m) => _messageMatchesSender(m, sender.value))
                  .toList();
            }
            if (after.value != null) {
              messages = messages
                  .where((m) => !m.createdAt.isBefore(after.value!.toUtc()))
                  .toList();
            }
            if (before.value != null) {
              messages = messages
                  .where((m) => m.createdAt.isBefore(before.value!.toUtc()))
                  .toList();
            }
          }

          searchResults.value = AsyncValue.data(messages);
          searchState.value = messages.isEmpty
              ? SearchState.noResults
              : SearchState.results;
        } catch (error, stackTrace) {
          searchResults.value = AsyncValue.error(error, stackTrace);
          searchState.value = SearchState.error;
        }
      });
    }

    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(flashingMessagesProvider.notifier).clear();
      });
      return null;
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) focusNode.requestFocus();
      });
      return null;
    }, []);
    final hasQuery = searchController.text.isNotEmpty;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('searchMessages').tr(),
        actions: [
          IconButton(
            onPressed: () => isFilterVisible.value = !isFilterVisible.value,
            icon: Icon(
              isFilterVisible.value
                  ? Symbols.filter_list_off
                  : Symbols.filter_list,
            ),
            tooltip: isFilterVisible.value
                ? 'hideFilters'.tr()
                : 'showFilters'.tr(),
          ),
          IconButton(
            icon: const Icon(Symbols.travel_explore),
            tooltip: 'searchMessages'.tr(),
            onPressed: () =>
                openUniversalSearch(context, tab: SearchTab.messages),
          ),
          const Gap(8),
        ],
        bottom: searchState.value == SearchState.searching
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  controller: searchController,
                  focusNode: focusNode,
                  hintText: 'searchMessagesHint'.tr(),
                  leading: const Icon(Symbols.search),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  trailing: [
                    if (hasQuery)
                      IconButton(
                        icon: const Icon(Symbols.close),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'clear'.tr(),
                        onPressed: () {
                          searchController.clear();
                          performSearch('');
                          focusNode.requestFocus();
                        },
                      ),
                  ],
                  onChanged: performSearch,
                  onSubmitted: (value) {
                    performSearch(value);
                    focusNode.unfocus();
                  },
                ),
              ),
              _CollapsibleFilterHeader(
                visible: isFilterVisible.value,
                child: _ChatSearchFilterBar(
                  cloudSearch: cloudSearch.value,
                  onCloudSearchChanged: (value) => cloudSearch.value = value,
                  withLinks: withLinks.value,
                  withAttachments: withAttachments.value,
                  onLinksChanged: (value) => withLinks.value = value,
                  onAttachmentsChanged: (value) =>
                      withAttachments.value = value,
                  sender: sender.value,
                  onSenderChanged: (value) => sender.value = value,
                  after: after.value,
                  before: before.value,
                  onAfterChanged: (value) => after.value = value,
                  onBeforeChanged: (value) => before.value = value,
                  onFiltersChanged: () => performSearch(searchController.text),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) =>
                      _updateFilterVisibilityFromScroll(
                        notification,
                        isFilterVisible,
                      ),
                  child: searchResults.value.when(
                    data: (messageList) {
                      switch (searchState.value) {
                        case SearchState.idle:
                          return EmptyState(
                            key: const Key('chatSearchIdle'),
                            icon: Symbols.search,
                            title: 'searchMessages'.tr(),
                            description: 'chatSearchIdleBody'.tr(),
                          );

                        case SearchState.noResults:
                          return EmptyState(
                            key: const Key('chatSearchNoResults'),
                            icon: Symbols.search_off,
                            title: 'noMessagesFound'.tr(),
                            description: 'chatSearchNoResultsBody'.tr(),
                          );

                        case SearchState.results:
                          return SuperListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            reverse: false,
                            itemCount: messageList.length,
                            itemBuilder: (context, index) =>
                                _ChatSearchMatchTile(
                                  message: messageList[index],
                                  query: searchController.text,
                                  onJump: (messageId) {
                                    context.pop(
                                      SearchMessagesResult(messageId),
                                    );
                                  },
                                ),
                          );

                        default:
                          return const SizedBox.shrink();
                      }
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const Gap(16),
                          Text('searching'.tr()),
                        ],
                      ),
                    ),
                    error: (error, _) => EmptyState(
                      icon: Symbols.error_outline,
                      iconColor: Theme.of(context).colorScheme.error,
                      title: 'searchError'.tr(),
                      action: FilledButton.tonalIcon(
                        onPressed: () => performSearch(searchController.text),
                        icon: const Icon(Symbols.refresh),
                        label: const Text('retry').tr(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cross-room search
// ---------------------------------------------------------------------------

/// Cross-room chat message search, embedded in the universal search page.
///
/// Local-first when offline / filtering attachments; cloud for text index.
/// [searchQuery] is the debounced text owned by the host page's search field.
class ChatMessageSearchView extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  /// Filter panel visibility, owned by the host page's app bar action so all
  /// sections share a single trigger.
  final ValueNotifier<bool> filtersVisible;

  const ChatMessageSearchView({
    super.key,
    required this.searchQuery,
    required this.filtersVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useValueListenable(searchQuery);
    final filterVisible = useValueListenable(filtersVisible);
    final withLinks = useState(false);
    final withAttachments = useState(false);
    final cloudSearch = useState(true);
    final sender = useState<SnAccount?>(null);
    final after = useState<DateTime?>(null);
    final before = useState<DateTime?>(null);
    final groups = useState<List<_SearchRoomGroup>>([]);
    final isSearching = useState(false);
    final hasSearched = useState(false);
    final error = useState<Object?>(null);
    final request = useRef(0);
    final database = ref.read(databaseProvider);
    final client = ref.read(apiClientProvider);

    Future<void> search(String rawQuery) async {
      final query = rawQuery.trim();
      final hasLocalFilters = withLinks.value || withAttachments.value;
      final hasCloudFilters =
          sender.value != null || after.value != null || before.value != null;

      if (query.isEmpty && !hasLocalFilters && !hasCloudFilters) {
        groups.value = [];
        hasSearched.value = false;
        error.value = null;
        return;
      }

      final currentRequest = ++request.value;
      isSearching.value = true;
      hasSearched.value = true;
      error.value = null;

      try {
        List<_SearchRoomGroup> nextGroups = [];

        final useCloud =
            cloudSearch.value && query.isNotEmpty && !withAttachments.value;

        if (useCloud) {
          try {
            final page = await _searchMessagesCloud(
              client,
              query: query,
              sender: _senderQuery(sender.value),
              after: after.value,
              before: before.value,
              take: 100,
            );
            nextGroups = page.groups;

            final flat = page.messages;
            if (flat.isNotEmpty) {
              await database.saveMessagesWithSenders(flat);
            }
          } on DioException catch (exception) {
            // Fall back to local cache when cloud fails.
            if (currentRequest != request.value) return;
            // Keep trying local; only surface error if local is also empty.
            error.value = exception;
          }
        }

        if (nextGroups.isEmpty || !useCloud) {
          var local = await database.searchMessagesAcrossRooms(
            query,
            withAttachments: withAttachments.value,
          );
          if (withLinks.value) {
            local = local.where(_messageHasLink).toList();
          }

          if (sender.value != null) {
            local = local
                .where((m) => _messageMatchesSender(m, sender.value))
                .toList();
          }
          if (after.value != null) {
            local = local
                .where((m) => !m.createdAt.isBefore(after.value!.toUtc()))
                .toList();
          }
          if (before.value != null) {
            local = local
                .where((m) => m.createdAt.isBefore(before.value!.toUtc()))
                .toList();
          }

          final rooms =
              ref.read(chatRoomJoinedProvider).value ?? const <SnChatRoom>[];
          final roomsById = {for (final room in rooms) room.id: room};
          nextGroups = _groupMessagesByRoom(local, roomsById);

          // Local succeeded — clear cloud error if we have results.
          if (local.isNotEmpty) error.value = null;
        }

        if (currentRequest != request.value) return;
        groups.value = nextGroups;
        if (nextGroups.isNotEmpty) error.value = null;
      } catch (exception) {
        if (currentRequest == request.value) {
          error.value = exception;
        }
      } finally {
        if (currentRequest == request.value) isSearching.value = false;
      }
    }

    // Re-run whenever the host search field's debounced text changes.
    useEffect(() {
      search(query);
      return null;
    }, [query]);

    // Enrich groups missing room metadata from the joined rooms list.
    final joinedRooms = ref.watch(chatRoomJoinedProvider).value ?? const [];
    final displayGroups = useMemoized(() {
      final roomsById = {for (final room in joinedRooms) room.id: room};
      return [
        for (final group in groups.value)
          group.room != null
              ? group
              : _SearchRoomGroup(
                  roomId: group.roomId,
                  room: roomsById[group.roomId],
                  messages: group.messages,
                ),
      ];
    }, [groups.value, joinedRooms]);

    final filterBar = _ChatSearchFilterBar(
      cloudSearch: cloudSearch.value,
      onCloudSearchChanged: (value) => cloudSearch.value = value,
      withLinks: withLinks.value,
      withAttachments: withAttachments.value,
      onLinksChanged: (value) => withLinks.value = value,
      onAttachmentsChanged: (value) => withAttachments.value = value,
      sender: sender.value,
      onSenderChanged: (value) => sender.value = value,
      after: after.value,
      before: before.value,
      onAfterChanged: (value) => after.value = value,
      onBeforeChanged: (value) => before.value = value,
      onFiltersChanged: () => search(query),
    );

    // The host page's pill floats over this section, so its band is reserved
    // as the scroll view's first sliver: the first result clears the capsule
    // and everything after it travels under the glass. The narrow layout
    // reserves it inside its sliver; the wide layout's panes are siblings of
    // the pill, so they reserve it as padding instead (see below).
    final band = MediaQuery.paddingOf(context).top + kPillAppBarHeight;
    final topGap = band + kExploreCardGap;

    Widget buildGroup(_SearchRoomGroup group) => _SearchRoomSection(
      group: group,
      query: query,
      onOpenRoom: () =>
          context.router.navigate(ChatRoomRoute(id: group.roomId)),
      onJumpMessage: (messageId) => context.router.navigate(
        ChatRoomRoute(id: group.roomId, initialMessageId: messageId),
      ),
    );

    final results = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kChatSearchLedgerWidth),
        child: !hasSearched.value
            ? EmptyState(
                key: const Key('chatSearchIdle'),
                icon: Symbols.search,
                title: 'chatSearchIdleTitle'.tr(),
                description: 'chatSearchIdleBody'.tr(),
              )
            : error.value != null && displayGroups.isEmpty
            ? EmptyState(
                key: const Key('chatSearchError'),
                icon: Symbols.error_outline,
                iconColor: Theme.of(context).colorScheme.error,
                title: 'searchError'.tr(),
              )
            : displayGroups.isEmpty && !isSearching.value
            ? EmptyState(
                key: const Key('chatSearchNoResults'),
                icon: Symbols.search_off,
                title: 'noMessagesFound'.tr(),
                description: 'chatSearchNoResultsBody'.tr(),
              )
            : SuperListView.separated(
                // The card stack's own gutter, with the pill's band on top
                // (so rows scroll under the glass) and the last card clear of
                // the shell's bottom bar.
                padding: EdgeInsets.only(
                  left: SolSpace.md,
                  right: SolSpace.md,
                  top: topGap,
                  bottom:
                      MediaQuery.paddingOf(context).bottom + kExploreCardGap,
                ),
                itemCount: displayGroups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: kExploreCardGap),
                itemBuilder: (context, index) =>
                    buildGroup(displayGroups[index]),
              ),
      ),
    );

    // The pill is the host scaffold's app bar, so it floats over the filter
    // pane as well as over the results: both have to start below it, or the
    // pane's first control paints behind the capsule. The pane carries no
    // surface of its own — it is a column of controls over the page ground.
    if (isWideScreen(context)) {
      return ResponsiveSidebar(
        showSidebar: filtersVisible,
        isLeft: false,
        sidebarWidth: 320,
        sidebarBackgroundColor: Colors.transparent,
        sidebarElevation: 0,
        sidebarContent: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            SolSpace.md,
            band + SolSpace.md,
            SolSpace.md,
            SolSpace.md,
          ),
          child: filterBar,
        ),
        mainContent: results,
      );
    }

    // Narrow: one scroll view for the whole section. The filter bar and the
    // result cards are its slivers, so both travel under the host page's pill
    // instead of a fixed bar stopping them at the capsule.
    return CustomScrollView(
      slivers: [
        SliverGap(topGap),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kChatSearchLedgerWidth,
              ),
              child: _CollapsibleFilterHeader(
                visible: filterVisible,
                child: filterBar,
              ),
            ),
          ),
        ),
        if (!hasSearched.value)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              key: const Key('chatSearchIdle'),
              icon: Symbols.search,
              title: 'chatSearchIdleTitle'.tr(),
              description: 'chatSearchIdleBody'.tr(),
            ),
          )
        else if (error.value != null && displayGroups.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              key: const Key('chatSearchError'),
              icon: Symbols.error_outline,
              iconColor: Theme.of(context).colorScheme.error,
              title: 'searchError'.tr(),
            ),
          )
        else if (displayGroups.isEmpty && !isSearching.value)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              key: const Key('chatSearchNoResults'),
              icon: Symbols.search_off,
              title: 'noMessagesFound'.tr(),
              description: 'chatSearchNoResultsBody'.tr(),
            ),
          )
        else
          SliverPadding(
            // The card stack's own gutter, with the last card clear of the
            // shell's bottom bar.
            padding: EdgeInsets.only(
              left: SolSpace.md,
              right: SolSpace.md,
              bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
            ),
            sliver: SliverList.separated(
              itemCount: displayGroups.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: kExploreCardGap),
              itemBuilder: (context, index) => buildGroup(displayGroups[index]),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grouping + room section UI
// ---------------------------------------------------------------------------

/// Animated filter chrome that collapses on scroll (see [CreatorPostListScreen]).
class _CollapsibleFilterHeader extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _CollapsibleFilterHeader({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, -0.08),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: visible
              ? Padding(
                  key: const ValueKey('filters-visible'),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: child,
                )
              : const SizedBox(key: ValueKey('filters-hidden')),
        ),
      ),
    );
  }
}

class _SearchRoomGroup {
  final String roomId;
  final SnChatRoom? room;
  final List<LocalChatMessage> messages;

  const _SearchRoomGroup({
    required this.roomId,
    required this.room,
    required this.messages,
  });
}

/// Groups search hits by room while preserving first-seen room order.
List<_SearchRoomGroup> _groupMessagesByRoom(
  List<LocalChatMessage> messages,
  Map<String, SnChatRoom> roomsById,
) {
  final order = <String>[];
  final buckets = <String, List<LocalChatMessage>>{};

  for (final message in messages) {
    final roomId = message.roomId;
    final bucket = buckets.putIfAbsent(roomId, () {
      order.add(roomId);
      return <LocalChatMessage>[];
    });
    bucket.add(message);
  }

  return [
    for (final roomId in order)
      _SearchRoomGroup(
        roomId: roomId,
        room: roomsById[roomId],
        messages: buckets[roomId]!,
      ),
  ];
}

/// One room's matches: the band that names it, then its hits down a hairline
/// spine that runs from the band to the last row, so a group reads as that
/// room's transcript rather than another block of list.
class _SearchRoomSection extends StatelessWidget {
  final _SearchRoomGroup group;
  final String query;
  final VoidCallback onOpenRoom;
  final void Function(String messageId) onJumpMessage;

  const _SearchRoomSection({
    required this.group,
    required this.query,
    required this.onOpenRoom,
    required this.onJumpMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // The spine is a painted edge, not a stretched child: a sliver hands its
    // items an unbounded height, which a stretched Row would try to fill.
    //
    // One room is one card: its band and hits share a single floating surface,
    // the way an explore card owns its section.
    return ExploreCard(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 2,
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchRoomHeader(
              roomId: group.roomId,
              room: group.room,
              messages: group.messages,
              onTap: onOpenRoom,
            ),
            for (final message in group.messages)
              _ChatSearchMatchTile(
                message: message,
                query: query,
                onJump: onJumpMessage,
              ),
            const SizedBox(height: SolSpace.md),
          ],
        ),
      ),
    );
  }
}

/// One hit: who said it and when, then the body with the query marked.
///
/// Text bodies draw an excerpt built by [buildMessageSearchExcerpt] so the hit
/// is visible in the row itself. Everything the excerpt cannot stand in for —
/// stickers, events, calls, bodies that never decrypted — keeps the rich
/// renderer, which is the only thing that can draw it.
class _ChatSearchMatchTile extends StatelessWidget {
  final LocalChatMessage message;
  final String query;
  final void Function(String messageId) onJump;

  const _ChatSearchMatchTile({
    required this.message,
    required this.query,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remoteMessage = message.toRemoteMessage();
    final excerpt = message.type == 'text'
        ? buildMessageSearchExcerpt(
            content:
                resolveE2eeDisplayContentForMessage(remoteMessage).content ??
                '',
            query: query,
          )
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onJump(message.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePictureWidget(
                file: remoteMessage.sender.account.profile.picture,
                fallbackName: remoteMessage.sender.account.nick,
                radius: 16,
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MessageSenderInfo(
                      roomId: message.roomId,
                      sender: remoteMessage.sender,
                      createdAt: message.createdAt,
                      textColor: colorScheme.onSurfaceVariant,
                      showAvatar: false,
                      isCompact: true,
                    ),
                    const Gap(3),
                    if (excerpt != null)
                      _MessageExcerptText(excerpt: excerpt)
                    else
                      MessageContent(item: remoteMessage, isSelectable: false),
                    if (remoteMessage.attachments.isNotEmpty)
                      LayoutBuilder(
                        builder: (context, constraints) => CloudFileList(
                          files: remoteMessage.attachments,
                          maxWidth: constraints.maxWidth,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ..._linkEmbeds(remoteMessage, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The link cards a message carries, held to a column width a result row can
/// afford instead of the reading width a chat bubble gets.
List<Widget> _linkEmbeds(SnChatMessage message, BuildContext context) {
  final embeds = message.meta['embeds'];
  if (embeds is! List) return const [];
  return [
    for (final embed in embeds)
      if (embed is Map)
        LayoutBuilder(
          builder: (context, constraints) => EmbedLinkWidget(
            link: SnScrappedLink.fromJson(
              convertMapKeysToSnakeCase(Map<String, dynamic>.from(embed)),
            ),
            maxWidth: math.min(constraints.maxWidth, 320),
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
  ];
}

/// The body of a result row: one window of the message, its hit drawn with
/// the same ink the composer gives `==highlight==`.
class _MessageExcerptText extends StatelessWidget {
  final MessageSearchExcerpt excerpt;

  const _MessageExcerptText({required this.excerpt});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35) ??
        const TextStyle(fontSize: 14, height: 1.35);
    final marked = base.copyWith(backgroundColor: colorScheme.primaryContainer);

    return Text.rich(
      TextSpan(
        children: [
          for (final run in excerpt.runs)
            TextSpan(text: run.text, style: run.marked ? marked : base),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Room band: avatar, DM-aware title and the reach of this room's matches
/// (how many, and the days they fall on).
class _SearchRoomHeader extends ConsumerWidget {
  final String roomId;
  final SnChatRoom? room;
  final List<LocalChatMessage> messages;
  final VoidCallback onTap;

  const _SearchRoomHeader({
    required this.roomId,
    required this.room,
    required this.messages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final room = this.room;
    final isDirect = room?.type == 1;

    var validMembers = room?.members ?? const <SnChatMember>[];
    if (validMembers.isNotEmpty) {
      final userInfo = ref.watch(userInfoProvider);
      if (userInfo.value != null) {
        validMembers = validMembers
            .where((e) => e.accountId != userInfo.value!.id)
            .toList();
      }
    }

    final titleText = _resolveRoomTitle(
      ref: ref,
      room: room,
      isDirect: isDirect,
      validMembers: validMembers,
    );

    // Newest-first ordering is what both search paths return, but the reach of
    // a room's matches is worth stating exactly rather than inferring.
    var newest = messages.first.createdAt;
    var oldest = newest;
    for (final message in messages.skip(1)) {
      if (message.createdAt.isAfter(newest)) newest = message.createdAt;
      if (message.createdAt.isBefore(oldest)) oldest = message.createdAt;
    }

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      letterSpacing: -0.2,
      height: 1.2,
    );
    final reachStyle = GoogleFonts.robotoMono(
      fontSize: 11,
      height: 1.2,
      letterSpacing: 0.1,
      color: colorScheme.onSurfaceVariant,
    );

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
          child: Row(
            children: [
              if (room != null)
                ChatRoomAvatar(
                  room: room,
                  isDirect: isDirect,
                  summary: const AsyncValue.data(null),
                  validMembers: validMembers,
                  radius: 18,
                  hideRealm: false,
                )
              else
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Symbols.chat,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            titleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                        if (room != null && room.encryptionMode != 0) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.lock_outline,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${'matches'.plural(messages.length)}  ·  '
                      '${formatMatchDateSpan(newest, oldest)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: reachStyle,
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveRoomTitle({
    required WidgetRef ref,
    required SnChatRoom? room,
    required bool isDirect,
    required List<SnChatMember> validMembers,
  }) {
    if (room == null) return 'Chat';

    // Match [ChatRoomListTile]: direct rooms without a custom name use
    // peer nicknames (prefer relationship alias when set).
    if (isDirect && room.name == null) {
      if (validMembers.isEmpty) return 'Direct Message';
      final names = <String>[];
      for (final member in validMembers) {
        final aliasAsync = ref.watch(
          relationshipAliasProvider(member.accountId),
        );
        final alias = aliasAsync.hasValue ? aliasAsync.value : null;
        names.add(
          (alias != null && alias.isNotEmpty) ? alias : member.account.nick,
        );
      }
      return names.join(', ');
    }

    final name = room.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Chat';
  }
}
