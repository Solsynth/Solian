import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/database.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/data/database.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _ChatGroupIconOption {
  const _ChatGroupIconOption(this.id, this.icon);

  final String id;
  final IconData icon;
}

const List<String> _chatGroupColorOptions = <String>[
  '#4A90D9',
  '#7ED321',
  '#F5A623',
  '#E35D6A',
  '#8B5CF6',
  '#14B8A6',
];

const List<_ChatGroupIconOption> _chatGroupIconOptions = <_ChatGroupIconOption>[
  _ChatGroupIconOption('folder', Symbols.folder),
  _ChatGroupIconOption('work', Symbols.work),
  _ChatGroupIconOption('favorite', Symbols.favorite),
  _ChatGroupIconOption('forum', Symbols.forum),
  _ChatGroupIconOption('school', Symbols.school),
  _ChatGroupIconOption('bolt', Symbols.bolt),
];

Color? chatGroupColorFromHex(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.replaceFirst('#', '');
  final hex = switch (normalized.length) {
    6 => 'FF$normalized',
    8 => normalized,
    _ => '',
  };
  if (hex.isEmpty) return null;
  return Color(int.tryParse(hex, radix: 16) ?? 0xFF9E9E9E);
}

IconData _chatGroupIconData(String? value) {
  for (final option in _chatGroupIconOptions) {
    if (option.id == value) return option.icon;
  }
  return Symbols.folder;
}

bool _chatGroupIconIsPreset(String? value) {
  if (value == null || value.isEmpty) return false;
  return _chatGroupIconOptions.any((option) => option.id == value);
}

Widget buildChatGroupIconWidget(
  String? value, {
  Color? color,
  double iconSize = 20,
  double emojiFontSize = 18,
}) {
  if (value != null && value.isNotEmpty && !_chatGroupIconIsPreset(value)) {
    return Text(
      value,
      style: TextStyle(fontSize: emojiFontSize, height: 1),
      textAlign: TextAlign.center,
    ).padding(left: 3);
  }
  return Icon(_chatGroupIconData(value), color: color, size: iconSize);
}

List<SnChatGroup> _normalizeChatGroups(List<SnChatGroup> groups) {
  final sorted = groups.toList()..sort((a, b) => a.order.compareTo(b.order));
  return [for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i)];
}

final chatGroupsProvider = FutureProvider<List<SnChatGroup>>((ref) async {
  final db = ref.watch(databaseProvider);
  final userInfo = ref.watch(userInfoProvider);
  final accountId = userInfo.value?.id;
  if (accountId == null) return const <SnChatGroup>[];
  return db.getChatGroups(accountId);
});

int _nextChatGroupOrder(List<SnChatGroup> groups) {
  if (groups.isEmpty) return 0;
  return groups.map((group) => group.order).reduce(math.max) + 1;
}

String _createChatGroupId() {
  return 'local-chat-group-${DateTime.now().toUtc().microsecondsSinceEpoch}';
}

List<SnChatGroup> _upsertChatGroup(
  List<SnChatGroup> groups,
  SnChatGroup group,
) {
  final next = groups.where((item) => item.id != group.id).toList()..add(group);
  return _normalizeChatGroups(next);
}

List<SnChatGroup> _removeChatGroup(List<SnChatGroup> groups, String groupId) {
  return _normalizeChatGroups(
    groups.where((item) => item.id != groupId).toList(),
  );
}

List<SnChatGroup> _applyRoomGroupAssignment(
  List<SnChatGroup> groups,
  String roomId, {
  String? groupId,
}) {
  return _normalizeChatGroups(
    groups.map((group) {
      final nextRoomIds = group.roomIds.where((id) => id != roomId).toList();
      if (group.id == groupId) nextRoomIds.add(roomId);
      return group.copyWith(roomIds: nextRoomIds);
    }).toList(),
  );
}

Future<SnChatGroup?> _showChatGroupEditorSheet(
  BuildContext context, {
  required String accountId,
  SnChatGroup? initialGroup,
  required int nextOrder,
}) async {
  final nameController = TextEditingController(text: initialGroup?.name ?? '');
  final iconController = TextEditingController(text: initialGroup?.icon ?? '');
  var selectedColor = initialGroup?.color ?? _chatGroupColorOptions.first;
  var selectedIcon = initialGroup?.icon ?? '';

  return showModalBottomSheet<SnChatGroup>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SheetScaffold(
            titleText: initialGroup == null ? 'Create Group' : 'Edit Group',
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: 256,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const Gap(12),
                  TextField(
                    controller: iconController,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'Icon or emoji',
                      hintText: '📁',
                    ),
                    onChanged: (value) => selectedIcon = value.trim(),
                  ),
                  const Gap(12),
                  Text('Color', style: Theme.of(context).textTheme.titleSmall),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final color in _chatGroupColorOptions)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () =>
                              setModalState(() => selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: chatGroupColorFromHex(color),
                              border: Border.all(
                                color: selectedColor == color
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selectedColor == color
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                  const Gap(20),
                  FilledButton(
                    onPressed: () {
                      final trimmedName = nameController.text.trim();
                      if (trimmedName.isEmpty) return;
                      final now = DateTime.now().toUtc();
                      Navigator.of(context).pop(
                        SnChatGroup(
                          id: initialGroup?.id ?? _createChatGroupId(),
                          accountId: accountId,
                          name: trimmedName,
                          color: selectedColor,
                          icon: selectedIcon,
                          order: initialGroup?.order ?? nextOrder,
                          roomIds: initialGroup?.roomIds ?? const [],
                          createdAt: initialGroup?.createdAt ?? now,
                          updatedAt: now,
                        ),
                      );
                    },
                    child: Text(initialGroup == null ? 'Create' : 'Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool> showChatGroupsManagerSheet(
  BuildContext context, {
  required Dio client,
  required AppDatabase db,
  required String accountId,
  required List<SnChatGroup> groups,
}) async {
  var currentGroups = _normalizeChatGroups(groups);
  var changed = false;

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> persist(List<SnChatGroup> nextGroups) async {
            currentGroups = _normalizeChatGroups(nextGroups);
            await db.saveChatGroups(accountId, currentGroups);
            changed = true;
            eventBus.fire(const ChatGroupsRefreshEvent());
            setModalState(() {});
          }

          return SheetScaffold(
            titleText: 'Chat Groups',
            actions: [
              IconButton(
                icon: const Icon(Symbols.add),
                onPressed: () async {
                  final group = await _showChatGroupEditorSheet(
                    context,
                    accountId: accountId,
                    nextOrder: _nextChatGroupOrder(currentGroups),
                  );
                  if (group == null) return;
                  final response = await client.post(
                    '/messager/chat/groups',
                    data: {
                      'name': group.name,
                      'color': group.color,
                      'icon': group.icon,
                      'order': group.order,
                    }..removeWhere((_, value) => value == null),
                  );
                  final created = SnChatGroup.fromJson(
                    Map<String, dynamic>.from(response.data as Map),
                  );
                  await persist(_upsertChatGroup(currentGroups, created));
                },
              ),
            ],
            child: currentGroups.isEmpty
                ? const Center(child: Text('No chat groups yet'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: currentGroups.length,
                    itemBuilder: (context, index) {
                      final group = currentGroups[index];
                      final groupColor =
                          chatGroupColorFromHex(group.color) ??
                          Theme.of(context).colorScheme.primary;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: groupColor.withOpacity(0.16),
                          foregroundColor: groupColor,
                          child: buildChatGroupIconWidget(
                            group.icon,
                            color: groupColor,
                          ),
                        ),
                        title: Text(group.name),
                        subtitle: Text(
                          '${group.roomIds.length} room${group.roomIds.length == 1 ? '' : 's'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: index == 0
                                  ? null
                                  : () async {
                                      final next = currentGroups.toList();
                                      final temp = next[index - 1];
                                      next[index - 1] = next[index];
                                      next[index] = temp;
                                      final normalized = _normalizeChatGroups(
                                        next,
                                      );
                                      for (final group in normalized) {
                                        await client.patch(
                                          '/messager/chat/groups/${group.id}',
                                          data: {'order': group.order},
                                        );
                                      }
                                      await persist(normalized);
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: index == currentGroups.length - 1
                                  ? null
                                  : () async {
                                      final next = currentGroups.toList();
                                      final temp = next[index + 1];
                                      next[index + 1] = next[index];
                                      next[index] = temp;
                                      final normalized = _normalizeChatGroups(
                                        next,
                                      );
                                      for (final group in normalized) {
                                        await client.patch(
                                          '/messager/chat/groups/${group.id}',
                                          data: {'order': group.order},
                                        );
                                      }
                                      await persist(normalized);
                                    },
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final edited =
                                      await _showChatGroupEditorSheet(
                                        context,
                                        accountId: accountId,
                                        initialGroup: group,
                                        nextOrder: group.order,
                                      );
                                  if (edited == null) return;
                                  final response = await client.patch(
                                    '/messager/chat/groups/${group.id}',
                                    data: {
                                      'name': edited.name,
                                      'color': edited.color,
                                      'icon': edited.icon,
                                      'order': edited.order,
                                    }..removeWhere((_, value) => value == null),
                                  );
                                  final updated = SnChatGroup.fromJson(
                                    Map<String, dynamic>.from(
                                      response.data as Map,
                                    ),
                                  );
                                  await persist(
                                    _upsertChatGroup(currentGroups, updated),
                                  );
                                  return;
                                }
                                if (value == 'delete') {
                                  await client.delete(
                                    '/messager/chat/groups/${group.id}',
                                  );
                                  await persist(
                                    _removeChatGroup(currentGroups, group.id),
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      );
    },
  );

  return changed;
}

Future<bool> showAssignChatGroupSheet(
  BuildContext context, {
  required Dio client,
  required AppDatabase db,
  required String accountId,
  required SnChatRoom room,
  required List<SnChatGroup> groups,
}) async {
  SnChatGroup? currentGroup;
  for (final group in groups) {
    if (group.roomIds.contains(room.id)) {
      currentGroup = group;
      break;
    }
  }

  var changed = false;
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return SheetScaffold(
        heightFactor: 0.6,
        titleText: 'Move To Group',
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 16,
                child: const Icon(Symbols.do_not_disturb_on),
              ),
              title: const Text('Ungrouped'),
              trailing: currentGroup == null ? const Icon(Icons.check) : null,
              onTap: () async {
                await client.patch(
                  '/messager/chat/rooms/${room.id}/group',
                  data: {'group_id': null},
                );
                await db.saveChatGroups(
                  accountId,
                  _applyRoomGroupAssignment(groups, room.id),
                );
                changed = true;
                eventBus.fire(const ChatGroupsRefreshEvent());
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            for (final group in _normalizeChatGroups(groups))
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      (chatGroupColorFromHex(group.color) ??
                              Theme.of(context).colorScheme.primary)
                          .withOpacity(0.16),
                  foregroundColor:
                      chatGroupColorFromHex(group.color) ??
                      Theme.of(context).colorScheme.primary,
                  child: buildChatGroupIconWidget(
                    group.icon,
                    color:
                        chatGroupColorFromHex(group.color) ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(group.name),
                trailing: currentGroup?.id == group.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () async {
                  await client.patch(
                    '/messager/chat/rooms/${room.id}/group',
                    data: {'group_id': group.id},
                  );
                  await db.saveChatGroups(
                    accountId,
                    _applyRoomGroupAssignment(
                      groups,
                      room.id,
                      groupId: group.id,
                    ),
                  );
                  changed = true;
                  eventBus.fire(const ChatGroupsRefreshEvent());
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              leading: CircleAvatar(radius: 16, child: const Icon(Symbols.add)),
              title: const Text('Create New Group'),
              onTap: () async {
                final created = await _showChatGroupEditorSheet(
                  context,
                  accountId: accountId,
                  nextOrder: _nextChatGroupOrder(groups),
                );
                if (created == null) return;
                final createdResp = await client.post(
                  '/messager/chat/groups',
                  data: {
                    'name': created.name,
                    'color': created.color,
                    'icon': created.icon,
                    'order': created.order,
                  }..removeWhere((_, value) => value == null),
                );
                final createdGroup = SnChatGroup.fromJson(
                  Map<String, dynamic>.from(createdResp.data as Map),
                );
                await client.patch(
                  '/messager/chat/rooms/${room.id}/group',
                  data: {'group_id': createdGroup.id},
                );
                await db.saveChatGroups(
                  accountId,
                  _applyRoomGroupAssignment(
                    _upsertChatGroup(groups, createdGroup),
                    room.id,
                    groupId: createdGroup.id,
                  ),
                );
                changed = true;
                eventBus.fire(const ChatGroupsRefreshEvent());
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
  return changed;
}
