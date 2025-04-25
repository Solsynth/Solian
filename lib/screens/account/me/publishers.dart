import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'publishers.g.dart';

@riverpod
Future<List<SnPublisher>> publishersManaged(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/publishers');
  return resp.data
      .map((e) => SnPublisher.fromJson(e))
      .cast<SnPublisher>()
      .toList();
}

@RoutePage()
class ManagedPublisherScreen extends HookConsumerWidget {
  const ManagedPublisherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text('publishers').tr(),
        leading: const PageBackButton(),
      ),
      body: RefreshIndicator(
        child: publishers.when(
          data:
              (value) => Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.plus),
                    title: Text('Create a publisher').tr(),
                    subtitle: Text('To create posts, collections, etc.'),
                    trailing: const Icon(LucideIcons.chevronRight),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () {
                      context.router.push(NewPublisherRoute());
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: value.length,
                      itemBuilder: (context, item) {
                        return ListTile(
                          leading: ProfilePictureWidget(
                            item: value[item].picture,
                          ),
                          title: Text(value[item].nick),
                          subtitle: Text('@${value[item].name}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(LucideIcons.trash, size: 16),
                                onPressed: () {
                                  showConfirmAlert(
                                    'deletePublisherHint'.tr(),
                                    'deletePublisher'.tr(
                                      args: ['@${value[item].name}'],
                                    ),
                                  ).then((confirm) {
                                    if (confirm) {
                                      final client = ref.watch(
                                        apiClientProvider,
                                      );
                                      client.delete(
                                        '/publishers/${value[item].name}',
                                      );
                                      ref.invalidate(publishersManagedProvider);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(LucideIcons.edit, size: 16),
                                onPressed: () {
                                  context.router
                                      .push(
                                        EditPublisherRoute(
                                          name: value[item].name,
                                        ),
                                      )
                                      .then((value) {
                                        if (value != null) {
                                          ref.invalidate(
                                            publishersManagedProvider,
                                          );
                                        }
                                      });
                                },
                              ),
                            ],
                          ),
                          contentPadding: EdgeInsets.only(left: 16, right: 14),
                        );
                      },
                    ),
                  ),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => GestureDetector(
                child: Center(
                  child: Text('Error: $e', textAlign: TextAlign.center),
                ),
                onTap: () {
                  ref.invalidate(publishersManagedProvider);
                },
              ),
        ),
        onRefresh: () => ref.refresh(publishersManagedProvider.future),
      ),
    );
  }
}

@riverpod
Future<SnPublisher?> publisher(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/publishers/$identifier');
  return SnPublisher.fromJson(resp.data);
}

@RoutePage()
class NewPublisherScreen extends StatelessWidget {
  const NewPublisherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditPublisherScreen(key: key);
  }
}

@RoutePage()
class EditPublisherScreen extends HookConsumerWidget {
  final String? name;
  const EditPublisherScreen({super.key, @PathParam('id') this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    final picture = useState<SnCloudFile?>(null);
    final background = useState<SnCloudFile?>(null);

    void setPicture(String position) async {
      final result = await ref
          .read(imagePickerProvider)
          .pickImage(source: ImageSource.gallery);
      if (result == null) return;

      submitting.value = true;
      try {
        final baseUrl = ref.watch(serverUrlProvider);
        final atk = await getFreshAtk(
          ref.watch(tokenPairProvider),
          baseUrl,
          onRefreshed: (atk, rtk) {
            setTokenPair(ref.watch(sharedPreferencesProvider), atk, rtk);
            ref.invalidate(tokenPairProvider);
          },
        );
        if (atk == null) throw ArgumentError('Access token is null');
        final cloudFile =
            await putMediaToCloud(
              fileData: result,
              atk: atk,
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
        submitting.value = false;
      }
    }

    final publisher = ref.watch(publisherProvider(name));

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final nameController = useTextEditingController(
      text: publisher.value?.name,
    );
    final nickController = useTextEditingController(
      text: publisher.value?.nick,
    );
    final bioController = useTextEditingController(text: publisher.value?.bio);

    useEffect(() {
      if (publisher.value != null) {
        picture.value = publisher.value!.picture;
        background.value = publisher.value!.background;
        nameController.text = publisher.value!.name;
        nickController.text = publisher.value!.nick;
        bioController.text = publisher.value!.bio;
      }
      return null;
    }, [publisher]);

    Future<void> performAction() async {
      if (!formKey.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.request(
          name == null ? '/publishers' : '/publishers/$name',
          data: {
            'name': nameController.text,
            'nick': nickController.text,
            'bio': bioController.text,
            'picture_id': picture.value?.id,
            'background_id': background.value?.id,
          },
          options: Options(method: name == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          context.maybePop(SnPublisher.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(name == null ? 'createPublisher' : 'editPublisher').tr(),
        leading: const PageBackButton(),
      ),
      body: Column(
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
                      item: picture.value,
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
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextFormField(
                  controller: nickController,
                  decoration: InputDecoration(labelText: 'nickname'.tr()),
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextFormField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: 'bio'.tr()),
                  minLines: 3,
                  maxLines: null,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final user = ref.watch(userInfoProvider);
                        nameController.text = user.value!.name;
                        nickController.text = user.value!.nick;
                        bioController.text = user.value!.profile.bio ?? '';
                        picture.value = user.value!.profile.picture;
                        background.value = user.value!.profile.background;
                      },
                      label: Text('syncPublisher'.tr()),
                      icon: const Icon(LucideIcons.refreshCcw),
                    ),
                    TextButton.icon(
                      onPressed: submitting.value ? null : performAction,
                      label: Text('saveChanges'.tr()),
                      icon: const Icon(LucideIcons.save),
                    ),
                  ],
                ),
              ],
            ).padding(horizontal: 24),
          ),
        ],
      ),
    );
  }
}
