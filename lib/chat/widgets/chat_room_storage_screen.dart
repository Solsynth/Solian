import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_room_widgets.dart';
import 'package:island/core/database.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class ChatRoomStorageScreen extends HookConsumerWidget {
  const ChatRoomStorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomJoinedProvider);
    final summariesAsync = ref.watch(chatSummaryProvider);
    final db = ref.watch(databaseProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('settingsChatRoomStorage').tr(),
        leading: const AutoLeadingButton(),
        elevation: 0,
      ),
      body: roomsAsync.when(
        data: (rooms) {
          final summaries = summariesAsync.whenData((data) => data).value ?? {};
          return _RoomStorageList(
            rooms: rooms,
            summaries: summaries,
            db: db,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _RoomStorageList extends ConsumerStatefulWidget {
  final List<SnChatRoom> rooms;
  final Map<String, SnChatSummary> summaries;
  final AppDatabase db;

  const _RoomStorageList({
    required this.rooms,
    required this.summaries,
    required this.db,
  });

  @override
  ConsumerState<_RoomStorageList> createState() => _RoomStorageListState();
}

class _RoomStorageListState extends ConsumerState<_RoomStorageList> {
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await widget.db.getChatRoomMessageStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _clearRoomHistory(String roomId, String roomName) async {
    final confirmed = await showConfirmAlert(
      'settingsClearChatHistoryConfirm'.tr(args: [roomName]),
      'settingsClearChatHistory'.tr(),
      isDanger: true,
    );
    if (confirmed != true) return;

    await widget.db.deleteMessagesForRoom(roomId);
    await _loadStats();
    if (mounted) {
      showSnackBar('settingsApplied'.tr());
    }
  }

  Future<void> _exportRoomMessages(
    String roomId,
    String roomName,
    String format,
  ) async {
    if (kIsWeb) {
      showSnackBar('Export not supported on web');
      return;
    }

    showLoadingModal(context);

    try {
      final allMessages = <LocalChatMessage>[];
      int offset = 0;
      const batchSize = 500;

      while (true) {
        final batch = await widget.db.getMessagesForRoom(
          roomId,
          offset: offset,
          limit: batchSize,
        );
        if (batch.isEmpty) break;
        allMessages.addAll(batch);
        offset += batchSize;
        if (batch.length < batchSize) break;
      }

      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      String content;
      String extension;
      String mimeType;

      if (format == 'json') {
        final jsonList = allMessages.map((msg) {
          final map = <String, dynamic>{
            'id': msg.id,
            'sender_id': msg.senderId,
            'sender_name': msg.sender?.account.nick ?? msg.senderId,
            'content': msg.content,
            'type': msg.type,
            'created_at': msg.createdAt.toIso8601String(),
            'meta': msg.meta,
            'attachments': msg.attachments,
            'reactions': msg.reactions,
            'members_mentioned': msg.membersMentioned,
            'edited_at': msg.editedAt?.toIso8601String(),
            'is_deleted': msg.isDeleted,
          };
          if (msg.repliedMessageId != null) {
            map['replied_message_id'] = msg.repliedMessageId;
          }
          if (msg.forwardedMessageId != null) {
            map['forwarded_message_id'] = msg.forwardedMessageId;
          }
          return map;
        }).toList();
        content = const JsonEncoder.withIndent('  ').convert(jsonList);
        extension = 'json';
        mimeType = 'application/json';
      } else {
        final buffer = StringBuffer();
        buffer.writeln('ID,Sender,Content,Type,Created At,Edited At,Deleted');
        for (final msg in allMessages) {
          final senderName = msg.sender?.account.nick ?? msg.senderId;
          final contentText = (msg.content ?? '').replaceAll('"', '""');
          final editedAt = msg.editedAt?.toIso8601String() ?? '';
          final isDeleted = msg.isDeleted?.toString() ?? 'false';
          buffer.writeln(
            '"${msg.id}","${senderName.replaceAll('"', '""')}","$contentText","${msg.type}","${msg.createdAt.toIso8601String()}","$editedAt","$isDeleted"',
          );
        }
        content = buffer.toString();
        extension = 'csv';
        mimeType = 'text/csv';
      }

      final dir = await getTemporaryDirectory();
      final safeName = roomName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/chat_export_${safeName}_$timestamp.$extension');
      await file.writeAsString(content);

      if (!mounted) return;
      hideLoadingModal(context);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        hideLoadingModal(context);
        showErrorAlert(e);
      }
    }
  }

  void _showExportOptions(String roomId, String roomName) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.dataset),
              title: const Text('Export as JSON'),
              subtitle: Text('settingsExportJsonDesc'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportRoomMessages(roomId, roomName, 'json');
              },
            ),
            ListTile(
              leading: const Icon(Symbols.table_rows),
              title: const Text('Export as CSV'),
              subtitle: Text('settingsExportCsvDesc'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportRoomMessages(roomId, roomName, 'csv');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userInfo = ref.watch(userInfoProvider);
    final totalCount = _stats.values.fold(0, (a, b) => a + b);

    final roomStats = widget.rooms
        .map((room) => _RoomStat(room: room, count: _stats[room.id] ?? 0))
        .where((s) => s.count > 0)
        .toList();
    roomStats.sort((a, b) => b.count.compareTo(a.count));

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settingsTotalMessages'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                totalCount.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: roomStats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.chat_bubble,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'settingsNoChatMessages'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: roomStats.length,
                  itemBuilder: (context, index) {
                    final stat = roomStats[index];
                    final room = stat.room;
                    final isDirect = room.type == 1;
                    final summary = widget.summaries[room.id];

                    var validMembers = room.members ?? <SnChatMember>[];
                    if (validMembers.isNotEmpty && userInfo.value != null) {
                      validMembers = validMembers
                          .where((e) => e.accountId != userInfo.value!.id)
                          .toList();
                    }

                    String roomName;
                    if (isDirect && room.name == null) {
                      roomName = validMembers.isNotEmpty
                          ? validMembers.map((e) => e.account.nick).join(', ')
                          : 'Direct Message';
                    } else {
                      roomName = room.name ?? 'settingsUnknownRoom'.tr();
                    }

                    return ListTile(
                      leading: ChatRoomAvatar(
                        room: room,
                        isDirect: isDirect,
                        summary: AsyncValue.data(summary),
                        validMembers: validMembers,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              roomName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (room.encryptionMode != 0)
                            Icon(
                              Icons.lock,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'settingsMessageCount'.tr(
                          args: [stat.count.toString()],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!kIsWeb)
                            IconButton(
                              icon: const Icon(Symbols.download),
                              onPressed: () =>
                                  _showExportOptions(room.id, roomName),
                              tooltip: 'settingsExportChat'.tr(),
                            ),
                          IconButton(
                            icon: Icon(
                              Symbols.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () =>
                                _clearRoomHistory(room.id, roomName),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RoomStat {
  final SnChatRoom room;
  final int count;

  _RoomStat({required this.room, required this.count});
}
