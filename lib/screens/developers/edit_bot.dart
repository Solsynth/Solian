import 'package:croppy/croppy.dart' hide cropImage;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/bot.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'edit_bot.g.dart';

@riverpod
Future<Bot?> bot(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/develop/bots/$id');
  return Bot.fromJson(resp.data);
}

class EditBotScreen extends HookConsumerWidget {
  final String publisherName;
  final String? id;
  final String? appId;
  const EditBotScreen({
    super.key,
    required this.publisherName,
    this.id,
    this.appId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final botData = isNew ? null : ref.watch(botProvider(id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final submitting = useState(false);

    final nameController = useTextEditingController();
    final slugController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final websiteController = useTextEditingController();
    final documentationController = useTextEditingController();

    final isPublic = useState(false);
    final isInteractive = useState(false);

    useEffect(() {
      if (botData?.value != null) {
        nameController.text = botData!.value!.name;
        slugController.text = botData.value!.slug;
        descriptionController.text = botData.value!.description ?? '';
        picture.value = botData.value!.picture;
        websiteController.text = botData.value!.links?.website ?? '';
        documentationController.text =
            botData.value!.links?.documentation ?? '';
        isPublic.value = botData.value!.config?.isPublic ?? false;
        isInteractive.value = botData.value!.config?.isInteractive ?? false;
      }
      return null;
    }, [botData]);

    void setPicture() async {
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
        allowedAspectRatios: [const CropAspectRatio(height: 1, width: 1)],
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
        picture.value = cloudFile;
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
        'config': {
          'is_public': isPublic.value,
          'is_interactive': isInteractive.value,
        },
        'links': {
          'website':
              websiteController.text.isNotEmpty ? websiteController.text : null,
          'documentation':
              documentationController.text.isNotEmpty
                  ? documentationController.text
                  : null,
        },
        'publisher_id': publisherName,
        if (appId != null) 'app_id': appId,
      };

      if (isNew) {
        await client.post('/develop/bots', data: data);
      } else {
        await client.patch('/develop/bots/$id', data: data);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return AppScaffold(
      appBar: AppBar(title: Text(isNew ? 'createBot'.tr() : 'editBot'.tr())),
      body:
          botData == null && !isNew
              ? const Center(child: CircularProgressIndicator())
              : botData?.hasError == true && !isNew
              ? ResponseErrorWidget(
                error: botData!.error,
                onRetry: () => ref.invalidate(botProvider(id!)),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: setPicture,
                        child: Container(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                          child:
                              picture.value != null
                                  ? CloudFileWidget(
                                    item: picture.value!,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Symbols.smart_toy, size: 48),
                        ),
                      ),
                    ).padding(bottom: 32),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: 'name'.tr()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: slugController,
                            decoration: InputDecoration(
                              labelText: 'slug'.tr(),
                              helperText: 'slugHint'.tr(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'description'.tr(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: websiteController,
                            decoration: InputDecoration(
                              labelText: 'websiteUrl'.tr(),
                              hintText: 'https://example.com',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: documentationController,
                            decoration: InputDecoration(
                              labelText: 'documentationUrl'.tr(),
                              hintText: 'https://example.com/docs',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text('isPublic').tr(),
                            value: isPublic.value,
                            onChanged: (value) => isPublic.value = value,
                          ),
                          SwitchListTile(
                            title: Text('isInteractive').tr(),
                            value: isInteractive.value,
                            onChanged: (value) => isInteractive.value = value,
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
