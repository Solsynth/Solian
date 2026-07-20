import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:island/chat/widgets/message_list_tile.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
  final VoidCallback? onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    this.stateIcon,
    required this.emphasized,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final foreground = !enabled
        ? colorScheme.onSurface.withOpacity(0.38)
        : emphasized
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: emphasized && enabled
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const Gap(6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: !enabled
                        ? colorScheme.onSurface.withOpacity(0.38)
                        : emphasized
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
                if (stateIcon != null) ...[
                  const Gap(6),
                  Icon(stateIcon, size: 16, color: foreground),
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

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
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
            Material(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => showAdvanced.value = !showAdvanced.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Symbols.tune,
                          size: 18,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'advancedFilters'.tr(),
                              style: theme.textTheme.labelLarge,
                            ),
                            Text(
                              '${'account'.tr()} · ${'fromDate'.tr()} · ${'toDate'.tr()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (_advancedCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$_advancedCount',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Gap(6),
                      ],
                      Icon(
                        showAdvanced.value
                            ? Symbols.expand_less
                            : Symbols.expand_more,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                      if (_advancedCount > 0) ...[
                        const Gap(6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              onSenderChanged(null);
                              onAfterChanged(null);
                              onBeforeChanged(null);
                              onFiltersChanged();
                            },
                            icon: const Icon(Symbols.restart_alt),
                            label: Text('clear'.tr()),
                          ),
                        ),
                      ],
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
        ),
      ),
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
                ProfilePictureWidget(file: account!.profile.picture, radius: 16)
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

/// Bottom status bar showing total search match count.
class _SearchStatusBar extends StatelessWidget implements PreferredSizeWidget {
  final int totalMatches;
  final bool isSearching;

  /// Optional info tooltip (e.g. global search limitations).
  final String? infoTooltip;

  const _SearchStatusBar({
    required this.totalMatches,
    this.isSearching = false,
    this.infoTooltip,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainer,
      elevation: 2,
      child: SafeArea(
        top: false,
        child: Container(
          height: preferredSize.height,
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              // Keep the match count centered even when an info icon is present.
              SizedBox(width: infoTooltip != null ? 36 : 0),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSearching) ...[
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Gap(10),
                    ],
                    Flexible(
                      child: Text(
                        'matches'.plural(totalMatches),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (infoTooltip != null)
                Tooltip(
                  message: infoTooltip!,
                  preferBelow: false,
                  waitDuration: const Duration(milliseconds: 200),
                  showDuration: const Duration(seconds: 6),
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(
                    Symbols.info,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                const SizedBox(width: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const _SearchEmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: muted.withValues(alpha: 0.6)),
            const Gap(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: muted),
            ),
            if (subtitle != null) ...[
              const Gap(8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
            if (action != null) ...[const Gap(16), action!],
          ],
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
          var total = 0;

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
              total = page.total;
              if (messages.isNotEmpty) {
                await database.saveMessagesWithSenders(messages);
              }
              if (withLinks.value) {
                messages = messages.where(_messageHasLink).toList();
                // X-Total is pre-filter; prefer filtered length when narrowing.
                total = messages.length;
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
              total = local.length;
            } else if (hasLocalFilters) {
              // Prefer cloud hits that also satisfy local filters; fill gaps.
              final cloudIds = messages.map((m) => m.id).toSet();
              final extra = local.where((m) => !cloudIds.contains(m.id));
              messages = [...messages, ...extra];
              total = messages.length;
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
            total = messages.length;
          }

          searchResults.value = AsyncValue.data(messages);
          searchState.value = messages.isEmpty
              ? SearchState.noResults
              : SearchState.results;
          searchResultCount.value = total;
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
    final showStatusBar =
        searchState.value == SearchState.results ||
        searchState.value == SearchState.noResults ||
        searchState.value == SearchState.searching;
    final totalMatches = searchResultCount.value ?? 0;

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
            tooltip: 'Search all chats',
            onPressed: () =>
                context.router.replace(const SearchAllMessagesRoute()),
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
      bottomNavigationBar: showStatusBar
          ? _SearchStatusBar(
              totalMatches: totalMatches,
              isSearching: searchState.value == SearchState.searching,
            )
          : null,
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
                          return _SearchEmptyState(
                            icon: Symbols.search,
                            title: 'searchMessagesHint'.tr(),
                          );

                        case SearchState.noResults:
                          return _SearchEmptyState(
                            icon: Symbols.search_off,
                            title: 'noMessagesFound'.tr(),
                            subtitle: 'tryDifferentKeywords'.tr(),
                          );

                        case SearchState.results:
                          return SuperListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            reverse: false,
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              final message = messageList[index];
                              return MessageListTile(
                                message: message,
                                onJump: (messageId) {
                                  context.pop(SearchMessagesResult(messageId));
                                },
                              );
                            },
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
                    error: (error, _) => _SearchEmptyState(
                      icon: Symbols.error_outline,
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

/// Local-first when offline / filtering attachments; cloud for text index.
@RoutePage()
class SearchAllMessagesScreen extends HookConsumerWidget {
  const SearchAllMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    useListenable(controller);

    final withLinks = useState(false);
    final withAttachments = useState(false);
    final cloudSearch = useState(true);
    final sender = useState<SnAccount?>(null);
    final after = useState<DateTime?>(null);
    final before = useState<DateTime?>(null);
    final isFilterVisible = useState(true);
    final groups = useState<List<_SearchRoomGroup>>([]);
    final totalMatches = useState(0);
    final isSearching = useState(false);
    final hasSearched = useState(false);
    final error = useState<Object?>(null);
    final debounce = useRef<Timer?>(null);
    final request = useRef(0);
    final database = ref.read(databaseProvider);
    final client = ref.read(apiClientProvider);

    Future<void> search(String rawQuery) async {
      debounce.value?.cancel();
      final query = rawQuery.trim();
      final hasLocalFilters = withLinks.value || withAttachments.value;
      final hasCloudFilters =
          sender.value != null || after.value != null || before.value != null;

      if (query.isEmpty && !hasLocalFilters && !hasCloudFilters) {
        groups.value = [];
        totalMatches.value = 0;
        hasSearched.value = false;
        error.value = null;
        return;
      }

      final currentRequest = ++request.value;
      isSearching.value = true;
      hasSearched.value = true;
      error.value = null;

      debounce.value = Timer(const Duration(milliseconds: 250), () async {
        try {
          List<_SearchRoomGroup> nextGroups = [];
          var total = 0;

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
              total = page.total;

              final flat = page.messages;
              if (flat.isNotEmpty) {
                await database.saveMessagesWithSenders(flat);
              }

              if (withLinks.value) {
                nextGroups = [
                  for (final g in nextGroups)
                    _SearchRoomGroup(
                      roomId: g.roomId,
                      room: g.room,
                      messages: g.messages.where(_messageHasLink).toList(),
                    ),
                ].where((g) => g.messages.isNotEmpty).toList();
                total = nextGroups.fold<int>(
                  0,
                  (sum, g) => sum + g.messages.length,
                );
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
            total = local.length;

            // Local succeeded — clear cloud error if we have results.
            if (local.isNotEmpty) error.value = null;
          }

          if (currentRequest != request.value) return;
          groups.value = nextGroups;
          totalMatches.value = total;
          if (nextGroups.isNotEmpty) error.value = null;
        } catch (exception) {
          if (currentRequest == request.value) {
            error.value = exception;
            if (groups.value.isEmpty) {
              totalMatches.value = 0;
            }
          }
        } finally {
          if (currentRequest == request.value) isSearching.value = false;
        }
      });
    }

    useEffect(
      () =>
          () => debounce.value?.cancel(),
      [],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) focusNode.requestFocus();
      });
      return null;
    }, []);

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

    final hasQuery = controller.text.isNotEmpty;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Search all chats'),
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
          const Gap(8),
        ],
        bottom: isSearching.value
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      bottomNavigationBar: hasSearched.value
          ? _SearchStatusBar(
              totalMatches: totalMatches.value,
              isSearching: isSearching.value,
              infoTooltip: 'chatGlobalSearchHint'.tr(),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  controller: controller,
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
                          controller.clear();
                          search('');
                          focusNode.requestFocus();
                        },
                      ),
                  ],
                  onChanged: search,
                  onSubmitted: (value) {
                    search(value);
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
                  onFiltersChanged: () => search(controller.text),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) =>
                      _updateFilterVisibilityFromScroll(
                        notification,
                        isFilterVisible,
                      ),
                  child: !hasSearched.value
                      ? _SearchEmptyState(
                          icon: Symbols.search,
                          title: 'Search messages in all chats',
                        )
                      : error.value != null && displayGroups.isEmpty
                      ? _SearchEmptyState(
                          icon: Symbols.error_outline,
                          title: 'searchError'.tr(),
                        )
                      : displayGroups.isEmpty && !isSearching.value
                      ? _SearchEmptyState(
                          icon: Symbols.search_off,
                          title: 'noMessagesFound'.tr(),
                        )
                      : SuperListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: displayGroups.length,
                          itemBuilder: (context, index) {
                            final group = displayGroups[index];
                            return _SearchRoomSection(
                              group: group,
                              onOpenRoom: () => context.router.navigate(
                                ChatRoomRoute(id: group.roomId),
                              ),
                              onJumpMessage: (messageId) =>
                                  context.router.navigate(
                                    ChatRoomRoute(
                                      id: group.roomId,
                                      initialMessageId: messageId,
                                    ),
                                  ),
                            );
                          },
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

class _SearchRoomSection extends StatelessWidget {
  final _SearchRoomGroup group;
  final VoidCallback onOpenRoom;
  final void Function(String messageId) onJumpMessage;

  const _SearchRoomSection({
    required this.group,
    required this.onOpenRoom,
    required this.onJumpMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchRoomHeader(
          roomId: group.roomId,
          room: group.room,
          matchCount: group.messages.length,
          onTap: onOpenRoom,
        ),
        for (final message in group.messages)
          MessageListTile(message: message, onJump: onJumpMessage),
      ],
    );
  }
}

/// Room header styled after [ChatRoomListTile]: avatar + DM-aware title.
class _SearchRoomHeader extends ConsumerWidget {
  final String roomId;
  final SnChatRoom? room;
  final int matchCount;
  final VoidCallback onTap;

  const _SearchRoomHeader({
    required this.roomId,
    required this.room,
    required this.matchCount,
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

    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      letterSpacing: -0.1,
      height: 1.2,
    );

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
                        Expanded(
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
                    const SizedBox(height: 2),
                    Text(
                      'matches'.plural(matchCount),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 20,
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
