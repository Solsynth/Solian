import 'package:collection/collection.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditChatScreen();
  }
}

@RoutePage()
class EditChatScreen extends HookConsumerWidget {
  final String? id;

  const EditChatScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final submitting = useState(false);

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<IDisplayableCloudFile?>(null);
    final background = useState<IDisplayableCloudFile?>(null);
    final isPublic = useState(true);
    final isCommunity = useState(false);

    final chat = ref.watch(chatRoomProvider(id));

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
        currentRealm.value = joinedRealms.value?.firstWhereOrNull((realm) => realm.id == chat.value!.realmId);
      }
      return;
    }, [chat, joinedRealms]);

    void setPicture(String position) async {
      final result = await showImagePickerEditor(
        context,
        config: position == 'background'
            ? const ImageEditorConfig(
                allowedAspectRatios: [ImageAspectRatio(width: 16, height: 7)],
                allowMultiple: false,
                allowCompression: true,
                defaultCompressionQuality: 85,
              )
            : const ImageEditorConfig(
                allowedAspectRatios: [ImageAspectRatio.square],
                allowMultiple: false,
                allowCompression: true,
                defaultCompressionQuality: 90,
              ),
        title: position == 'background' ? 'settingsBackgroundImage'.tr() : 'accountProfile'.tr(),
      );
      if (result == null) return;
      if (!context.mounted) return;
      showLoadingModal(context);
      submitting.value = true;
      try {
        final cloudFile = result as SnCloudFile;
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
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          id == null ? '/messager/chat' : '/messager/chat/$id',
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
        final finalRoom = SnChatRoom.fromJson(resp.data);

        if (context.mounted) {
          context.router.pop(finalRoom);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: (id == null ? 'createChatRoom' : 'editChatRoom').tr(),
      onClose: () => context.pop(),
      child: SingleChildScrollView(
        child: Column(
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
                      child: background.value != null
                          ? CloudFileWidget(item: background.value!, fit: BoxFit.cover)
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
                      child: ProfilePictureWidget(file: picture.value, radius: 40, fallbackIcon: Symbols.group),
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
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    minLines: 3,
                    maxLines: null,
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SnRealm>(
                    value: currentRealm.value,
                    decoration: InputDecoration(
                      labelText: 'realm'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      DropdownMenuItem<SnRealm>(value: null, child: Text('none'.tr())),
                      ...joinedRealms.maybeWhen(
                        data: (realms) =>
                            realms.map((realm) => DropdownMenuItem(value: realm, child: Text(realm.name))),
                        orElse: () => [],
                      ),
                    ],
                    onChanged: joinedRealms.isLoading
                        ? null
                        : (SnRealm? value) {
                            currentRealm.value = value;
                          },
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        CheckboxListTile(
                          secondary: const Icon(Symbols.travel_explore),
                          title: Text('communityChat').tr(),
                          subtitle: Text('communityChatDescription').tr(),
                          value: isCommunity.value,
                          onChanged: (value) {
                            isCommunity.value = value ?? false;
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
