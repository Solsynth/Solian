import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class UpdateProfileScreen extends HookConsumerWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    final submitting = useState(false);

    void updateProfilePicture(String position) async {
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
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/accounts/me/profile',
          data: {'${position}_id': cloudFile.id},
        );
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    final formKeyBasicInfo = useMemoized(GlobalKey<FormState>.new, const []);
    final usernameController = useTextEditingController(text: user.value!.name);
    final nicknameController = useTextEditingController(text: user.value!.nick);

    void updateBasicInfo() async {
      if (!formKeyBasicInfo.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/accounts/me',
          data: {
            'name': usernameController.text,
            'nick': nicknameController.text,
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
    final bioController = useTextEditingController(
      text: user.value!.profile.bio,
    );

    void updateProfile() async {
      if (!formKeyProfile.currentState!.validate()) return;

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.patch(
          '/accounts/me/profile',
          data: {'bio': bioController.text},
        );
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
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
      body: Column(
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
                        user.value!.profile.background != null
                            ? CloudFileWidget(
                              item: user.value!.profile.background!,
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
                      item: user.value!.profile.picture,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: submitting.value ? null : updateBasicInfo,
                    label: Text('saveChanges').tr(),
                    icon: const Icon(LucideIcons.save),
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'bio'.tr()),
                  maxLines: null,
                  minLines: 3,
                  controller: bioController,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: submitting.value ? null : updateProfile,
                    label: Text('saveChanges').tr(),
                    icon: const Icon(LucideIcons.save),
                  ),
                ),
              ],
            ).padding(horizontal: 24),
          ),
        ],
      ),
    );
  }
}
