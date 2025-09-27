import 'package:collection/collection.dart';
import 'package:croppy/croppy.dart' hide cropImage;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/pods/chat/chat_summary.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/services/file.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/realm/realm_selection_dropdown.dart';
import 'package:island/widgets/response.dart';
import 'package:island/screens/tabs.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'chat.g.dart';

class ChatRoomListTile extends HookConsumerWidget {
  final SnChatRoom room;
  final bool isDirect;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ChatRoomListTile({
    super.key,
    required this.room,
    this.isDirect = false,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref
        .watch(chatSummaryProvider)
        .whenData((summaries) => summaries[room.id]);

    Widget buildSubtitle() {
      if (subtitle != null) return subtitle!;

      return summary.when(
        data: (data) {
          if (data == null) {
            return isDirect && room.description == null
                ? Text(
                  room.members!.map((e) => '@${e.account.name}').join(', '),
                  maxLines: 1,
                )
                : Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1);
          }

          return Column(
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
                Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1)
              else
                Row(
                  spacing: 4,
                  children: [
                    Badge(
                      label: Text(data.lastMessage!.sender.account.nick),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
          );
        },
        loading: () => const SizedBox.shrink(),
        error:
            (_, _) =>
                isDirect && room.description == null
                    ? Text(
                      room.members!.map((e) => '@${e.account.name}').join(', '),
                      maxLines: 1,
                    )
                    : Text(
                      room.description ?? 'descriptionNone'.tr(),
                      maxLines: 1,
                    ),
      );
    }

    return ListTile(
      leading: Badge(
        isLabelVisible: summary.when(
          data: (data) => (data?.unreadCount ?? 0) > 0,
          loading: () => false,
          error: (_, _) => false,
        ),
        child:
            (isDirect && room.picture?.id == null)
                ? SplitAvatarWidget(
                  filesId:
                      room.members!
                          .map((e) => e.account.profile.picture?.id)
                          .toList(),
                )
                : room.picture?.id == null
                ? CircleAvatar(child: Text(room.name![0].toUpperCase()))
                : ProfilePictureWidget(fileId: room.picture?.id),
      ),
      title: Text(
        (isDirect && room.name == null)
            ? room.members!.map((e) => e.account.nick).join(', ')
            : room.name ?? '',
      ),
      subtitle: buildSubtitle(),
      trailing: trailing, // Add this line
      onTap: () async {
        // Clear unread count if there are unread messages
        ref.read(chatSummaryProvider.future).then((summary) {
          if ((summary[room.id]?.unreadCount ?? 0) > 0) {
            ref.read(chatSummaryProvider.notifier).clearUnreadCount(room.id);
          }
        });
        onTap?.call();
      },
    );
  }
}

@riverpod
Future<List<SnChatRoom>> chatroomsJoined(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/chat');
  return resp.data
      .map((e) => SnChatRoom.fromJson(e))
      .cast<SnChatRoom>()
      .toList();
}

class ChatShellScreen extends HookConsumerWidget {
  final Widget child;
  const ChatShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            Flexible(flex: 2, child: ChatListScreen(isAside: true)),
            const VerticalDivider(width: 1),
            Flexible(flex: 4, child: child),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: child);
  }
}

class ChatListScreen extends HookConsumerWidget {
  final bool isAside;
  const ChatListScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

    final chats = ref.watch(chatroomsJoinedProvider);
    final chatInvites = ref.watch(chatroomInvitesProvider);
    final tabController = useTabController(initialLength: 3);
    final selectedTab = useState(
      0,
    ); // 0 for All, 1 for Direct Messages, 2 for Group Chats

    final callState = ref.watch(callNotifierProvider);

    useEffect(() {
      tabController.addListener(() {
        selectedTab.value = tabController.index;
      });
      return null;
    }, [tabController]);

    Future<void> createDirectMessage() async {
      final result = await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      final client = ref.read(apiClientProvider);
      try {
        await client.post(
          '/sphere/chat/direct',
          data: {'related_user_id': result.id},
        );
        ref.invalidate(chatroomsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
      appBar: AppBar(
        title: const Text('chat').tr(),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'chatTabAll'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'chatTabDirect'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'chatTabGroup'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(
                chatInvites.when(
                  data: (invites) => invites.length.toString(),
                  error: (_, _) => '0',
                  loading: () => '0',
                ),
              ),
              isLabelVisible: chatInvites.when(
                data: (invites) => invites.isNotEmpty,
                error: (_, _) => false,
                loading: () => false,
              ),
              child: const Icon(Symbols.email),
            ),
            onPressed: () {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => const _ChatInvitesSheet(),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            builder:
                (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: const Text('createChatRoom').tr(),
                      leading: const Icon(Symbols.add),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed('chatNew').then((value) {
                          if (value != null) {
                            ref.invalidate(chatroomsJoinedProvider);
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('createDirectMessage').tr(),
                      leading: const Icon(Symbols.person),
                      onTap: () {
                        Navigator.pop(context);
                        createDirectMessage();
                      },
                    ),
                    Gap(MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
          );
        },
        child: const Icon(Symbols.add),
      ),
      floatingActionButtonLocation: TabbedFabLocation(context),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final summaryState = ref.watch(chatSummaryProvider);
              return summaryState.maybeWhen(
                loading:
                    () => const LinearProgressIndicator(
                      minHeight: 2,
                      borderRadius: BorderRadius.zero,
                    ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          Expanded(
            child: chats.when(
              data:
                  (items) => RefreshIndicator(
                    onRefresh:
                        () => Future.sync(() {
                          ref.invalidate(chatroomsJoinedProvider);
                        }),
                    child: ListView.builder(
                      padding: getTabbedPadding(
                        context,
                        bottom: callState.isConnected ? 96 : null,
                      ),
                      itemCount:
                          items
                              .where(
                                (item) =>
                                    selectedTab.value == 0 ||
                                    (selectedTab.value == 1 &&
                                        item.type == 1) ||
                                    (selectedTab.value == 2 && item.type != 1),
                              )
                              .length,
                      itemBuilder: (context, index) {
                        final filteredItems =
                            items
                                .where(
                                  (item) =>
                                      selectedTab.value == 0 ||
                                      (selectedTab.value == 1 &&
                                          item.type == 1) ||
                                      (selectedTab.value == 2 &&
                                          item.type != 1),
                                )
                                .toList();
                        final item = filteredItems[index];
                        return ChatRoomListTile(
                          room: item,
                          isDirect: item.type == 1,
                          onTap: () {
                            context.pushNamed(
                              'chatRoom',
                              pathParameters: {'id': item.id},
                            );
                          },
                        );
                      },
                    ),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => ResponseErrorWidget(
                    error: error,
                    onRetry: () {
                      ref.invalidate(chatroomsJoinedProvider);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

@riverpod
Future<SnChatRoom?> chatroom(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/$identifier');
    return SnChatRoom.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null; // Chat room not found
    }
    rethrow; // Rethrow other errors
  }
}

@riverpod
Future<SnChatMember?> chatroomIdentity(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  try {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/$identifier/members/me');
    return SnChatMember.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null; // Chat member not found
    }
    rethrow; // Rethrow other errors
  }
}

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditChatScreen();
  }
}

class EditChatScreen extends HookConsumerWidget {
  final String? id;
  const EditChatScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final submitting = useState(false);

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);
    final isPublic = useState(true);
    final isCommunity = useState(false);

    final chat = ref.watch(chatroomProvider(id));

    final joinedRealms = ref.watch(realmsJoinedProvider);
    final currentRealm = useState<SnRealm?>(null);

    useEffect(() {
      if (chat.value != null) {
        nameController.text = chat.value!.name ?? '';
        descriptionController.text = chat.value!.description ?? '';
        picture.value = chat.value!.picture;
        background.value = chat.value!.background;
        isPublic.value = chat.value!.isPublic;
        isCommunity.value = chat.value!.isCommunity;
        currentRealm.value = joinedRealms.value?.firstWhereOrNull(
          (realm) => realm.id == chat.value!.realmId,
        );
      }
      return;
    }, [chat, joinedRealms]);

    void setPicture(String position) async {
      showLoadingModal(context);
      var result = await ref
          .read(imagePickerProvider)
          .pickImage(source: ImageSource.gallery);
      if (result == null) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }
      if (!context.mounted) return;
      hideLoadingModal(context);
      result = await cropImage(
        context,
        image: result,
        allowedAspectRatios: [
          if (position == 'background')
            const CropAspectRatio(height: 7, width: 16)
          else
            const CropAspectRatio(height: 1, width: 1),
        ],
      );
      if (result == null) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }
      if (!context.mounted) return;
      showLoadingModal(context);

      submitting.value = true;
      try {
        final baseUrl = ref.watch(serverUrlProvider);
        final token = await getToken(ref.watch(tokenProvider));
        if (token == null) throw ArgumentError('Token is null');
        final cloudFile =
            await putFileToCloud(
              fileData: UniversalFile(
                data: result,
                type: UniversalFileType.image,
              ),
              atk: token,
              baseUrl: baseUrl,
              filename: result.name,
              mimetype: result.mimeType ?? 'image/jpeg',
            ).future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        switch (position) {
          case 'picture':
            picture.value = cloudFile;
          case 'background':
            background.value = cloudFile;
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
        submitting.value = false;
      }
    }

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          id == null ? '/sphere/chat' : '/sphere/chat/$id',
          data: {
            'name': nameController.text,
            'description': descriptionController.text,
            'background_id': background.value?.id,
            'picture_id': picture.value?.id,
            'realm_id': currentRealm.value?.id,
            'is_public': isPublic.value,
            'is_community': isCommunity.value,
          },
          options: Options(method: id == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.pop(SnChatRoom.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(id == null ? 'createChatRoom' : 'editChatRoom').tr(),
        leading: const PageBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RealmSelectionDropdown(
              value: currentRealm.value,
              realms: joinedRealms.when(
                data: (realms) => realms,
                loading: () => [],
                error: (_, _) => [],
              ),
              onChanged: (SnRealm? value) {
                currentRealm.value = value;
              },
              isLoading: joinedRealms.isLoading,
              error: joinedRealms.error?.toString(),
            ),
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child:
                          background.value != null
                              ? CloudFileWidget(
                                item: background.value!,
                                fit: BoxFit.cover,
                              )
                              : const SizedBox.shrink(),
                    ),
                    onTap: () {
                      setPicture('background');
                    },
                  ),
                  Positioned(
                    left: 20,
                    bottom: -32,
                    child: GestureDetector(
                      child: ProfilePictureWidget(
                        fileId: picture.value?.id,
                        radius: 40,
                        fallbackIcon: Symbols.group,
                      ),
                      onTap: () {
                        setPicture('picture');
                      },
                    ),
                  ),
                ],
              ),
            ).padding(bottom: 32),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: null,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          secondary: const Icon(Symbols.public),
                          title: Text('publicChat').tr(),
                          subtitle: Text('publicChatDescription').tr(),
                          value: isPublic.value,
                          onChanged: (value) {
                            isPublic.value = value ?? true;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        CheckboxListTile(
                          secondary: const Icon(Symbols.travel_explore),
                          title: Text('communityChat').tr(),
                          subtitle: Text('communityChatDescription').tr(),
                          value: isCommunity.value,
                          onChanged: (value) {
                            isCommunity.value = value ?? false;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: submitting.value ? null : performAction,
                      label: const Text('Save'),
                      icon: const Icon(Symbols.save),
                    ),
                  ),
                ],
              ).padding(all: 24),
            ),
          ],
        ),
      ),
    );
  }
}

@riverpod
Future<List<SnChatMember>> chatroomInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/chat/invites');
  return resp.data
      .map((e) => SnChatMember.fromJson(e))
      .cast<SnChatMember>()
      .toList();
}

class _ChatInvitesSheet extends HookConsumerWidget {
  const _ChatInvitesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(chatroomInvitesProvider);

    Future<void> acceptInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/sphere/chat/invites/${invite.chatRoom!.id}/accept');
        ref.invalidate(chatroomInvitesProvider);
        ref.invalidate(chatroomsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/sphere/chat/invites/${invite.chatRoom!.id}/decline',
        );
        ref.invalidate(chatroomInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'invites'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(realmInvitesProvider);
          },
        ),
      ],
      child: invites.when(
        data:
            (items) =>
                items.isEmpty
                    ? Center(
                      child:
                          Text(
                            'invitesEmpty',
                            textAlign: TextAlign.center,
                          ).tr(),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final invite = items[index];
                        return ChatRoomListTile(
                          room: invite.chatRoom!,
                          isDirect: invite.chatRoom!.type == 1,
                          subtitle: Row(
                            spacing: 6,
                            children: [
                              Flexible(
                                child:
                                    Text(
                                      invite.role >= 100
                                          ? 'permissionOwner'
                                          : invite.role >= 50
                                          ? 'permissionModerator'
                                          : 'permissionMember',
                                    ).tr(),
                              ),
                              if (invite.chatRoom!.type == 1)
                                Badge(
                                  label: const Text('directMessage').tr(),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  textColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Symbols.check),
                                onPressed: () => acceptInvite(invite),
                              ),
                              IconButton(
                                icon: const Icon(Symbols.close),
                                onPressed: () => declineInvite(invite),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
