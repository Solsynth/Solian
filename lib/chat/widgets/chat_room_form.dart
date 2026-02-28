import 'package:collection/collection.dart';
import 'package:croppy/croppy.dart' hide cropImage;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/image.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/drive_service.dart';
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
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);
    final isPublic = useState(true);
    final isCommunity = useState(false);
    final encryptionMode = useState<int>(0);

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
        encryptionMode.value = chat.value!.encryptionMode;
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
        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: UniversalFile(
                data: result,
                type: UniversalFileType.image,
              ),
            )
            .future;
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
          id == null ? '/messager/chat' : '/messager/chat/$id',
          data: {
            'name': nameController.text,
            'description': descriptionController.text,
            'background_id': background.value?.id,
            'picture_id': picture.value?.id,
            'realm_id': currentRealm.value?.id,
            'is_public': isPublic.value,
            'is_community': isCommunity.value,
            'encryption_mode': encryptionMode.value,
          },
          options: Options(method: id == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.router.pop(SnChatRoom.fromJson(resp.data));
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
                        file: picture.value,
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
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    minLines: 3,
                    maxLines: null,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SnRealm>(
                    value: currentRealm.value,
                    decoration: InputDecoration(
                      labelText: 'realm'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<SnRealm>(
                        value: null,
                        child: Text('none'.tr()),
                      ),
                      ...joinedRealms.maybeWhen(
                        data: (realms) => realms.map(
                          (realm) => DropdownMenuItem(
                            value: realm,
                            child: Text(realm.name),
                          ),
                        ),
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
                  DropdownButtonFormField<int>(
                    value: encryptionMode.value,
                    decoration: InputDecoration(
                      labelText: 'Encryption mode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('None (plaintext)'),
                      ),
                      DropdownMenuItem(value: 1, child: Text('E2EE DM')),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('E2EE Group (sender key)'),
                      ),
                    ],
                    onChanged: (value) {
                      encryptionMode.value = value ?? 0;
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
