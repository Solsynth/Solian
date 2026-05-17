import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/realms/models/realm_quota_info.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'realm_form_content.g.dart';

@riverpod
Future<RealmQuotaInfo> realmQuotaInfo(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final response = await client.dio.get('/passport/realms/quota');
  return RealmQuotaInfo.fromJson(response.data);
}

@riverpod
Future<SnRealm?> _realm(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(solarNetworkClientProvider);
  return await client.realms.getRealm(identifier);
}

// Export the provider for external use
final realmProvider = _realmProvider;

class RealmFormContent extends HookConsumerWidget {
  final String? slug;
  final bool isInSheet;
  final VoidCallback? onSubmit;

  const RealmFormContent({
    super.key,
    this.slug,
    this.isInSheet = false,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);
    final picture = useState<IDisplayableCloudFile?>(null);
    final background = useState<IDisplayableCloudFile?>(null);
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
        title: position == 'background'
            ? 'settingsBackgroundImage'.tr()
            : 'accountProfile'.tr(),
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
        final client = ref.read(solarNetworkClientProvider);
        final realm = await ref.watch(realmProvider(slug).future);
        final isCreate = realm == null;
        final resp = await client.dio.request(
          '/passport/realms${isCreate ? '' : '/$slug'}',
          data: {
            'slug': slugController.text,
            'name': nameController.text,
            'description': descriptionController.text,
            'background_id': background.value?.id,
            'picture_id': picture.value?.id,
            'is_public': isPublic.value,
            'is_community': isCommunity.value,
          },
          options: Options(method: isCreate ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          Navigator.of(context).pop(SnRealm.fromJson(resp.data));
          onSubmit?.call();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Column(
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
                onTap: () => setPicture('background'),
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
                  onTap: () => setPicture('picture'),
                ),
              ),
            ],
          ),
        ).padding(bottom: 40),
        if (slug == null) ...[
          ref
                  .watch(realmQuotaInfoProvider)
                  .whenOrNull(
                    data: (data) => Card(
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: HookBuilder(
                        builder: (context) {
                          final isCollapsed = useState(true);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.used} / ${data.total}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).padding(horizontal: 4),
                              Row(
                                children: [
                                  Text('realmQuotaSlotUsed').tr(),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () =>
                                        isCollapsed.value = !isCollapsed.value,
                                    child: const Icon(Symbols.info, size: 16),
                                  ),
                                ],
                              ).padding(horizontal: 4),
                              if (!isCollapsed.value)
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'realmQuotaInfoHint',
                                  ).tr().fontSize(13).opacity(0.75),
                                ),
                              const Gap(8),
                              LinearProgressIndicator(
                                value: data.total > 0
                                    ? data.used / data.total
                                    : 0,
                              ),
                            ],
                          ).padding(horizontal: 16, vertical: 12);
                        },
                      ),
                    ),
                  ) ??
              const SizedBox.shrink(),
        ],
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: slugController,
                decoration: InputDecoration(
                  labelText: 'slug'.tr(),
                  helperText: slug != null
                      ? 'usernameCannotChangeHint'.tr()
                      : 'slugHint'.tr(),
                ),
                readOnly: slug != null,
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
                  label: Text((slug == null ? 'create' : 'saveChanges').tr()),
                  icon: Icon(slug == null ? Symbols.add : Symbols.save),
                ),
              ),
            ],
          ).padding(horizontal: 24),
        ),
      ],
    );
  }
}
