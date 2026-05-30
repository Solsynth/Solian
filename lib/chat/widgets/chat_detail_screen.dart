import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/widgets/chat_room_form.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/core/database.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:island/core/network.dart';
import 'package:island/e2ee/mls_client.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_detail_screen.freezed.dart';
part 'chat_detail_screen.g.dart';

@riverpod
Future<int> totalMessagesCount(Ref ref, String roomId) async {
  final database = ref.watch(databaseProvider);
  return database.getTotalMessagesForRoom(roomId);
}

class _ChatBasisWidget extends HookConsumerWidget {
  final SnChatRoom data;
  final String roomId;

  const _ChatBasisWidget({required this.data, required this.roomId});

  String _getFirstLine(String text) {
    final lines = text.split('\n');
    if (lines.isEmpty) return '';
    return lines.first.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDescExpanded = useState(false);
    final theme = Theme.of(context);
    final roomIdentity = ref.watch(chatRoomIdentityProvider(roomId));

    // Get background image
    Widget backgroundWidget;
    if (data.type == 1 && data.background != null) {
      backgroundWidget = CloudImageWidget(
        file: data.background!,
        fit: BoxFit.cover,
      );
    } else if (data.type == 1 &&
        data.members?.length == 1 &&
        data.members!.first.account.profile.background?.id != null) {
      backgroundWidget = CloudImageWidget(
        file: data.members!.first.account.profile.background!,
        fit: BoxFit.cover,
      );
    } else if (data.background != null) {
      backgroundWidget = CloudImageWidget(
        file: data.background!,
        fit: BoxFit.cover,
      );
    } else {
      backgroundWidget = Container(color: theme.colorScheme.primaryContainer);
    }

    // Get chat name
    final chatName = (data.type == 1 && data.name == null)
        ? data.members?.map((e) => e.account.nick).join(', ') ?? 'Chat'
        : data.name ?? 'Chat';

    // Get chat picture
    IDisplayableCloudFile? pictureFile;
    if (data.picture != null) {
      pictureFile = data.picture;
    } else if (data.type == 1 && data.members?.isNotEmpty == true) {
      pictureFile = data.members!.first.account.profile.picture;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: backgroundWidget,
                ),
              ),
              Positioned(
                bottom: -24,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                  ),
                  child: ProfilePictureWidget(
                    file: pictureFile,
                    radius: 32,
                    fallbackIcon: data.type == 1
                        ? Symbols.person
                        : Symbols.group,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chatName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!data.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'private',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                      ),
                  ],
                ),
                const Gap(4),
                if (data.description?.isNotEmpty == true) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isDescExpanded.value
                              ? Text(
                                  data.description!,
                                  key: const ValueKey('expanded'),
                                )
                              : Text(
                                  _getFirstLine(data.description!),
                                  key: const ValueKey('collapsed'),
                                ),
                        ).alignment(Alignment.centerLeft),
                      ),
                      if (data.description!.contains('\n'))
                        InkWell(
                          onTap: () =>
                              isDescExpanded.value = !isDescExpanded.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              isDescExpanded.value
                                  ? 'collapse'.tr()
                                  : 'expand'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'descriptionNone'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                roomIdentity.when(
                  data: (identity) {
                    if (identity == null) {
                      // Not joined - show join button
                      return FilledButton.icon(
                        onPressed: () async {
                          try {
                            final client = ref.read(apiClientProvider);
                            await client.post('/messager/chat/$roomId/join');
                            ref.invalidate(chatRoomIdentityProvider(roomId));
                            ref.invalidate(chatRoomProvider(roomId));
                            ref.invalidate(chatRoomJoinedProvider);
                            showSnackBar('chatJoinSuccess'.tr());
                          } catch (err) {
                            showErrorAlert(err);
                          }
                        },
                        icon: const Icon(Symbols.add),
                        label: Text('chatJoin'.tr()),
                        style: ButtonStyle(
                          visualDensity: VisualDensity(vertical: -2),
                        ),
                      ).padding(top: 12);
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ).padding(top: 12),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class ChatDetailScreen extends HookConsumerWidget {
  final String id;
  const ChatDetailScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(chatRoomProvider(id));
    final roomIdentity = ref.watch(chatRoomIdentityProvider(id));
    final totalMessages = ref.watch(totalMessagesCountProvider(id));

    // Local state for pinned status to provide immediate UI feedback
    final isPinned = useState<bool?>(null);

    // Initialize pinned state from database
    useEffect(() {
      final db = ref.read(databaseProvider);
      db.getChatRoomById(id).then((room) {
        isPinned.value = room?.isPinned ?? false;
      });
      return null;
    }, [id]);

    const kNotifyLevelText = [
      'chatNotifyLevelAll',
      'chatNotifyLevelMention',
      'chatNotifyLevelNone',
    ];

    void setNotifyLevel(int level) async {
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/messager/chat/$id/members/me/notify',
          data: {'notify_level': level},
        );
        ref.invalidate(chatRoomIdentityProvider(id));
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
          '/messager/chat/$id/members/me/notify',
          data: {'break_until': until.toUtc().toIso8601String()},
        );
        ref.invalidate(chatRoomIdentityProvider(id));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void showNotifyLevelBottomSheet(SnChatMember identity) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => SheetScaffold(
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
        builder: (context) => AlertDialog(
          title: const Text('chatBreak').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('chatBreakDescription').tr(),
              const Gap(16),
              ListTile(
                title: const Text('chatBreakClearButton').tr(),
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
                title: const Text('chatBreak5m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak5m'.tr()]),
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
                title: const Text('chatBreak10m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak10m'.tr()]),
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
                title: const Text('chatBreak15m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak15m'.tr()]),
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
                title: const Text('chatBreak30m').tr(),
                subtitle: const Text(
                  'chatBreakHour',
                ).tr(args: ['chatBreak30m'.tr()]),
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
                  labelText: 'chatBreakCustomMinutes'.tr(),
                  hintText: 'chatBreakEnterMinutes'.tr(),

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
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
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

    return AppScaffold(
      appBar: AppBar(
        leading: AutoLeadingButton(),
        title: roomState.when(
          data: (currentRoom) => Text(
            (currentRoom?.type == 1 && currentRoom?.name == null)
                ? currentRoom?.members?.map((e) => e.account.nick).join(', ') ??
                      'Chat'
                : currentRoom?.name ?? 'Chat',
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => _ChatMemberListSheet(roomId: id),
              );
            },
          ),
          _ChatRoomActionMenu(id: id),
          const Gap(8),
        ],
      ),
      body: roomState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('errorGeneric'.tr(args: [error.toString()]))),
        data: (currentRoom) => CustomScrollView(
          slivers: [
            const SliverGap(12),
            SliverToBoxAdapter(
              child: _ChatBasisWidget(
                data: currentRoom!,
                roomId: id,
              ).padding(horizontal: 12),
            ),
            const SliverGap(12),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pin/Unpin Switch
                  if (isPinned.value != null)
                    SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      secondary: Icon(
                        Symbols.push_pin,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: const Text('pinChatRoom').tr(),
                      subtitle: const Text('pinChatRoomDescription').tr(),
                      value: isPinned.value!,
                      onChanged: (value) async {
                        // Update local state immediately for instant UI feedback
                        isPinned.value = value;
                        final db = ref.read(databaseProvider);
                        await db.toggleChatRoomPinned(id);
                        // Re-verify the state from database in case of error
                        final room = await db.getChatRoomById(id);
                        final actualPinned = room?.isPinned ?? false;
                        if (actualPinned != value) {
                          // Revert if database operation failed
                          isPinned.value = actualPinned;
                        }
                        showSnackBar(
                          value
                              ? 'chatRoomPinned'.tr()
                              : 'chatRoomUnpinned'.tr(),
                        );
                      },
                    ),
                  roomIdentity.when(
                    data: (identity) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (identity != null) ...[
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            leading: const Icon(Symbols.edit),
                            trailing: const Icon(Symbols.chevron_right),
                            title: const Text('nickname').tr(),
                            subtitle: Text(
                              identity.nick?.isNotEmpty ?? false
                                  ? identity.nick!
                                  : 'No chat-specific nick set yet.',
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                builder: (_) => _ChatIdentityEditorSheet(
                                  roomId: identity.chatRoomId,
                                  identity: identity,
                                ),
                              );
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            leading: const Icon(Symbols.notifications),
                            trailing: const Icon(Symbols.chevron_right),
                            title: const Text('chatNotifyLevel').tr(),
                            subtitle: Text(
                              kNotifyLevelText[identity.notify].tr(),
                            ),
                            onTap: () => showNotifyLevelBottomSheet(identity),
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
                                    identity.breakUntil!.isAfter(DateTime.now())
                                ? Text(
                                    DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(identity.breakUntil!),
                                  )
                                : const Text('chatBreakNone').tr(),
                            onTap: () => showChatBreakDialog(),
                          ),
                        ],
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 24),
                          leading: const Icon(Icons.search),
                          trailing: const Icon(Symbols.chevron_right),
                          title: const Text('searchMessages').tr(),
                          subtitle: totalMessages.when(
                            data: (count) => Text(
                              'messagesCount'.tr(args: [count.toString()]),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (err, stack) =>
                                Text('errorGeneric'.tr(args: [err.toString()])),
                          ),
                          onTap: () async {
                            final result = await context.router.push(
                              SearchMessagesRoute(roomId: id),
                            );
                            if (result is SearchMessagesResult) {
                              // Navigate back to room screen with message to jump to
                              if (context.mounted) {
                                context.pop(result);
                              }
                            }
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

  const _ChatRoomActionMenu({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatIdentity = ref.watch(chatRoomIdentityProvider(id));
    final chatRoom = ref.watch(chatRoomProvider(id));

    final isManagable =
        chatIdentity.value?.accountId == chatRoom.value?.accountId ||
        chatRoom.value?.type == 1;
    final canEnableMls =
        isManagable && (chatRoom.value?.encryptionMode ?? 0) == 0;
    final hasMls = !canEnableMls;

    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (isManagable)
          PopupMenuItem(
            onTap: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (context) => EditChatScreen(id: id),
              ).then((value) {
                if (value != null) {
                  // Invalidate to refresh room data after edit
                  ref.invalidate(chatMemberListProvider(id));
                }
              });
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
        if (canEnableMls)
          PopupMenuItem(
            onTap: () async {
              final confirmed = await showConfirmAlert(
                'Enable MLS encryption for this chat room? This cannot be undone.',
                'Enable MLS',
              );
              if (!confirmed) return;

              try {
                final client = ref.watch(apiClientProvider);
                await client.post('/messager/chat/$id/mls/enable');
                ref.invalidate(chatRoomProvider(id));
                ref.invalidate(chatRoomJoinedProvider);
                if (context.mounted) {
                  showSnackBar('MLS enabled successfully.');
                }
              } catch (err) {
                showErrorAlert(err);
              }
            },
            child: Row(
              children: [
                Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                const Gap(12),
                const Text('Enable MLS'),
              ],
            ),
          ),
        if (hasMls)
          PopupMenuItem(
            onTap: () async {
              final confirmed = await showConfirmAlert(
                'Reset E2EE encryption for this chat room? All members will need to re-join.',
                'Reset E2EE',
              );
              if (!confirmed) return;

              final mlsGroupId = chatRoom.value?.mlsGroupId;
              if (mlsGroupId == null) {
                if (context.mounted) {
                  showErrorAlert('Room has no MLS group ID');
                }
                return;
              }

              try {
                final mlsClient = ref.read(mlsClientProvider);
                final currentAccountId = chatIdentity.value?.accountId;
                if (currentAccountId == null) {
                  if (context.mounted) {
                    showErrorAlert('Unable to get current account ID');
                  }
                  return;
                }
                await mlsClient.resetAndRebootstrapGroup(
                  roomId: id,
                  mlsGroupId: mlsGroupId,
                  creatorAccountId: currentAccountId,
                );
                ref.invalidate(chatRoomProvider(id));
                if (context.mounted) {
                  showSnackBar('E2EE reset successfully.');
                }
              } catch (err) {
                showErrorAlert(err);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(12),
                const Text('Reset E2EE'),
              ],
            ),
          ),
        if (hasMls)
          PopupMenuItem(
            onTap: () async {
              final mlsGroupId = chatRoom.value?.mlsGroupId;
              if (mlsGroupId == null) {
                if (context.mounted) {
                  showErrorAlert('Room has no MLS group ID');
                }
                return;
              }

              try {
                final mlsClient = ref.read(mlsClientProvider);
                await mlsClient.groupManager.uploadGroupInfo(mlsGroupId);
                ref.invalidate(chatRoomMlsReadinessProvider(id));
                if (context.mounted) {
                  showSnackBar('Group info uploaded successfully.');
                }
              } catch (err) {
                showErrorAlert(err);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(12),
                const Text('Upload Group Info'),
              ],
            ),
          ),
        if (isManagable)
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
                isDanger: true,
              ).then((confirm) async {
                if (confirm) {
                  final client = ref.watch(apiClientProvider);
                  await client.delete('/messager/chat/$id');
                  ref.invalidate(chatRoomJoinedProvider);
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                  await client.delete('/messager/chat/$id/members/me');
                  ref.invalidate(chatRoomJoinedProvider);
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

final chatMemberListProvider = AsyncNotifierProvider.autoDispose.family(
  ChatMemberListNotifier.new,
);

final mlsUserReadinessProvider = FutureProvider.autoDispose
    .family<Map<String, MlsUserReadyStatus>, List<String>>((
      ref,
      accountIds,
    ) async {
      if (accountIds.isEmpty) return {};

      final mlsClient = ref.watch(mlsClientProvider);
      final results = await mlsClient.identityManager.checkUsersBatchReady(
        accountIds,
      );

      final readinessMap = <String, MlsUserReadyStatus>{};
      for (final result in results) {
        final accountId = result['account_id'] as String?;
        final isReady = result['is_ready'] as bool? ?? false;
        final availableKeyPackages =
            result['available_key_packages'] as int? ?? 0;

        if (accountId != null) {
          readinessMap[accountId] = MlsUserReadyStatus(
            accountId: accountId,
            isReady: isReady,
            availableKeyPackages: availableKeyPackages,
          );
        }
      }
      return readinessMap;
    });

final chatRoomMlsReadinessProvider = FutureProvider.autoDispose
    .family<Map<String, MlsUserReadyStatus>, String>((ref, roomId) async {
      final memberListState = await ref.watch(
        chatMemberListProvider(roomId).future,
      );
      final memberList = memberListState.items;
      final accountIds = memberList.map((m) => m.accountId).toList();
      if (accountIds.isEmpty) return {};

      final mlsClient = ref.watch(mlsClientProvider);
      final results = await mlsClient.identityManager.checkUsersBatchReady(
        accountIds,
      );

      final readinessMap = <String, MlsUserReadyStatus>{};
      for (final result in results) {
        final accountId = result['account_id'] as String?;
        final isReady = result['is_ready'] as bool? ?? false;
        final availableKeyPackages =
            result['available_key_packages'] as int? ?? 0;

        if (accountId != null) {
          readinessMap[accountId] = MlsUserReadyStatus(
            accountId: accountId,
            isReady: isReady,
            availableKeyPackages: availableKeyPackages,
          );
        }
      }
      return readinessMap;
    });

class MlsUserReadyStatus {
  final String accountId;
  final bool isReady;
  final int availableKeyPackages;

  MlsUserReadyStatus({
    required this.accountId,
    required this.isReady,
    required this.availableKeyPackages,
  });
}

class ChatMemberListNotifier
    extends AsyncNotifier<PaginationState<SnChatMember>>
    with AsyncPaginationController<SnChatMember> {
  static const pageSize = 20;

  final String arg;
  ChatMemberListNotifier(this.arg);

  @override
  Future<List<SnChatMember>> fetch() async {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get(
      '/messager/chat/$arg/members',
      queryParameters: {
        'offset': fetchedCount.toString(),
        'take': pageSize,
        'withStatus': true,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final members = response.data
        .map((e) => SnChatMember.fromJson(e))
        .cast<SnChatMember>()
        .toList();

    return members;
  }
}

class _ChatMemberListSheet extends HookConsumerWidget {
  final String roomId;
  const _ChatMemberListSheet({required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(chatMemberListProvider(roomId));
    final memberNotifier = ref.watch(chatMemberListProvider(roomId).notifier);

    final chatRoom = ref.watch(chatRoomProvider(roomId));

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
          '/messager/chat/invites/$roomId',
          data: {'related_user_id': result.id, 'role': 0},
        );

        final mlsGroupId = chatRoom.value?.mlsGroupId;
        final isEncrypted = (chatRoom.value?.encryptionMode ?? 0) == 3;
        if (isEncrypted && mlsGroupId != null) {
          try {
            final padlockClient = ref.read(padlockApiClientProvider);
            final readyResponse = await padlockClient.get(
              '/e2ee/mls/users/${result.id}/ready',
              options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
            );
            final isReady = readyResponse.data['is_ready'] as bool? ?? false;

            if (isReady) {
              final mlsClient = ref.read(mlsClientProvider);
              await mlsClient.groupManager.addMembersAndFanoutWelcome(
                mlsGroupId,
                [result.id],
                chatRoomId: roomId,
              );
            }
          } catch (e) {
            Logger.root.warning('Failed to fanout welcome to new member: $e');
          }
        }

        memberNotifier.refresh();
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
                  'members'.plural(memberState.value?.totalCount ?? 0),
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
                    memberNotifier.refresh();
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
            child: PaginationList(
              provider: chatMemberListProvider(roomId),
              notifier: chatMemberListProvider(roomId).notifier,
              itemBuilder: (context, idx, member) {
                final readinessAsync = ref.watch(
                  chatRoomMlsReadinessProvider(roomId),
                );
                final isE2eeReady = readinessAsync.maybeWhen(
                  data: (data) => data[member.accountId]?.isReady ?? false,
                  orElse: () => false,
                );
                return _MemberListTile(
                  member: member,
                  roomId: roomId,
                  isE2eeReady: isE2eeReady,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberListTile extends HookConsumerWidget {
  final SnChatMember member;
  final String roomId;
  final bool isE2eeReady;

  const _MemberListTile({
    required this.member,
    required this.roomId,
    this.isE2eeReady = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomIdentity = ref.watch(chatRoomIdentityProvider(roomId));
    final chatRoom = ref.watch(chatRoomProvider(roomId));

    final isManagable =
        chatRoom.value?.accountId == roomIdentity.value?.accountId ||
        chatRoom.value?.type == 1;
    final memberNotifier = ref.watch(chatMemberListProvider(roomId).notifier);

    return ListTile(
      contentPadding: EdgeInsets.only(left: 16, right: 12),
      leading: AccountPfcRegion(
        uname: member.account.name,
        child: ProfilePictureWidget(file: member.account.profile.picture),
      ),
      title: Row(
        spacing: 6,
        children: [
          Flexible(child: Text(member.account.nick)),
          if (member.status != null)
            Flexible(
              child: AccountStatusLabel(
                status: member.status!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (member.realmLabel != null)
            RealmLabelWidget(label: member.realmLabel!, fontSize: 10),
          if (member.joinedAt == null)
            const Icon(Symbols.pending_actions, size: 20),
          if (isE2eeReady)
            Tooltip(
              message: 'E2EE Ready',
              child: Icon(
                Symbols.lock,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          else
            Tooltip(
              message: 'E2EE Not Available',
              child: Icon(
                Symbols.lock_open,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
      subtitle: Text("@${member.account.name}"),
      trailing: IconButton(
        icon: const Icon(Symbols.more_horiz),
        onPressed: () {
          showChatRoomMemberCard(
            context,
            roomId: roomId,
            member: member,
            canModerate: isManagable,
            onUpdated: () async {
              memberNotifier.refresh();
            },
          );
        },
      ),
      onTap: () {
        showChatRoomMemberCard(
          context,
          roomId: roomId,
          member: member,
          canModerate: isManagable,
          onUpdated: () async {
            memberNotifier.refresh();
          },
        );
      },
    );
  }
}

class _ChatIdentityEditorSheet extends HookConsumerWidget {
  const _ChatIdentityEditorSheet({
    required this.roomId,
    required this.identity,
  });

  final String roomId;
  final SnChatMember identity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickController = useTextEditingController(text: identity.nick ?? '');

    return SheetScaffold(
      heightFactor: 0.4,
      titleText: 'Edit Chat Identity',
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nickController,
              maxLength: 1024,
              decoration: InputDecoration(labelText: 'nickname'.tr()),
            ),
            const Gap(16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      try {
                        final apiClient = ref.read(apiClientProvider);
                        await apiClient.patch(
                          '/messager/chat/$roomId/members/me/profile',
                          data: {
                            'nick': nickController.text.trim().isEmpty
                                ? null
                                : nickController.text.trim(),
                          },
                        );
                        ref.invalidate(chatRoomIdentityProvider(roomId));
                        ref.invalidate(chatMemberListProvider(roomId));
                        if (context.mounted) {
                          showSnackBar('saveChanges'.tr());
                          Navigator.pop(context, true);
                        }
                      } catch (err) {
                        showErrorAlert(err);
                      }
                    },
                    icon: const Icon(Symbols.save),
                    label: const Text('saveChanges').tr(),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: identity.nick?.isNotEmpty != true
                      ? null
                      : () async {
                          final confirm = await showConfirmAlert(
                            'clearChatIdentityHint'.tr(),
                            'clearChatIdentity'.tr(),
                            isDanger: true,
                          );
                          if (confirm != true) return;
                          try {
                            final apiClient = ref.read(apiClientProvider);
                            await apiClient.delete(
                              '/messager/chat/$roomId/members/me/profile',
                            );
                            ref.invalidate(chatRoomIdentityProvider(roomId));
                            ref.invalidate(chatMemberListProvider(roomId));
                            if (context.mounted) {
                              showSnackBar('cleared'.tr());
                              Navigator.pop(context, true);
                            }
                          } catch (err) {
                            showErrorAlert(err);
                          }
                        },
                  icon: const Icon(Symbols.delete_forever),
                  label: const Text('clear').tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
