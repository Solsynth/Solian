import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'room_detail.freezed.dart';
part 'room_detail.g.dart';

class ChatDetailScreen extends HookConsumerWidget {
  final String id;
  const ChatDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(chatroomProvider(id));
    final roomIdentity = ref.watch(chatroomIdentityProvider(id));

    const kNotifyLevelText = [
      'chatNotifyLevelAll',
      'chatNotifyLevelMention',
      'chatNotifyLevelNone',
    ];

    void setNotifyLevel(int level) async {
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/sphere/chat/$id/members/me/notify',
          data: {'notify_level': level},
        );
        ref.invalidate(chatroomIdentityProvider(id));
        if (context.mounted) {
          showSnackBar(
            'chatNotifyLevelUpdated'.tr(args: [kNotifyLevelText[level].tr()]),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void setChatBreak(DateTime until) async {
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/sphere/chat/$id/members/me/notify',
          data: {'break_until': until.toUtc().toIso8601String()},
        );
        ref.invalidate(chatroomProvider(id));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void showNotifyLevelBottomSheet(SnChatMember identity) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder:
            (context) => SheetScaffold(
              height: 320,
              titleText: 'chatNotifyLevel'.tr(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('chatNotifyLevelAll').tr(),
                    subtitle: const Text('chatNotifyLevelDescription').tr(),
                    leading: const Icon(Icons.notifications_active),
                    selected: identity.notify == 0,
                    onTap: () {
                      setNotifyLevel(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('chatNotifyLevelMention').tr(),
                    subtitle: const Text('chatNotifyLevelDescription').tr(),
                    leading: const Icon(Icons.alternate_email),
                    selected: identity.notify == 1,
                    onTap: () {
                      setNotifyLevel(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('chatNotifyLevelNone').tr(),
                    subtitle: const Text('chatNotifyLevelDescription').tr(),
                    leading: const Icon(Icons.notifications_off),
                    selected: identity.notify == 2,
                    onTap: () {
                      setNotifyLevel(2);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
      );
    }

    void showChatBreakDialog() {
      final now = DateTime.now();
      final durationController = TextEditingController();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('chatBreak').tr(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('chatBreakDescription').tr(),
                  const Gap(16),
                  ListTile(
                    title: const Text('Clear').tr(),
                    subtitle: const Text('chatBreakClear').tr(),
                    leading: const Icon(Icons.notifications_active),
                    onTap: () {
                      setChatBreak(now);
                      Navigator.pop(context);
                      if (context.mounted) {
                        showSnackBar('chatBreakCleared'.tr());
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('5m'),
                    subtitle: const Text('chatBreakHour').tr(args: ['5m']),
                    leading: const Icon(Symbols.circle),
                    onTap: () {
                      setChatBreak(now.add(const Duration(minutes: 5)));
                      Navigator.pop(context);
                      if (context.mounted) {
                        showSnackBar('chatBreakSet'.tr(args: ['5m']));
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('10m'),
                    subtitle: const Text('chatBreakHour').tr(args: ['10m']),
                    leading: const Icon(Symbols.circle),
                    onTap: () {
                      setChatBreak(now.add(const Duration(minutes: 10)));
                      Navigator.pop(context);
                      if (context.mounted) {
                        showSnackBar('chatBreakSet'.tr(args: ['10m']));
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('15m'),
                    subtitle: const Text('chatBreakHour').tr(args: ['15m']),
                    leading: const Icon(Symbols.timer_3),
                    onTap: () {
                      setChatBreak(now.add(const Duration(minutes: 15)));
                      Navigator.pop(context);
                      if (context.mounted) {
                        showSnackBar('chatBreakSet'.tr(args: ['15m']));
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('30m'),
                    subtitle: const Text('chatBreakHour').tr(args: ['30m']),
                    leading: const Icon(Symbols.timer),
                    onTap: () {
                      setChatBreak(now.add(const Duration(minutes: 30)));
                      Navigator.pop(context);
                      if (context.mounted) {
                        showSnackBar('chatBreakSet'.tr(args: ['30m']));
                      }
                    },
                  ),
                  const Gap(8),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Custom (minutes)'.tr(),
                      hintText: 'Enter minutes'.tr(),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final minutes = int.tryParse(durationController.text);
                          if (minutes != null && minutes > 0) {
                            setChatBreak(now.add(Duration(minutes: minutes)));
                            Navigator.pop(context);
                            if (context.mounted) {
                              showSnackBar(
                                'chatBreakSet'.tr(args: ['${minutes}m']),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel').tr(),
                ),
              ],
            ),
      );
    }

    const iconShadow = Shadow(
      color: Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return AppScaffold(
      body: roomState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data:
            (currentRoom) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(shadows: [iconShadow]),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        (currentRoom!.type == 1 &&
                                currentRoom.background?.id != null)
                            ? CloudImageWidget(
                              fileId: currentRoom.background!.id,
                            )
                            : (currentRoom.type == 1 &&
                                currentRoom.members!.length == 1 &&
                                currentRoom
                                        .members!
                                        .first
                                        .account
                                        .profile
                                        .background
                                        ?.id !=
                                    null)
                            ? CloudImageWidget(
                              fileId:
                                  currentRoom
                                      .members!
                                      .first
                                      .account
                                      .profile
                                      .background!
                                      .id,
                            )
                            : currentRoom.background?.id != null
                            ? CloudImageWidget(
                              fileId: currentRoom.background!.id,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      (currentRoom.type == 1 && currentRoom.name == null)
                          ? currentRoom.members!
                              .map((e) => e.account.nick)
                              .join(', ')
                          : currentRoom.name!,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.people, shadows: [iconShadow]),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder:
                              (context) => _ChatMemberListSheet(roomId: id),
                        );
                      },
                    ),
                    _ChatRoomActionMenu(id: id, iconShadow: iconShadow),
                    const Gap(8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRoom.description ?? 'descriptionNone'.tr(),
                        style: const TextStyle(fontSize: 16),
                      ).padding(all: 24),
                      const Divider(height: 1),
                      roomIdentity.when(
                        data:
                            (identity) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  leading: const Icon(Symbols.notifications),
                                  trailing: const Icon(Symbols.chevron_right),
                                  title: const Text('chatNotifyLevel').tr(),
                                  subtitle: Text(
                                    kNotifyLevelText[identity!.notify].tr(),
                                  ),
                                  onTap:
                                      () =>
                                          showNotifyLevelBottomSheet(identity),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  leading: const Icon(Icons.timer),
                                  trailing: const Icon(Symbols.chevron_right),
                                  title: const Text('chatBreak').tr(),
                                  subtitle:
                                      identity.breakUntil != null &&
                                              identity.breakUntil!.isAfter(
                                                DateTime.now(),
                                              )
                                          ? Text(
                                            DateFormat(
                                              'yyyy-MM-dd HH:mm',
                                            ).format(identity.breakUntil!),
                                          )
                                          : const Text('chatBreakNone').tr(),
                                  onTap: () => showChatBreakDialog(),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  leading: const Icon(Icons.search),
                                  trailing: const Icon(Symbols.chevron_right),
                                  title: const Text('Search Messages').tr(),
                                  onTap: () {
                                    context.pushNamed('searchMessages', pathParameters: {'id': id});
                                  },
                                ),
                              ],
                            ),
                        error: (_, _) => const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _ChatRoomActionMenu extends HookConsumerWidget {
  final String id;
  final Shadow iconShadow;

  const _ChatRoomActionMenu({required this.id, required this.iconShadow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));

    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder:
          (context) => [
            if ((chatIdentity.value?.role ?? 0) >= 50)
              PopupMenuItem(
                onTap: () {
                  context.pushReplacementNamed(
                    'chatEdit',
                    pathParameters: {'id': id},
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const Gap(12),
                    const Text('editChatRoom').tr(),
                  ],
                ),
              ),
            if ((chatIdentity.value?.role ?? 0) >= 100)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const Gap(12),
                    const Text(
                      'deleteChatRoom',
                      style: TextStyle(color: Colors.red),
                    ).tr(),
                  ],
                ),
                onTap: () {
                  showConfirmAlert(
                    'deleteChatRoomHint'.tr(),
                    'deleteChatRoom'.tr(),
                  ).then((confirm) async {
                    if (confirm) {
                      final client = ref.watch(apiClientProvider);
                      await client.delete('/sphere/chat/$id');
                      ref.invalidate(chatroomsJoinedProvider);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  });
                },
              )
            else
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const Gap(12),
                    Text(
                      'leaveChatRoom',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ).tr(),
                  ],
                ),
                onTap: () {
                  showConfirmAlert(
                    'leaveChatRoomHint'.tr(),
                    'leaveChatRoom'.tr(),
                  ).then((confirm) async {
                    if (confirm) {
                      final client = ref.watch(apiClientProvider);
                      await client.delete('/sphere/chat/$id/members/me');
                      ref.invalidate(chatroomsJoinedProvider);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  });
                },
              ),
          ],
    );
  }
}

@freezed
sealed class ChatRoomMemberState with _$ChatRoomMemberState {
  const factory ChatRoomMemberState({
    required List<SnChatMember> members,
    required bool isLoading,
    required int total,
    String? error,
  }) = _ChatRoomMemberState;
}

final chatMemberStateProvider = StateNotifierProvider.family<
  ChatMemberNotifier,
  ChatRoomMemberState,
  String
>((ref, roomId) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatMemberNotifier(apiClient, roomId);
});

class ChatMemberNotifier extends StateNotifier<ChatRoomMemberState> {
  final String roomId;
  final Dio _apiClient;

  ChatMemberNotifier(this._apiClient, this.roomId)
    : super(const ChatRoomMemberState(members: [], isLoading: false, total: 0));

  Future<void> loadMore({int offset = 0, int take = 20}) async {
    if (state.isLoading) return;
    if (state.total > 0 && state.members.length >= state.total) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get(
        '/sphere/chat/$roomId/members',
        queryParameters: {'offset': offset, 'take': take},
      );

      final total = int.parse(response.headers.value('X-Total') ?? '0');
      final List<dynamic> data = response.data;
      final members = data.map((e) => SnChatMember.fromJson(e)).toList();

      state = state.copyWith(
        members: [...state.members, ...members],
        total: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void reset() {
    state = const ChatRoomMemberState(members: [], isLoading: false, total: 0);
  }
}

@riverpod
class ChatMemberListNotifier extends _$ChatMemberListNotifier
    with CursorPagingNotifierMixin<SnChatMember> {
  @override
  Future<CursorPagingData<SnChatMember>> build(String roomId) {
    return fetch();
  }

  @override
  Future<CursorPagingData<SnChatMember>> fetch({String? cursor}) async {
    final offset = cursor == null ? 0 : int.parse(cursor);
    final take = 20;

    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get(
      '/sphere/chat/$roomId/members',
      queryParameters: {'offset': offset, 'take': take, 'withStatus': true},
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final members = data.map((e) => SnChatMember.fromJson(e)).toList();

    // Calculate next cursor based on total count
    final nextOffset = offset + members.length;
    final String? nextCursor =
        nextOffset < total ? nextOffset.toString() : null;

    return CursorPagingData(
      items: members,
      nextCursor: nextCursor,
      hasMore: members.length < total,
    );
  }
}

class _ChatMemberListSheet extends HookConsumerWidget {
  final String roomId;
  const _ChatMemberListSheet({required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberListProvider = chatMemberListNotifierProvider(roomId);

    // For backward compatibility and to show total count in the header
    final memberState = ref.watch(chatMemberStateProvider(roomId));
    final memberNotifier = ref.read(chatMemberStateProvider(roomId).notifier);

    final roomIdentity = ref.watch(chatroomIdentityProvider(roomId));

    useEffect(() {
      Future(() {
        memberNotifier.loadMore();
      });
      return null;
    }, []);

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.post(
          '/sphere/chat/invites/$roomId',
          data: {'related_user_id': result.id, 'role': 0},
        );
        // Refresh both providers
        memberNotifier.reset();
        await memberNotifier.loadMore();
        ref.invalidate(memberListProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  'members'.plural(memberState.total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.person_add),
                  onPressed: invitePerson,
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
                IconButton(
                  icon: const Icon(Symbols.refresh),
                  onPressed: () {
                    // Refresh both providers
                    memberNotifier.reset();
                    memberNotifier.loadMore();
                    ref.invalidate(memberListProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PagingHelperView(
              provider: memberListProvider,
              futureRefreshable: memberListProvider.future,
              notifierRefreshable: memberListProvider.notifier,
              contentBuilder: (data, widgetCount, endItemView) {
                return ListView.builder(
                  itemCount: widgetCount,
                  itemBuilder: (context, index) {
                    if (index == data.items.length) {
                      return endItemView;
                    }

                    final member = data.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 12),
                      leading: AccountPfcGestureDetector(
                        uname: member.account.name,
                        child: ProfilePictureWidget(
                          fileId: member.account.profile.picture?.id,
                        ),
                      ),
                      title: Row(
                        spacing: 6,
                        children: [
                          Flexible(child: Text(member.account.nick)),
                          if (member.status != null)
                            AccountStatusLabel(status: member.status!),
                          if (member.joinedAt == null)
                            const Icon(Symbols.pending_actions, size: 20),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            member.role >= 100
                                ? 'permissionOwner'
                                : member.role >= 50
                                ? 'permissionModerator'
                                : 'permissionMember',
                          ).tr(),
                          Text('·').bold().padding(horizontal: 6),
                          Expanded(child: Text("@${member.account.name}")),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((roomIdentity.value?.role ?? 0) >= 50)
                            IconButton(
                              icon: const Icon(Symbols.edit),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder:
                                      (context) => _ChatMemberRoleSheet(
                                        roomId: roomId,
                                        member: member,
                                      ),
                                ).then((value) {
                                  if (value != null) {
                                    // Refresh both providers
                                    memberNotifier.reset();
                                    memberNotifier.loadMore();
                                    ref.invalidate(memberListProvider);
                                  }
                                });
                              },
                            ),
                          if ((roomIdentity.value?.role ?? 0) >= 50)
                            IconButton(
                              icon: const Icon(Symbols.delete),
                              onPressed: () {
                                showConfirmAlert(
                                  'removeChatMemberHint'.tr(),
                                  'removeChatMember'.tr(),
                                ).then((confirm) async {
                                  if (confirm != true) return;
                                  try {
                                    final apiClient = ref.watch(
                                      apiClientProvider,
                                    );
                                    await apiClient.delete(
                                      '/sphere/chat/$roomId/members/${member.accountId}',
                                    );
                                    // Refresh both providers
                                    memberNotifier.reset();
                                    memberNotifier.loadMore();
                                    ref.invalidate(memberListProvider);
                                  } catch (err) {
                                    showErrorAlert(err);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMemberRoleSheet extends HookConsumerWidget {
  final String roomId;
  final SnChatMember member;

  const _ChatMemberRoleSheet({required this.roomId, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleController = useTextEditingController(
      text: member.role.toString(),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Text(
                    'memberRoleEdit'.tr(args: [member.account.name]),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Autocomplete<int>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const [100, 50, 0];
                    }
                    final int? value = int.tryParse(textEditingValue.text);
                    if (value == null) return const [100, 50, 0];
                    return [100, 50, 0].where(
                      (option) =>
                          option.toString().contains(textEditingValue.text),
                    );
                  },
                  onSelected: (int selection) {
                    roleController.text = selection.toString();
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'memberRole'.tr(),
                        helperText: 'memberRoleHint'.tr(),
                      ),
                      onTapOutside: (event) => focusNode.unfocus(),
                    );
                  },
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final newRole = int.parse(roleController.text);
                      if (newRole < 0 || newRole > 100) {
                        throw 'Role must be between 0 and 100';
                      }

                      final apiClient = ref.read(apiClientProvider);
                      await apiClient.patch(
                        '/sphere/chat/$roomId/members/${member.accountId}/role',
                        data: newRole,
                      );

                      if (context.mounted) Navigator.pop(context, true);
                    } catch (err) {
                      showErrorAlert(err);
                    }
                  },
                  icon: const Icon(Symbols.save),
                  label: const Text('saveChanges').tr(),
                ),
              ],
            ).padding(vertical: 16, horizontal: 24),
          ],
        ),
      ),
    );
  }
}
