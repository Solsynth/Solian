import 'package:croppy/croppy.dart' hide cropImage;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/custom_app.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/developers/apps.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'edit_app.g.dart';

@riverpod
Future<CustomApp?> customApp(Ref ref, String publisherName, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/developers/$publisherName/apps/$id');
  return CustomApp.fromJson(resp.data);
}

class EditAppScreen extends HookConsumerWidget {
  final String publisherName;
  final String? id;
  const EditAppScreen({super.key, required this.publisherName, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final app = isNew ? null : ref.watch(customAppProvider(publisherName, id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameController = useTextEditingController();
    final slugController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);

    final submitting = useState(false);

    useEffect(() {
      if (app?.value != null) {
        nameController.text = app!.value!.name;
        slugController.text = app.value!.slug;
        descriptionController.text = app.value!.description ?? '';
        picture.value = app.value!.picture;
        background.value = app.value!.background;
      }
      return null;
    }, [app]);

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
            await putMediaToCloud(
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

    void performAction() async {
      final client = ref.read(apiClientProvider);
      final data = {
        'name': nameController.text,
        'slug': slugController.text,
        'description': descriptionController.text,
        'picture_id': picture.value?.id,
        'background_id': background.value?.id,
      };
      if (isNew) {
        await client.post('/developers/$publisherName/apps', data: data);
      } else {
        await client.patch('/developers/$publisherName/apps/$id', data: data);
      }
      ref.invalidate(customAppsProvider(publisherName));
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(isNew ? 'createCustomApp'.tr() : 'editCustomApp'.tr()),
      ),
      body:
          app == null && !isNew
              ? const Center(child: CircularProgressIndicator())
              : app?.hasError == true && !isNew
              ? ResponseErrorWidget(
                error: app!.error,
                onRetry:
                    () => ref.invalidate(customAppProvider(publisherName, id!)),
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
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
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
                                fallbackIcon: Symbols.apps,
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
                            decoration: InputDecoration(labelText: 'name'.tr()),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: slugController,
                            decoration: InputDecoration(
                              labelText: 'slug'.tr(),
                              helperText: 'slugHint'.tr(),
                            ),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'description'.tr(),
                            ),
                            maxLines: 3,
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed:
                                  submitting.value ? null : performAction,
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
