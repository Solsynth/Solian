import 'package:croppy/croppy.dart' hide cropImage;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/services/image.dart';
import 'package:island/developers/models/bot.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'edit_bot.g.dart';

@riverpod
Future<Bot?> bot(
  Ref ref,
  String publisherName,
  String projectId,
  String id,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/bots/$id',
  );
  return Bot.fromJson(resp.data);
}

@RoutePage()
class DeveloperBotEditScreen extends HookConsumerWidget {
  final String pubName;
  final String projectId;
  final String? id;
  final bool isModal;
  const DeveloperBotEditScreen({
    super.key,
    required this.pubName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final botData = isNew
        ? null
        : ref.watch(botProvider(pubName, projectId, id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final submitting = useState(false);

    final nameController = useTextEditingController();
    final nickController = useTextEditingController();
    final slugController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);

    final firstNameController = useTextEditingController();
    final middleNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final genderController = useTextEditingController();
    final pronounsController = useTextEditingController();
    final locationController = useTextEditingController();
    final timeZoneController = useTextEditingController();
    final bioController = useTextEditingController();
    final birthday = useState<DateTime?>(null);
    final background = useState<SnCloudFile?>(null);

    useEffect(() {
      if (botData?.value != null) {
        nameController.text = botData!.value!.account.name;
        nickController.text = botData.value!.account.nick;
        slugController.text = botData.value!.slug;
        picture.value = botData.value!.account.profile.picture;
        background.value = botData.value!.account.profile.background;

        // Populate from botData.value.account.profile
        firstNameController.text = botData.value!.account.profile.firstName;
        middleNameController.text = botData.value!.account.profile.middleName;
        lastNameController.text = botData.value!.account.profile.lastName;
        genderController.text = botData.value!.account.profile.gender;
        pronounsController.text = botData.value!.account.profile.pronouns;
        locationController.text = botData.value!.account.profile.location;
        timeZoneController.text = botData.value!.account.profile.timeZone;
        bioController.text = botData.value!.account.profile.bio;
        birthday.value = botData.value!.account.profile.birthday?.toLocal();
      }
      return null;
    }, [botData]);

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
        final cloudFile = await FileUploader.createCloudFile(
          ref: ref,
          fileData: UniversalFile(data: result, type: UniversalFileType.image),
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

    void performAction() async {
      final client = ref.read(apiClientProvider);
      final data = {
        'name': nameController.text,
        'nick': nickController.text,
        'slug': slugController.text,
        'picture_id': picture.value?.id,
        'background_id': background.value?.id,
        'first_name': firstNameController.text,
        'middle_name': middleNameController.text,
        'last_name': lastNameController.text,
        'gender': genderController.text,
        'pronouns': pronounsController.text,
        'location': locationController.text,
        'time_zone': timeZoneController.text,
        'bio': bioController.text,
        'birthday': birthday.value?.toUtc().toIso8601String(),
      };

      try {
        showLoadingModal(context);
        if (isNew) {
          await client.post(
            '/develop/developers/$pubName/projects/$projectId/bots',
            data: data,
          );
        } else {
          await client.patch(
            '/develop/developers/$pubName/projects/$projectId/bots/$id',
            data: data,
          );
        }

        if (context.mounted) {
          context.pop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final bodyContent = botData == null && !isNew
        ? const Center(child: CircularProgressIndicator())
        : botData?.hasError == true && !isNew
        ? ResponseErrorWidget(
            error: botData!.error,
            onRetry: () => ref.invalidate(botProvider(pubName, projectId, id!)),
          )
        : SingleChildScrollView(
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
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
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
                            fallbackIcon: Symbols.smart_toy,
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
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'name'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nickController,
                        decoration: InputDecoration(
                          labelText: 'nickname'.tr(),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: slugController,
                        decoration: InputDecoration(
                          labelText: 'slug'.tr(),
                          helperText: 'slugHint'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bioController,
                        decoration: InputDecoration(
                          labelText: 'bio'.tr(),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'firstName'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: middleNameController,
                              decoration: InputDecoration(
                                labelText: 'middleName'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'lastName'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: genderController,
                              decoration: InputDecoration(
                                labelText: 'gender'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: pronounsController,
                              decoration: InputDecoration(
                                labelText: 'pronouns'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: locationController,
                              decoration: InputDecoration(
                                labelText: 'location'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: timeZoneController,
                              decoration: InputDecoration(
                                labelText: 'timeZone'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: birthday.value ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            birthday.value = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'birthday'.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              Text(
                                birthday.value != null
                                    ? DateFormat.yMMMd().format(birthday.value!)
                                    : 'Select a date'.tr(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: submitting.value ? null : performAction,
                          label: Text('saveChanges').tr(),
                          icon: const Icon(Symbols.save),
                        ),
                      ),
                    ],
                  ).padding(all: 24),
                ),
              ],
            ),
          );

    if (isModal) {
      return bodyContent;
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text(isNew ? 'createBot'.tr() : 'editBot'.tr())),
      body: bodyContent,
    );
  }
}
