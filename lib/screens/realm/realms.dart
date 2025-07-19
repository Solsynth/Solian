import 'package:croppy/croppy.dart' show CropAspectRatio;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:island/screens/tabs.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'realms.g.dart';

@riverpod
Future<List<SnRealm>> realmsJoined(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/realms');
  return resp.data.map((e) => SnRealm.fromJson(e)).cast<SnRealm>().toList();
}

class RealmListScreen extends HookConsumerWidget {
  const RealmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realms = ref.watch(realmsJoinedProvider);
    final realmInvites = ref.watch(realmInvitesProvider);

    return AppScaffold(
      noBackground: false,
      appBar: AppBar(
        title: const Text('realms').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.travel_explore),
            onPressed: () => context.pushNamed('discoveryRealms'),
          ),
          IconButton(
            icon: Badge(
              label: Text(
                realmInvites.when(
                  data: (invites) => invites.length.toString(),
                  error: (_, _) => '0',
                  loading: () => '0',
                ),
              ),
              isLabelVisible: realmInvites.when(
                data: (invites) => invites.isNotEmpty,
                error: (_, _) => false,
                loading: () => false,
              ),
              child: const Icon(Symbols.email),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (_) => const _RealmInviteSheet(),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: const Key("realms-page-fab"),
        child: const Icon(Symbols.add),
        onPressed: () {
          context.pushNamed('realmNew').then((value) {
            if (value != null) {
              ref.invalidate(realmsJoinedProvider);
            }
          });
        },
      ),
      floatingActionButtonLocation: TabbedFabLocation(context),
      body: RefreshIndicator(
        child: realms.when(
          data:
              (value) => Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: getTabbedPadding(context),
                      itemCount: value.length,
                      itemBuilder: (context, item) {
                        return ListTile(
                          isThreeLine: true,
                          leading: ProfilePictureWidget(
                            fileId: value[item].picture?.id,
                            fallbackIcon: Symbols.group,
                          ),
                          title: Text(value[item].name),
                          subtitle: Text(value[item].description),
                          onTap: () {
                            context.pushNamed(
                              'realmDetail',
                              pathParameters: {'slug': value[item].slug},
                            );
                          },
                          contentPadding: const EdgeInsets.only(
                            left: 16,
                            right: 14,
                            top: 8,
                            bottom: 8,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => ResponseErrorWidget(
                error: e,
                onRetry: () => ref.invalidate(realmsJoinedProvider),
              ),
        ),
        onRefresh: () => ref.refresh(realmsJoinedProvider.future),
      ),
    );
  }
}

@riverpod
Future<SnRealm?> realm(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/realms/$identifier');
  return SnRealm.fromJson(resp.data);
}

class NewRealmScreen extends StatelessWidget {
  const NewRealmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditRealmScreen();
  }
}

class EditRealmScreen extends HookConsumerWidget {
  final String? slug;
  const EditRealmScreen({super.key, this.slug});

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
        final baseUrl = ref.watch(serverUrlProvider);
        final token = await getToken(ref.watch(tokenProvider));
        if (token == null) throw ArgumentError('Access token is null');
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

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          '/sphere${slug == null ? '/realms' : '/realms/$slug'}',
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
          context.pop(SnRealm.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      noBackground: false,
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
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'name'.tr()),
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
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

@riverpod
Future<List<SnRealmMember>> realmInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/realms/invites');
  return resp.data
      .map((e) => SnRealmMember.fromJson(e))
      .cast<SnRealmMember>()
      .toList();
}

class _RealmInviteSheet extends HookConsumerWidget {
  const _RealmInviteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(realmInvitesProvider);

    Future<void> acceptInvite(SnRealmMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/sphere/realms/invites/${invite.realm!.slug}/accept',
        );
        ref.invalidate(realmInvitesProvider);
        ref.invalidate(realmsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnRealmMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/sphere/realms/invites/${invite.realm!.slug}/decline',
        );
        ref.invalidate(realmInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'invites'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(realmInvitesProvider);
          },
        ),
      ],
      child: invites.when(
        data:
            (items) =>
                items.isEmpty
                    ? Center(
                      child:
                          Text(
                            'invitesEmpty',
                            textAlign: TextAlign.center,
                          ).tr(),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final invite = items[index];
                        return ListTile(
                          leading: ProfilePictureWidget(
                            fileId: invite.realm!.picture?.id,
                            fallbackIcon: Symbols.group,
                          ),
                          title: Text(invite.realm!.name),
                          subtitle:
                              Text(
                                invite.role >= 100
                                    ? 'permissionOwner'
                                    : invite.role >= 50
                                    ? 'permissionModerator'
                                    : 'permissionMember',
                              ).tr(),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Symbols.check),
                                onPressed: () => acceptInvite(invite),
                              ),
                              IconButton(
                                icon: const Icon(Symbols.close),
                                onPressed: () => declineInvite(invite),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(realmInvitesProvider),
            ),
      ),
    );
  }
}
