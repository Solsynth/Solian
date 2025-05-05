import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/route.gr.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'chat.g.dart';

@riverpod
Future<List<SnChatRoom>> chatroomsJoined(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/chat');
  return resp.data
      .map((e) => SnChatRoom.fromJson(e))
      .cast<SnChatRoom>()
      .toList();
}

@RoutePage()
class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatroomsJoinedProvider);

    final fabKey = useMemoized(() => GlobalKey<ExpandableFabState>(), []);

    Future<void> createDirectMessage() async {
      final result = await showModalBottomSheet(
        context: context,
        builder: (context) => AccountPickerSheet(),
      );
      if (result == null) return;
      final client = ref.read(apiClientProvider);
      try {
        await client.post('/chat/direct', data: {'related_user_id': result.id});
        ref.invalidate(chatroomsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('chat').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.email),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => _ChatInvitesSheet(),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: fabKey,
        distance: 75,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Theme.of(
            context,
          ).colorScheme.surface.withAlpha((255 * 0.5).round()),
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Symbols.add, size: 28),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          heroTag: Key("chat-page-fab"),
          child: const Icon(Symbols.close, size: 28),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:
              Theme.of(context).floatingActionButtonTheme.foregroundColor,
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
        ),
        children: [
          Row(
            children: [
              Text('createChatRoom').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'createChatRoom'.tr(),
                onPressed: () {
                  context.pushRoute(NewChatRoute()).then((value) {
                    if (value != null) {
                      ref.invalidate(chatroomsJoinedProvider);
                    }
                  });
                },
                child: const Icon(Symbols.chat_add_on),
              ),
            ],
          ),
          Row(
            children: [
              Text('createDirectMessage').tr(),
              const Gap(20),
              FloatingActionButton(
                heroTag: null,
                tooltip: 'createDirectMessage'.tr(),
                onPressed: createDirectMessage,
                child: const Icon(Symbols.communication),
              ),
            ],
          ),
        ],
      ),
      body: chats.when(
        data:
            (items) => RefreshIndicator(
              onRefresh:
                  () => Future.sync(() {
                    ref.invalidate(chatroomsJoinedProvider);
                  }),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item.type == 1) {
                    return ListTile(
                      leading: ProfilePictureWidget(
                        fileId: item.members!.first.account.profile.pictureId,
                      ),
                      title: Text(item.members!.first.account.nick),
                      subtitle: Text("An direct message"),
                      onTap: () {
                        context.pushRoute(ChatRoomRoute(id: item.id));
                      },
                    );
                  }
                  return ListTile(
                    leading:
                        item.pictureId == null
                            ? CircleAvatar(
                              child: Text(item.name[0].toUpperCase()),
                            )
                            : ProfilePictureWidget(fileId: item.pictureId),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    onTap: () {
                      context.pushRoute(ChatRoomRoute(id: item.id));
                    },
                  );
                },
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => GestureDetector(
              child: Center(child: Text('Error: $error')),
              onTap: () {
                ref.invalidate(chatroomsJoinedProvider);
              },
            ),
      ),
    );
  }
}

@riverpod
Future<SnChatRoom?> chatroom(Ref ref, int? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/chat/$identifier');
  return SnChatRoom.fromJson(resp.data);
}

@riverpod
Future<SnChatMember?> chatroomIdentity(Ref ref, int? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/chat/$identifier/members/me');
  return SnChatMember.fromJson(resp.data);
}

@RoutePage()
class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditChatScreen();
  }
}

@RoutePage()
class EditChatScreen extends HookConsumerWidget {
  final int? id;
  const EditChatScreen({super.key, @PathParam("id") this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final submitting = useState(false);

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);

    final chat = ref.watch(chatroomProvider(id));

    useEffect(() {
      if (chat.value != null) {
        nameController.text = chat.value!.name;
        descriptionController.text = chat.value!.description;
        picture.value = chat.value!.picture;
        background.value = chat.value!.background;
      }
      return;
    }, [chat]);

    void setPicture(String position) async {
      final result = await ref
          .read(imagePickerProvider)
          .pickImage(source: ImageSource.gallery);
      if (result == null) return;

      submitting.value = true;
      try {
        final baseUrl = ref.watch(serverUrlProvider);
        final atk = await getFreshAtk(
          ref.watch(tokenPairProvider),
          baseUrl,
          onRefreshed: (atk, rtk) {
            setTokenPair(ref.watch(sharedPreferencesProvider), atk, rtk);
            ref.invalidate(tokenPairProvider);
          },
        );
        if (atk == null) throw ArgumentError('Access token is null');
        final cloudFile =
            await putMediaToCloud(
              fileData: result,
              atk: atk,
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
        submitting.value = false;
      }
    }

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          id == null ? '/chat' : '/chat/$id',
          data: {
            'name': nameController.text,
            'description': descriptionController.text,
            'background_id': background.value?.id,
            'picture_id': picture.value?.id,
          },
          options: Options(method: id == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.maybePop(SnChatRoom.fromJson(resp.data));
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
      body: Column(
        children: [
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
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 3,
                  maxLines: null,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
    );
  }
}

@riverpod
Future<List<SnChatMember>> chatroomInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/chat/invites');
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
        await client.post('/chat/invites/${invite.chatRoom!.id}/accept');
        ref.invalidate(chatroomInvitesProvider);
        ref.invalidate(chatroomsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnChatMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/chat/invites/${invite.chatRoom!.id}/decline');
        ref.invalidate(chatroomInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  'invites'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.refresh),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                  onPressed: () {
                    ref.invalidate(chatroomInvitesProvider);
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
                              return ListTile(
                                leading: ProfilePictureWidget(
                                  fileId: invite.chatRoom!.pictureId,
                                  radius: 24,
                                  fallbackIcon: Symbols.group,
                                ),
                                title: Text(invite.chatRoom!.name),
                                subtitle:
                                    Text(
                                      invite.role >= 100
                                          ? 'permissionOwner'
                                          : invite.role >= 50
                                          ? 'permissionModerator'
                                          : 'permissionMember',
                                    ).tr(),
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
          ),
        ],
      ),
    );
  }
}
