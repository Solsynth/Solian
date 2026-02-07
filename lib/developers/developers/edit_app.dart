import 'package:croppy/croppy.dart' hide cropImage;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/services/image.dart';
import 'package:island/developers/developers/apps.dart';
import 'package:island/developers/developers_models/custom_app.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';

part 'edit_app.g.dart';

@riverpod
Future<CustomApp?> customApp(
  Ref ref,
  String publisherName,
  String projectId,
  String id,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/apps/$id',
  );
  return CustomApp.fromJson(resp.data);
}

class EditAppScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  final String? id;
  final bool isModal;
  const EditAppScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final app = isNew
        ? null
        : ref.watch(customAppProvider(publisherName, projectId, id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final submitting = useState(false);

    final nameController = useTextEditingController();
    final slugController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);

    final enableLinks = useState(false); // Only for UI purposes
    final homePageController = useTextEditingController();
    final privacyPolicyController = useTextEditingController();
    final termsController = useTextEditingController();
    final oauthEnabled = useState(false);
    final redirectUris = useState<List<String>>([]);
    final postLogoutUris = useState<List<String>>([]);
    final allowedScopes = useState<List<String>>([
      'openid',
      'profile',
      'email',
    ]);
    final allowedGrantTypes = useState<List<String>>([
      'authorization_code',
      'refresh_token',
    ]);
    final requirePkce = useState(true);
    final allowOfflineAccess = useState(false);

    useEffect(() {
      if (app?.value != null) {
        nameController.text = app!.value!.name;
        slugController.text = app.value!.slug;
        descriptionController.text = app.value!.description ?? '';
        picture.value = app.value!.picture;
        background.value = app.value!.background;
        homePageController.text = app.value!.links?.homePage ?? '';
        privacyPolicyController.text = app.value!.links?.privacyPolicy ?? '';
        termsController.text = app.value!.links?.termsOfService ?? '';
        if (app.value!.oauthConfig != null) {
          oauthEnabled.value = true;
          redirectUris.value = app.value!.oauthConfig!.redirectUris;
          postLogoutUris.value =
              app.value!.oauthConfig!.postLogoutRedirectUris ?? [];
          allowedScopes.value = app.value!.oauthConfig!.allowedScopes;
          allowedGrantTypes.value = app.value!.oauthConfig!.allowedGrantTypes;
          requirePkce.value = app.value!.oauthConfig!.requirePkce;
          allowOfflineAccess.value = app.value!.oauthConfig!.allowOfflineAccess;
        }
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

    void showAddScopeDialog() {
      final scopeController = TextEditingController();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          titleText: 'addScope'.tr(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: scopeController,
                  decoration: InputDecoration(
                    labelText: 'scopeName'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () {
                    if (scopeController.text.isNotEmpty) {
                      allowedScopes.value = [
                        ...allowedScopes.value,
                        scopeController.text,
                      ];
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('add').tr(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void showAddRedirectUriDialog() {
      final uriController = TextEditingController();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          titleText: 'addRedirectUri'.tr(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: uriController,
                  decoration: InputDecoration(
                    labelText: 'redirectUri'.tr(),
                    hintText: 'https://example.com/auth/callback',
                    helperText: 'redirectUriHint'.tr(),
                    helperMaxLines: 3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'uriRequired'.tr();
                    }
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'invalidUri'.tr();
                    }
                    return null;
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () {
                    if (uriController.text.isNotEmpty) {
                      redirectUris.value = [
                        ...redirectUris.value,
                        uriController.text,
                      ];
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('add').tr(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void performAction() async {
      final client = ref.read(apiClientProvider);
      final data = {
        'name': nameController.text,
        'slug': slugController.text,
        'description': descriptionController.text,
        'picture_id': picture.value?.id,
        'background_id': background.value?.id,
        'links': {
          'home_page': homePageController.text.isNotEmpty
              ? homePageController.text
              : null,
          'privacy_policy': privacyPolicyController.text.isNotEmpty
              ? privacyPolicyController.text
              : null,
          'terms_of_service': termsController.text.isNotEmpty
              ? termsController.text
              : null,
        },
        'oauth_config': oauthEnabled.value
            ? {
                'redirect_uris': redirectUris.value,
                'post_logout_redirect_uris': postLogoutUris.value.isNotEmpty
                    ? postLogoutUris.value
                    : null,
                'allowed_scopes': allowedScopes.value,
                'allowed_grant_types': allowedGrantTypes.value,
                'require_pkce': requirePkce.value,
                'allow_offline_access': allowOfflineAccess.value,
              }
            : null,
      };
      try {
        showLoadingModal(context);
        if (isNew) {
          await client.post(
            '/develop/developers/$publisherName/projects/$projectId/apps',
            data: data,
          );
        } else {
          await client.patch(
            '/develop/developers/$publisherName/projects/$projectId/apps/$id',
            data: data,
          );
        }
      } catch (err) {
        showErrorAlert(err);
        return;
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
      ref.invalidate(customAppsProvider(publisherName, projectId));
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    final bodyContent = app == null && !isNew
        ? const Center(child: CircularProgressIndicator())
        : app?.hasError == true && !isNew
        ? ResponseErrorWidget(
            error: app!.error,
            onRetry: () => ref.invalidate(
              customAppProvider(publisherName, projectId, id!),
            ),
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
                        decoration: InputDecoration(
                          labelText: 'name'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
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
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description'.tr(),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        maxLines: 3,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          switch (index) {
                            case 0:
                              enableLinks.value = isExpanded;
                              break;
                            case 1:
                              oauthEnabled.value = isExpanded;
                              break;
                          }
                        },
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) =>
                                ListTile(title: Text('appLinks').tr()),
                            body: Column(
                              spacing: 16,
                              children: [
                                TextFormField(
                                  controller: homePageController,
                                  decoration: InputDecoration(
                                    labelText: 'homePageUrl'.tr(),
                                    hintText: 'https://example.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.url,
                                ),
                                TextFormField(
                                  controller: privacyPolicyController,
                                  decoration: InputDecoration(
                                    labelText: 'privacyPolicyUrl'.tr(),
                                    hintText: 'https://example.com/privacy',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.url,
                                ),
                                TextFormField(
                                  controller: termsController,
                                  decoration: InputDecoration(
                                    labelText: 'termsOfServiceUrl'.tr(),
                                    hintText: 'https://example.com/terms',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.url,
                                ),
                              ],
                            ).padding(horizontal: 16, bottom: 24),
                            isExpanded: enableLinks.value,
                          ),
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) =>
                                ListTile(title: Text('oauthConfig').tr()),
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('redirectUris'.tr()),
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      ...redirectUris.value.map(
                                        (uri) => ListTile(
                                          title: Text(uri),
                                          trailing: IconButton(
                                            icon: const Icon(Symbols.delete),
                                            onPressed: () {
                                              redirectUris.value = redirectUris
                                                  .value
                                                  .where((u) => u != uri)
                                                  .toList();
                                            },
                                          ),
                                        ),
                                      ),
                                      if (redirectUris.value.isNotEmpty)
                                        const Divider(height: 1),
                                      ListTile(
                                        leading: const Icon(Symbols.add),
                                        title: Text('addRedirectUri'.tr()),
                                        onTap: showAddRedirectUriDialog,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('allowedScopes'.tr()),
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      ...allowedScopes.value.map(
                                        (scope) => ListTile(
                                          title: Text(scope),
                                          trailing: IconButton(
                                            icon: const Icon(Symbols.delete),
                                            onPressed: () {
                                              allowedScopes.value =
                                                  allowedScopes.value
                                                      .where((s) => s != scope)
                                                      .toList();
                                            },
                                          ),
                                        ),
                                      ),
                                      if (allowedScopes.value.isNotEmpty)
                                        const Divider(height: 1),
                                      ListTile(
                                        leading: const Icon(Symbols.add),
                                        title: Text('add').tr(),
                                        onTap: showAddScopeDialog,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SwitchListTile(
                                  title: Text('requirePkce'.tr()),
                                  value: requirePkce.value,
                                  onChanged: (value) =>
                                      requirePkce.value = value,
                                ),
                                SwitchListTile(
                                  title: Text('allowOfflineAccess'.tr()),
                                  value: allowOfflineAccess.value,
                                  onChanged: (value) =>
                                      allowOfflineAccess.value = value,
                                ),
                              ],
                            ).padding(horizontal: 16, bottom: 24),
                            isExpanded: oauthEnabled.value,
                          ),
                        ],
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
          );

    if (isModal) {
      return bodyContent;
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(isNew ? 'createCustomApp'.tr() : 'editCustomApp'.tr()),
      ),
      body: bodyContent,
    );
  }
}
