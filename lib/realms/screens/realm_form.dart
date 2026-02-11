import 'package:croppy/croppy.dart' show CropAspectRatio;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/services/image.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class RealmNewScreen extends StatelessWidget {
  const RealmNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RealmEditScreen();
  }
}

@RoutePage()
class RealmEditScreen extends HookConsumerWidget {
  final String? slug;
  const RealmEditScreen({super.key, this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);
    final isPublic = useState(true);
    final isCommunity = useState(false);

    final slugController = useTextEditingController();
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final realm = ref.watch(realmProvider(slug));

    useEffect(() {
      if (realm.value != null) {
        picture.value = realm.value!.picture;
        background.value = realm.value!.background;
        slugController.text = realm.value!.slug;
        nameController.text = realm.value!.name;
        descriptionController.text = realm.value!.description;
        isPublic.value = realm.value!.isPublic;
        isCommunity.value = realm.value!.isCommunity;
      }
      return null;
    }, [realm]);

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

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          '/pass${slug == null ? '/realms' : '/realms/$slug'}',
          data: {
            'slug': slugController.text,
            'name': nameController.text,
            'description': descriptionController.text,
            'background_id': background.value?.id,
            'picture_id': picture.value?.id,
            'is_public': isPublic.value,
            'is_community': isCommunity.value,
          },
          options: Options(method: slug == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.router.pop(SnRealm.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(slug == null ? 'createRealm'.tr() : 'editRealm'.tr()),
        leading: const PageBackButton(),
      ),
      body: SingleChildScrollView(
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
                    controller: slugController,
                    decoration: InputDecoration(
                      labelText: 'slug'.tr(),
                      helperText: 'slugHint'.tr(),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'name'.tr()),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'description'.tr(),
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: null,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          secondary: const Icon(Symbols.public),
                          title: Text('publicRealm').tr(),
                          subtitle: Text('publicRealmDescription').tr(),
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
                          title: Text('communityRealm').tr(),
                          subtitle: Text('communityRealmDescription').tr(),
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
                      label: Text('saveChanges'.tr()),
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
