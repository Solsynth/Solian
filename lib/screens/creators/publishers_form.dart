import 'package:collection/collection.dart';
import 'package:croppy/croppy.dart' hide cropImage;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/services/file.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'publishers_form.g.dart';

@riverpod
Future<List<SnPublisher>> publishersManaged(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/publishers');
  return resp.data
      .map((e) => SnPublisher.fromJson(e))
      .cast<SnPublisher>()
      .toList();
}

@riverpod
Future<SnPublisher?> publisherNullable(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/publishers/$identifier');
  return SnPublisher.fromJson(resp.data);
}

class NewPublisherScreen extends StatelessWidget {
  const NewPublisherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditPublisherScreen(key: key);
  }
}

class EditPublisherScreen extends HookConsumerWidget {
  final String? name;
  const EditPublisherScreen({super.key, this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    final picture = useState<String?>(null);
    final background = useState<String?>(null);

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
        replacePath: true,
        allowedAspectRatios: [
          if (position == 'background')
            CropAspectRatio(height: 7, width: 16)
          else
            CropAspectRatio(height: 1, width: 1),
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
        final cloudFile = await FileUploader.createCloudFile(
          ref: ref,
          fileData: UniversalFile(data: result, type: UniversalFileType.image),
        ).future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        switch (position) {
          case 'picture':
            picture.value = cloudFile.id;
          case 'background':
            background.value = cloudFile.id;
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final publisher = ref.watch(publisherNullableProvider(name));

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final nameController = useTextEditingController(
      text: publisher.value?.name,
    );
    final nickController = useTextEditingController(
      text: publisher.value?.nick,
    );
    final bioController = useTextEditingController(text: publisher.value?.bio);

    final joinedRealms = ref.watch(realmsJoinedProvider);
    final currentRealm = useState<SnRealm?>(null);

    useEffect(() {
      if (publisher.value != null) {
        picture.value = publisher.value!.picture?.id;
        background.value = publisher.value!.background?.id;
        nameController.text = publisher.value!.name;
        nickController.text = publisher.value!.nick;
        bioController.text = publisher.value!.bio;
        currentRealm.value = joinedRealms.value?.firstWhereOrNull(
          (realm) => realm.id == publisher.value!.realmId,
        );
      }
      return null;
    }, [publisher]);

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          '/sphere${name == null
              ? currentRealm.value == null
                    ? '/publishers/individual'
                    : '/publishers/organization/${currentRealm.value!.slug}'
              : '/publishers/$name'}',
          data: {
            'name': nameController.text,
            'nick': nickController.text,
            'bio': bioController.text,
            'picture_id': picture.value,
            'background_id': background.value,
          },
          options: Options(method: name == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.pop(SnPublisher.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    final titleText = (name == null ? 'createPublisher' : 'editPublisher').tr();

    return SheetScaffold(
      titleText: titleText,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
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
                          ? CloudImageWidget(
                              fileId: background.value!,
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
                        fileId: picture.value,
                        radius: 40,
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
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 480),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'username'.tr(),
                        helperText: 'usernameCannotChangeHint'.tr(),
                        prefixText: '@',
                      ),
                      readOnly: name != null,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    TextFormField(
                      controller: nickController,
                      decoration: InputDecoration(labelText: 'nickname'.tr()),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    TextFormField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'bio'.tr(),
                        alignLabelWithHint: true,
                      ),
                      minLines: 3,
                      maxLines: null,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    DropdownButtonFormField<SnRealm>(
                      value: currentRealm.value,
                      decoration: InputDecoration(labelText: 'realm'.tr()),
                      items: [
                        DropdownMenuItem<SnRealm>(
                          value: null,
                          child: Text('individual'.tr()),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            if (currentRealm.value == null) {
                              final user = ref.watch(userInfoProvider);
                              nameController.text = user.value!.name;
                              nickController.text = user.value!.nick;
                              bioController.text = user.value!.profile.bio;
                              picture.value = user.value!.profile.picture?.id;
                              background.value =
                                  user.value!.profile.background?.id;
                            } else {
                              nameController.text = currentRealm.value!.slug;
                              nickController.text = currentRealm.value!.name;
                              bioController.text =
                                  currentRealm.value!.description;
                              picture.value = currentRealm.value!.picture?.id;
                              background.value =
                                  currentRealm.value!.background?.id;
                            }
                          },
                          label: Text(
                            currentRealm.value == null
                                ? 'syncPublisher'
                                : 'syncPublisherRealm',
                          ).tr(),
                          icon: const Icon(Symbols.link),
                        ),
                        TextButton.icon(
                          onPressed: submitting.value ? null : performAction,
                          label: Text(
                            name == null ? 'create' : 'saveChanges',
                          ).tr(),
                          icon: const Icon(Symbols.save),
                        ),
                      ],
                    ),
                  ],
                ).padding(horizontal: 24),
              ).alignment(Alignment.topCenter),
            ),
          ],
        ),
      ),
    );
  }
}
