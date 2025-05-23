import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/pods/config.dart';

@RoutePage()
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final controller = TextEditingController(text: serverUrl);
    final settings = ref.watch(appSettingsProvider);

    final docBasepath = useState<String?>(null);

    useEffect(() {
      getApplicationSupportDirectory().then((dir) {
        docBasepath.value = dir.path;
      });
      return null;
    }, []);

    return AppScaffold(
      noBackground: false,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsDisplayLanguage').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.translate),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton2<Locale?>(
                  isExpanded: true,
                  items: [
                    ...EasyLocalization.of(
                      context,
                    )!.supportedLocales.mapIndexed((idx, ele) {
                      return DropdownMenuItem<Locale?>(
                        value: ele,
                        child: Text(
                          '${ele.languageCode}-${ele.countryCode}',
                        ).fontSize(14),
                      );
                    }),
                    DropdownMenuItem<Locale?>(
                      value: null,
                      child: Text('languageFollowSystem').tr().fontSize(14),
                    ),
                  ],
                  value: EasyLocalization.of(context)!.currentLocale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      EasyLocalization.of(context)!.setLocale(value);
                    } else {
                      EasyLocalization.of(context)!.resetLocale();
                    }
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    height: 40,
                    width: 160,
                  ),
                  menuItemStyleData: const MenuItemStyleData(height: 40),
                ),
              ),
            ),
            ListTile(
              isThreeLine: true,
              minLeadingWidth: 48,
              title: Text('settingsServerUrl').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.link),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: kNetworkServerDefault,
                    suffixIcon: IconButton(
                      icon: const Icon(Symbols.restart_alt),
                      onPressed: () {
                        controller.text = kNetworkServerDefault;
                        prefs.setString(
                          kNetworkServerStoreKey,
                          kNetworkServerDefault,
                        );
                        ref.invalidate(serverUrlProvider);
                        showSnackBar(context, 'settingsApplied'.tr());
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      prefs.setString(kNetworkServerStoreKey, value);
                      ref.invalidate(serverUrlProvider);
                      showSnackBar(context, 'settingsApplied'.tr());
                    }
                  },
                ),
              ),
            ),
            if (!kIsWeb && docBasepath.value != null)
              ListTile(
                minLeadingWidth: 48,
                title: Text('settingsBackgroundImage').tr(),
                contentPadding: const EdgeInsets.only(left: 24, right: 17),
                leading: const Icon(Symbols.image),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () async {
                  final imagePicker = ref.read(imagePickerProvider);
                  final image = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) return;

                  await File(
                    image.path,
                  ).copy('${docBasepath.value}/$kAppBackgroundImagePath');
                  prefs.setBool(kAppBackgroundStoreKey, true);
                  ref.invalidate(backgroundImageFileProvider);
                  if (context.mounted) {
                    showSnackBar(context, 'settingsApplied'.tr());
                  }
                },
              ),
            if (!kIsWeb && docBasepath.value != null)
              FutureBuilder<bool>(
                future:
                    File('${docBasepath.value}/app_background_image').exists(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text('settingsBackgroundImageClear').tr(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Symbols.texture),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () {
                      File(
                        '${docBasepath.value}/$kAppBackgroundImagePath',
                      ).deleteSync();
                      prefs.remove(kAppBackgroundStoreKey);
                      ref.invalidate(backgroundImageFileProvider);
                      if (context.mounted) {
                        showSnackBar(context, 'settingsApplied'.tr());
                      }
                    },
                  );
                },
              ),
            const Divider(),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsRealmCompactView').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.view_compact),
              trailing: Switch(
                value: settings.realmCompactView,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setRealmCompactView(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsMixedFeed').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.merge),
              trailing: Switch(
                value: settings.mixedFeed,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setMixedFeed(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsAutoTranslate').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.translate),
              trailing: Switch(
                value: settings.autoTranslate,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setAutoTranslate(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsHideBottomNav').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.navigation),
              trailing: Switch(
                value: settings.hideBottomNav,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setHideBottomNav(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsSoundEffects').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.volume_up),
              trailing: Switch(
                value: settings.soundEffects,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setSoundEffects(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsAprilFoolFeatures').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.celebration),
              trailing: Switch(
                value: settings.aprilFoolFeatures,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setAprilFoolFeatures(value);
                },
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsEnterToSend').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.send),
              trailing: Switch(
                value: settings.enterToSend,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setEnterToSend(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
