import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/color_extraction.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/pods/config.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final controller = TextEditingController(text: serverUrl);
    final settings = ref.watch(appSettingsNotifierProvider);
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final isWide = isWideScreen(context);

    final docBasepath = useState<String?>(null);

    useEffect(() {
      getApplicationSupportDirectory().then((dir) {
        docBasepath.value = dir.path;
      });
      return null;
    }, []);

    // Group settings into categories for better organization
    final appearanceSettings = [
      // Language settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsDisplayLanguage').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.translate),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<Locale?>(
            isExpanded: true,
            items: [
              ...EasyLocalization.of(context)!.supportedLocales.mapIndexed((
                idx,
                ele,
              ) {
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

      // Custom fonts settings
      ListTile(
        isThreeLine: true,
        minLeadingWidth: 48,
        title: Text('settingsCustomFonts').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.font_download),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: TextField(
            controller: TextEditingController(text: settings.customFonts),
            decoration: InputDecoration(
              hintText: 'Nunito, Arial, sans-serif',
              helperText: 'settingsCustomFontsHelper'.tr(),
              suffixIcon: IconButton(
                icon: const Icon(Symbols.restart_alt),
                onPressed: () {
                  ref
                      .read(appSettingsNotifierProvider.notifier)
                      .setCustomFonts(null);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            onSubmitted: (value) {
              ref
                  .read(appSettingsNotifierProvider.notifier)
                  .setCustomFonts(value.isEmpty ? null : value);
              showSnackBar('settingsApplied'.tr());
            },
          ),
        ),
      ),

      // Color scheme settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsColorScheme').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.palette),
        trailing: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color selectedColor =
                    settings.appColorScheme != null
                        ? Color(settings.appColorScheme!)
                        : Colors.indigo;

                return AlertDialog(
                  title: Text('settingsColorScheme').tr(),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      paletteType: PaletteType.rgbWithBlue,
                      enableAlpha: false,
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        selectedColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('cancel').tr(),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(appSettingsNotifierProvider.notifier)
                            .setAppColorScheme(selectedColor.value);
                        Navigator.of(context).pop();
                      },
                      child: Text('confirm').tr(),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            decoration: BoxDecoration(
              color:
                  settings.appColorScheme != null
                      ? Color(settings.appColorScheme!)
                      : Colors.indigo,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ),

      // Background image settings (only for non-web platforms)
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
              showSnackBar('settingsApplied'.tr());
            }
          },
        ),

      // Background image enabled
      if (!kIsWeb && docBasepath.value != null)
        FutureBuilder<bool>(
          future:
              File('${docBasepath.value}/$kAppBackgroundImagePath').exists(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const SizedBox.shrink();
            }

            return ListTile(
              minLeadingWidth: 48,
              title: Text('settingsBackgroundImageEnable').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.image),
              trailing: Switch(
                value: settings.showBackgroundImage,
                onChanged: (value) {
                  ref
                      .read(appSettingsNotifierProvider.notifier)
                      .setShowBackgroundImage(value);
                },
              ),
            );
          },
        ),

      // Clear background image option
      if (!kIsWeb && docBasepath.value != null)
        FutureBuilder<bool>(
          future:
              File('${docBasepath.value}/$kAppBackgroundImagePath').exists(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const SizedBox.shrink();
            }

            return ListTile(
              minLeadingWidth: 48,
              title: Text('settingsBackgroundImageClear').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.texture),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                File(
                  '${docBasepath.value}/$kAppBackgroundImagePath',
                ).deleteSync();
                prefs.remove(kAppBackgroundStoreKey);
                ref.invalidate(backgroundImageFileProvider);
                if (context.mounted) {
                  showSnackBar('settingsApplied'.tr());
                }
              },
            );
          },
        ),

      if (!kIsWeb && docBasepath.value != null)
        FutureBuilder(
          future:
              File('${docBasepath.value}/$kAppBackgroundImagePath').exists(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return const SizedBox.shrink();
            }

            return ListTile(
              minLeadingWidth: 48,
              title: Text('settingsBackgroundGenerateColor').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.format_color_fill),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () async {
                showLoadingModal(context);
                final colors = await ColorExtractionService.getColorsFromImage(
                  FileImage(
                    File('${docBasepath.value}/$kAppBackgroundImagePath'),
                  ),
                );
                if (colors.isEmpty) {
                  if (context.mounted) hideLoadingModal(context);
                  showErrorAlert(
                    'Unable to calculate the dominant color of the background image.',
                  );
                  return;
                }
                if (!context.mounted) return;
                final colorScheme = ColorScheme.fromSeed(
                  seedColor: colors.first,
                );
                final color =
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? colorScheme.primary
                        : colorScheme.primary;
                ref
                    .read(appSettingsNotifierProvider.notifier)
                    .setAppColorScheme(color.value);
                if (context.mounted) {
                  hideLoadingModal(context);
                  showSnackBar('settingsApplied'.tr());
                }
              },
            );
          },
        ),
    ];

    final serverSettings = [
      // Server URL settings
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
                  showSnackBar('settingsApplied'.tr());
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
                showSnackBar('settingsApplied'.tr());
              }
            },
          ),
        ),
      ),
    ];

    final behaviorSettings = [
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsAutoTranslate').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.translate),
        trailing: Switch(
          value: settings.autoTranslate,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setAutoTranslate(value);
          },
        ),
      ),

      // Sound effects settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsSoundEffects').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.volume_up),
        trailing: Switch(
          value: settings.soundEffects,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setSoundEffects(value);
          },
        ),
      ),

      // April Fool features settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsAprilFoolFeatures').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.celebration),
        trailing: Switch(
          value: settings.aprilFoolFeatures,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setAprilFoolFeatures(value);
          },
        ),
      ),

      // Enter to send settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsEnterToSend').tr(),
        subtitle:
            isDesktop
                ? Text('settingsEnterToSendDesktopHint').tr().fontSize(12)
                : null,
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.send),
        trailing: Switch(
          value: settings.enterToSend,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setEnterToSend(value);
          },
        ),
      ),

      // Transparent app bar settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsTransparentAppBar').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.blur_on),
        trailing: Switch(
          value: settings.appBarTransparent,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setAppBarTransparent(value);
          },
        ),
      ),
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsDataSavingMode').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.data_saver_on_rounded),
        trailing: Switch(
          value: settings.dataSavingMode,
          onChanged: (value) {
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setDataSavingMode(value);
          },
        ),
      ),
    ];

    // Desktop-specific settings
    // But nothing for now
    final desktopSettings = !isDesktop ? <Widget>[] : <Widget>[];

    // Create a responsive layout based on screen width
    Widget buildSettingsList() {
      if (isWide) {
        // Two-column layout for wide screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    title: 'settingsAppearance'.tr(),
                    children: appearanceSettings,
                  ),
                  _SettingsSection(
                    title: 'settingsServer'.tr(),
                    children: serverSettings,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    title: 'settingsBehavior'.tr(),
                    children: behaviorSettings,
                  ),
                  if (desktopSettings.isNotEmpty)
                    _SettingsSection(
                      title: 'settingsDesktop'.tr(),
                      children: desktopSettings,
                    ),
                ],
              ),
            ),
          ],
        );
      } else {
        // Single column layout for narrow screens
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(
              title: 'settingsAppearance'.tr(),
              children: appearanceSettings,
            ),
            _SettingsSection(
              title: 'settingsServer'.tr(),
              children: serverSettings,
            ),
            _SettingsSection(
              title: 'settingsBehavior'.tr(),
              children: behaviorSettings,
            ),
            if (desktopSettings.isNotEmpty)
              _SettingsSection(
                title: 'settingsDesktop'.tr(),
                children: desktopSettings,
              ),
          ],
        );
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('settings').tr()),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // Add keyboard shortcuts for desktop
          if (isDesktop &&
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            context.pop();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: buildSettingsList(),
        ),
      ),
    );
  }
}

// Helper widget for displaying settings sections with titles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}
