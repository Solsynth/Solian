import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/screens/apps.dart';
import 'package:island/developers/models/custom_app.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/wallets/wallet.dart';

part 'edit_app.g.dart';

@riverpod
Future<CustomApp?> customApp(Ref ref,
    String publisherName,
    String projectId,
    String id,) async {
  final client = ref
      .watch(solarNetworkClientProvider)
      .dio;
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/apps/$id',
  );
  return CustomApp.fromJson(resp.data);
}

@RoutePage()
class DeveloperAppEditScreen extends HookConsumerWidget {
  final String pubName;
  final String projectId;
  final String? id;
  final bool isModal;

  const DeveloperAppEditScreen({
    super.key,
    required this.pubName,
    required this.projectId,
    this.id,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final app = isNew
        ? null
        : ref.watch(customAppProvider(pubName, projectId, id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final submitting = useState(false);

    final nameController = useTextEditingController();
    final slugController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);

    final enableLinks = useState(false);
    final homePageController = useTextEditingController();
    final privacyPolicyController = useTextEditingController();
    final termsController = useTextEditingController();
    final oauthEnabled = useState(false);
    final paymentEnabled = useState(false);
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
    final isPublicClient = useState(false);
    final paymentWalletId = useState<String?>(null);

    final wallets = ref.watch(walletListProvider);

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
        paymentWalletId.value = app.value!.paymentWalletId;
        if (app.value!.oauthConfig != null) {
          oauthEnabled.value = true;
          redirectUris.value = app.value!.oauthConfig!.redirectUris;
          postLogoutUris.value =
              app.value!.oauthConfig!.postLogoutRedirectUris ?? [];
          allowedScopes.value = app.value!.oauthConfig!.allowedScopes;
          allowedGrantTypes.value = app.value!.oauthConfig!.allowedGrantTypes;
          requirePkce.value = app.value!.oauthConfig!.requirePkce;
          allowOfflineAccess.value = app.value!.oauthConfig!.allowOfflineAccess;
          isPublicClient.value = app.value!.oauthConfig!.isPublicClient;
        }
      }
      return null;
    }, [app]);

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

    void showAddScopeDialog() {
      final scopeController = TextEditingController();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            SheetScaffold(
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
        builder: (context) =>
            SheetScaffold(
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
      final client = ref
          .read(solarNetworkClientProvider)
          .dio;
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
          'is_public_client': isPublicClient.value,
        }
            : null,
        'payment_wallet_id': paymentWalletId.value,
      };
      try {
        showLoadingModal(context);
        if (isNew) {
          await client.post(
            '/develop/developers/$pubName/projects/$projectId/apps',
            data: data,
          );
        } else {
          await client.patch(
            '/develop/developers/$pubName/projects/$projectId/apps/$id',
            data: data,
          );
        }
      } catch (err) {
        showErrorAlert(err);
        return;
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
      ref.invalidate(customAppsProvider(pubName, projectId));
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    final bodyContent = app == null && !isNew
        ? const Center(child: CircularProgressIndicator())
        : app?.hasError == true && !isNew
        ? ResponseErrorWidget(
      error: app!.error,
      onRetry: () =>
          ref.invalidate(customAppProvider(pubName, projectId, id!)),
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
                    color: Theme
                        .of(
                      context,
                    )
                        .colorScheme
                        .surfaceContainerHigh,
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
                      case 2:
                        paymentEnabled.value = isExpanded;
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
                                      (uri) =>
                                      ListTile(
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
                                      (scope) =>
                                      ListTile(
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
                            title: const Text('Public client (PKCE-only)'),
                            subtitle: const Text(
                              'For SPA/mobile/desktop apps without a client secret.',
                            ),
                            value: isPublicClient.value,
                            onChanged: (value) =>
                            isPublicClient.value = value,
                          ),
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
                    ExpansionPanel(
                      headerBuilder: (context, isExpanded) =>
                          ListTile(title: Text('paymentConfig'.tr())),
                      body: wallets.when(
                        data: (walletList) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('paymentWalletDescription'.tr()),
                              const Gap(16),
                              DropdownButtonFormField<String>(
                                value: paymentWalletId.value,
                                decoration: InputDecoration(
                                  labelText: 'paymentWallet'.tr(),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('none'.tr()),
                                  ),
                                  ...walletList.map((wallet) {
                                    final balance = wallet.pockets.isNotEmpty
                                        ? wallet.pockets.first.amount
                                        : 0.0;
                                    return DropdownMenuItem(
                                      value: wallet.id,
                                      child: Text(
                                        '${wallet.name.isNotEmpty ? wallet.name : 'Default Wallet'} (${balance.toStringAsFixed(2)})',
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  paymentWalletId.value = value;
                                },
                              ),
                            ],
                          ).padding(horizontal: 16, bottom: 24);
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('error: $error'),
                        ),
                      ),
                      isExpanded: paymentEnabled.value,
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
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(isNew ? 'createCustomApp'.tr() : 'editCustomApp'.tr()),
      ),
      body: bodyContent,
    );
  }
}
