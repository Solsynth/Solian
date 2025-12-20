import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/chat/chat_room.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';

class CommandPattleWidget extends HookConsumerWidget {
  final VoidCallback onDismiss;

  const CommandPattleWidget({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final searchQuery = useState('');
    final focusedIndex = useState<int?>(null);

    useEffect(() {
      focusNode.requestFocus();
      return null;
    }, []);

    useEffect(() {
      void listener() {
        searchQuery.value = textController.text;
        // Reset focused index when search changes
        focusedIndex.value = null;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    final chatRooms = ref.watch(chatRoomJoinedProvider);
    final userInfo = ref.watch(userInfoProvider);

    bool isDesktop() =>
        kIsWeb ||
        (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS));

    final filteredRooms = chatRooms.maybeWhen(
      data: (rooms) {
        if (searchQuery.value.isEmpty) return <SnChatRoom>[];
        return rooms
            .where((room) {
              final title = room.name ?? '';
              final desc = room.description ?? '';
              final query = searchQuery.value.toLowerCase();
              return title.toLowerCase().contains(query) ||
                  desc.toLowerCase().contains(query) ||
                  (room.members?.any(
                        (member) =>
                            member.account.name.contains(query) ||
                            member.account.nick.contains(query),
                      ) ??
                      false);
            })
            .take(5) // Limit to 5 results
            .toList();
      },
      orElse: () => <SnChatRoom>[],
    );

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            onDismiss();
          } else if (isDesktop()) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              if (focusedIndex.value != null &&
                  focusedIndex.value! < filteredRooms.length) {
                _navigateToRoom(
                  context,
                  ref,
                  filteredRooms[focusedIndex.value!],
                );
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (filteredRooms.isNotEmpty) {
                if (focusedIndex.value == null) {
                  focusedIndex.value = 0;
                } else {
                  focusedIndex.value = math.max(0, focusedIndex.value! - 1);
                }
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (filteredRooms.isNotEmpty) {
                if (focusedIndex.value == null) {
                  focusedIndex.value = 0;
                } else {
                  focusedIndex.value = math.min(
                    filteredRooms.length - 1,
                    focusedIndex.value! + 1,
                  );
                }
              }
            }
          }
        }
      },
      child: GestureDetector(
        onTap: onDismiss,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from dismissing when tapping inside
                child: Container(
                  width: math.max(MediaQuery.of(context).size.width * 0.6, 320),
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    maxHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchBar(
                        controller: textController,
                        focusNode: focusNode,
                        hintText: 'Search chats...',
                        leading: const Icon(
                          Symbols.keyboard_command_key,
                        ).padding(horizontal: 8),
                        onSubmitted: (_) {
                          if (filteredRooms.isNotEmpty) {
                            _navigateToRoom(context, ref, filteredRooms.first);
                          }
                        },
                      ),
                      if (filteredRooms.isNotEmpty)
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredRooms.length,
                            itemBuilder: (context, index) {
                              final room = filteredRooms[index];
                              return _ChatRoomSearchResult(
                                room: room,
                                isFocused: index == focusedIndex.value,
                                onTap: () =>
                                    _navigateToRoom(context, ref, room),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoom(BuildContext context, WidgetRef ref, SnChatRoom room) {
    onDismiss();
    if (isWideScreen(context)) {
      ref
          .read(routerProvider)
          .replaceNamed('chatRoom', pathParameters: {'id': room.id});
    } else {
      ref
          .read(routerProvider)
          .pushNamed('chatRoom', pathParameters: {'id': room.id});
    }
  }
}

class _ChatRoomSearchResult extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isFocused;
  final VoidCallback onTap;

  const _ChatRoomSearchResult({
    required this.room,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    var validMembers = room.members ?? [];
    if (validMembers.isNotEmpty && userInfo.value != null) {
      validMembers = validMembers
          .where((e) => e.accountId != userInfo.value!.id)
          .toList();
    }

    String titleText;
    if (room.type == 1 && room.name == null) {
      if (room.members?.isNotEmpty ?? false) {
        titleText = validMembers.map((e) => e.account.nick).join(', ');
      } else {
        titleText = 'Direct Message';
      }
    } else {
      titleText = room.name ?? '';
    }

    Widget buildSubtitle() {
      return summary.when(
        data: (data) => data == null
            ? (room.type == 1 && room.description == null
                  ? Text(
                      validMembers.map((e) => '@${e.account.name}').join(', '),
                    )
                  : Text(room.description ?? ''))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.unreadCount > 0)
                    Text(
                      'unreadMessages'.plural(data.unreadCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (data.lastMessage == null)
                    room.type == 1 && room.description == null
                        ? Text(
                            validMembers
                                .map((e) => '@${e.account.name}')
                                .join(', '),
                          )
                        : Text(room.description ?? '')
                  else
                    Row(
                      spacing: 4,
                      children: [
                        Badge(
                          label: Text(data.lastMessage!.sender.account.nick),
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            (data.lastMessage!.content?.isNotEmpty ?? false)
                                ? data.lastMessage!.content!
                                : 'messageNone'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            RelativeTime(
                              context,
                            ).format(data.lastMessage!.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
        loading: () => room.type == 1 && room.description == null
            ? Text(validMembers.map((e) => '@${e.account.name}').join(', '))
            : Text(room.description ?? ''),
        error: (_, _) => room.type == 1 && room.description == null
            ? Text(validMembers.map((e) => '@${e.account.name}').join(', '))
            : Text(room.description ?? ''),
      );
    }

    final isDirect = room.type == 1;

    return ListTile(
      tileColor: isFocused
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
      leading: Badge(
        isLabelVisible: summary.maybeWhen(
          data: (data) => (data?.unreadCount ?? 0) > 0,
          orElse: () => false,
        ),
        child: (isDirect && room.picture?.id == null)
            ? SplitAvatarWidget(
                filesId: validMembers
                    .map((e) => e.account.profile.picture?.id)
                    .toList(),
              )
            : room.picture?.id == null
            ? CircleAvatar(child: Text((room.name ?? 'DM')[0].toUpperCase()))
            : ProfilePictureWidget(
                fileId: room.picture?.id,
              ), // Placeholder for now
      ),
      title: Text(titleText),
      subtitle: buildSubtitle(),
      onTap: onTap,
    );
  }
}
