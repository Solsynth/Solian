import 'package:collection/collection.dart';
import 'package:croppy/croppy.dart' hide cropImage;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/file.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/services/timezone.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kServerSupportedLanguages = {'en-US': 'en-us', 'zh-CN': 'zh-hans'};
const kServerSupportedRegions = ['US', 'JP', 'CN'];

class UpdateProfileScreen extends HookConsumerWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    final submitting = useState(false);

    void updateProfilePicture(String position) async {
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
        final cloudFile =
            await FileUploader.createCloudFile(
              client: ref.read(apiClientProvider),
              fileData: UniversalFile(
                data: result,
                type: UniversalFileType.image,
              ),
            ).future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/id/accounts/me/profile',
          data: {'${position}_id': cloudFile.id},
        );
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final formKeyBasicInfo = useMemoized(GlobalKey<FormState>.new, const []);
    final usernameController = useTextEditingController(text: user.value!.name);
    final nicknameController = useTextEditingController(text: user.value!.nick);
    final language = useState(user.value!.language);
    final region = useState(user.value!.region);
    final links = useState<List<ProfileLink>>(user.value!.profile.links);

    void updateBasicInfo() async {
      if (!formKeyBasicInfo.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/id/accounts/me',
          data: {
            'name': usernameController.text,
            'nick': nicknameController.text,
            'language': language.value,
            'region': region.value,
          },
        );
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    final formKeyProfile = useMemoized(GlobalKey<FormState>.new, const []);
    final birthday = useState<DateTime?>(
      user.value!.profile.birthday?.toLocal(),
    );
    final firstNameController = useTextEditingController(
      text: user.value!.profile.firstName,
    );
    final middleNameController = useTextEditingController(
      text: user.value!.profile.middleName,
    );
    final lastNameController = useTextEditingController(
      text: user.value!.profile.lastName,
    );
    final bioController = useTextEditingController(
      text: user.value!.profile.bio,
    );
    final genderController = useTextEditingController(
      text: user.value!.profile.gender,
    );
    final pronounsController = useTextEditingController(
      text: user.value!.profile.pronouns,
    );
    final locationController = useTextEditingController(
      text: user.value!.profile.location,
    );
    final timeZoneController = useTextEditingController(
      text: user.value!.profile.timeZone,
    );

    void updateProfile() async {
      if (!formKeyProfile.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/id/accounts/me/profile',
          data: {
            'bio': bioController.text,
            'first_name': firstNameController.text,
            'middle_name': middleNameController.text,
            'last_name': lastNameController.text,
            'gender': genderController.text,
            'pronouns': pronounsController.text,
            'location': locationController.text,
            'time_zone': timeZoneController.text,
            'birthday': birthday.value?.toUtc().toIso8601String(),
            'links':
                links.value
                    .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
                    .toList(),
          },
        );
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
        links.value =
            links.value
                .where((e) => e.name.isNotEmpty && e.url.isNotEmpty)
                .toList();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('updateYourProfile').tr(),
        leading: const PageBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          user.value!.profile.background?.id != null
                              ? CloudImageWidget(
                                fileId: user.value!.profile.background!.id,
                                fit: BoxFit.cover,
                              )
                              : const SizedBox.shrink(),
                    ),
                    onTap: () {
                      updateProfilePicture('background');
                    },
                  ),
                  Positioned(
                    left: 20,
                    bottom: -32,
                    child: GestureDetector(
                      child: ProfilePictureWidget(
                        fileId: user.value!.profile.picture?.id,
                        radius: 40,
                      ),
                      onTap: () {
                        updateProfilePicture('picture');
                      },
                    ),
                  ),
                ],
              ),
            ).padding(bottom: 32),
            Text('accountBasicInfo')
                .tr()
                .bold()
                .fontSize(18)
                .padding(horizontal: 24, top: 16, bottom: 12),
            Form(
              key: formKeyBasicInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'username'.tr(),
                      helperText: 'usernameCannotChangeHint'.tr(),
                      prefixText: '@',
                    ),
                    controller: usernameController,
                    readOnly: true,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'nickname'.tr()),
                    controller: nicknameController,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      labelText: 'language'.tr(),
                      helperText: 'accountLanguageHint'.tr(),
                    ),
                    items: [
                      ...kServerSupportedLanguages.values.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                      if (!kServerSupportedLanguages.containsValue(
                        language.value,
                      ))
                        DropdownMenuItem(
                          value: language.value,
                          child: Text(language.value),
                        ),
                    ],
                    value: language.value,
                    onChanged: (value) {
                      language.value = value ?? language.value;
                    },
                    customButton: Row(
                      children: [
                        Expanded(child: Text(language.value)),
                        Icon(Symbols.arrow_drop_down),
                      ],
                    ),
                  ),
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      labelText: 'region'.tr(),
                      helperText: 'accountRegionHint'.tr(),
                    ),
                    items: [
                      ...kServerSupportedRegions.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                      if (!kServerSupportedRegions.contains(region.value))
                        DropdownMenuItem(
                          value: region.value,
                          child: Text(region.value),
                        ),
                    ],
                    value: region.value,
                    onChanged: (value) {
                      region.value = value ?? region.value;
                    },
                    customButton: Row(
                      children: [
                        Expanded(child: Text(region.value)),
                        Icon(Symbols.arrow_drop_down),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: submitting.value ? null : updateBasicInfo,
                      label: Text('saveChanges').tr(),
                      icon: const Icon(Symbols.save),
                    ),
                  ),
                ],
              ).padding(horizontal: 24),
            ),
            Text('accountProfile')
                .tr()
                .bold()
                .fontSize(18)
                .padding(horizontal: 24, top: 16, bottom: 8),
            Form(
              key: formKeyProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'firstName'.tr(),
                          ),
                          controller: firstNameController,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'middleName'.tr(),
                          ),
                          controller: middleNameController,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'lastName'.tr(),
                          ),
                          controller: lastNameController,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                    ],
                  ),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'bio'.tr(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    minLines: 3,
                    controller: bioController,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final options = ['Male', 'Female'];
                            if (textEditingValue.text == '') {
                              return options;
                            }
                            return options.where(
                              (option) => option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            genderController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Initialize the controller with the current value
                            if (controller.text.isEmpty &&
                                genderController.text.isNotEmpty) {
                              controller.text = genderController.text;
                            }

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'gender'.tr(),
                              ),
                              onChanged: (value) {
                                genderController.text = value;
                              },
                              onTapOutside:
                                  (_) =>
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus(),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'pronouns'.tr(),
                          ),
                          controller: pronounsController,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'location'.tr(),
                          ),
                          controller: locationController,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            final lowercaseQuery =
                                textEditingValue.text.toLowerCase();
                            return getAvailableTz().where((tz) {
                              return tz.toLowerCase().contains(lowercaseQuery);
                            });
                          },
                          onSelected: (String selection) {
                            timeZoneController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Sync the controller with timeZoneController when the widget is built
                            if (controller.text != timeZoneController.text) {
                              controller.text = timeZoneController.text;
                            }

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'timeZone'.tr(),
                                suffix: InkWell(
                                  child: const Icon(
                                    Symbols.my_location,
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    try {
                                      showLoadingModal(context);
                                      final machineTz = await getMachineTz();
                                      controller.text = machineTz;
                                      timeZoneController.text = machineTz;
                                    } finally {
                                      if (context.mounted) {
                                        hideLoadingModal(context);
                                      }
                                    }
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                timeZoneController.text = value;
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: 300,
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: options.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          option,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
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
                  Text('links').tr().bold().fontSize(18).padding(top: 16),
                  Column(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < links.value.length; i++)
                        Row(
                          key: ValueKey(links.value[i].hashCode),
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: links.value[i].name,
                                decoration: InputDecoration(
                                  labelText: 'linkKey'.tr(),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  links.value[i] = links.value[i].copyWith(
                                    name: value,
                                  );
                                },
                                onTapOutside:
                                    (_) =>
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus(),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: TextFormField(
                                initialValue: links.value[i].url,
                                decoration: InputDecoration(
                                  labelText: 'linkValue'.tr(),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  links.value[i] = links.value[i].copyWith(
                                    url: value,
                                  );
                                },
                                onTapOutside:
                                    (_) =>
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Symbols.delete),
                              onPressed: () {
                                links.value =
                                    links.value
                                        .whereIndexed((idx, _) => idx != i)
                                        .toList();
                              },
                            ),
                          ],
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            links.value = List.from(links.value)
                              ..add(ProfileLink(name: '', url: ''));
                          },
                          label: Text('addLink').tr(),
                          icon: const Icon(Symbols.add),
                        ).padding(top: 8),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: submitting.value ? null : updateProfile,
                      label: Text('saveChanges').tr(),
                      icon: const Icon(Symbols.save),
                    ),
                  ),
                ],
              ).padding(horizontal: 24),
            ),
          ],
        ),
      ),
    );
  }
}
