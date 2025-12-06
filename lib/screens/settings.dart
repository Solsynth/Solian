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
import 'package:island/pods/userinfo.dart';
import 'package:island/services/color_extraction.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/drive/file_pool.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  String _getLanguageDisplayName(Locale locale) {
    switch ('${locale.languageCode}-${locale.countryCode}') {
      case 'en-US':
        return 'English (US)';
      case 'es-ES':
        return 'Español (España)';
      case 'ja-JP':
        return '日本語 (日本)';
      case 'ko-KR':
        return '한국어 (대한민국)';
      case 'zh-CN':
        return '简体中文';
      case 'zh-OG':
        return '文言文 (华夏)';
      case 'zh-TW':
        return '繁體中文 (台灣)';
      default:
        return '${locale.languageCode}-${locale.countryCode}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final controller = TextEditingController(text: serverUrl);
    final settings = ref.watch(appSettingsProvider);
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final isWide = isWideScreen(context);
    final pools = ref.watch(poolsProvider);
    final user = ref.watch(userInfoProvider);
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
                  child: Text(_getLanguageDisplayName(ele)).fontSize(14),
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

      // Theme mode settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsThemeMode').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.dark_mode),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownMenuItem<String>(
                value: 'system',
                child: Text('settingsThemeModeSystem').tr().fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'light',
                child: Text('settingsThemeModeLight').tr().fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'dark',
                child: Text('settingsThemeModeDark').tr().fontSize(14),
              ),
            ],
            value: settings.themeMode,
            onChanged: (String? value) {
              if (value != null) {
                ref.read(appSettingsProvider.notifier).setThemeMode(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
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
                  ref.read(appSettingsProvider.notifier).setCustomFonts(null);
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
                  .read(appSettingsProvider.notifier)
                  .setCustomFonts(value.isEmpty ? null : value);
              showSnackBar('settingsApplied'.tr());
            },
          ),
        ),
      ),

      // Message display style settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsMessageDisplayStyle').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.chat),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownMenuItem<String>(
                value: 'bubble',
                child: Text('Bubble').fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'column',
                child: Text('Column').fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'compact',
                child: Text('Compact').fontSize(14),
              ),
            ],
            value: settings.messageDisplayStyle,
            onChanged: (String? value) {
              if (value != null) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setMessageDisplayStyle(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 40),
          ),
        ),
      ),

      // Color scheme settings
      Theme(
        data: Theme.of(
          context,
        ).copyWith(listTileTheme: ListTileThemeData(minLeadingWidth: 48)),
        child: ExpansionTile(
          title: Text('settingsColorScheme').tr(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.palette),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seed color picker
            ListTile(
              title: Text('Seed Color').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              trailing: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Color selectedColor = settings.appColorScheme != null
                          ? Color(settings.appColorScheme!)
                          : Colors.indigo;

                      return AlertDialog(
                        title: Text('Seed Color').tr(),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            paletteType: PaletteType.hsv,
                            enableAlpha: true,
                            showLabel: true,
                            hexInputBar: true,
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
                                  .read(appSettingsProvider.notifier)
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
                    color: settings.appColorScheme != null
                        ? Color(settings.appColorScheme!)
                        : Colors.indigo,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Custom colors section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Custom Colors',
                style: Theme.of(context).textTheme.titleMedium,
              ).bold(),
            ),
            // Primary color
            _ColorPickerTile(
              title: 'Primary',
              color: settings.customColors?.primary != null
                  ? Color(settings.customColors!.primary!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(current.copyWith(primary: color?.value));
              },
            ),
            // Secondary
            _ColorPickerTile(
              title: 'Secondary',
              color: settings.customColors?.secondary != null
                  ? Color(settings.customColors!.secondary!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(current.copyWith(secondary: color?.value));
              },
            ),
            // Tertiary
            _ColorPickerTile(
              title: 'Tertiary',
              color: settings.customColors?.tertiary != null
                  ? Color(settings.customColors!.tertiary!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(current.copyWith(tertiary: color?.value));
              },
            ),
            // Surface
            _ColorPickerTile(
              title: 'Surface',
              color: settings.customColors?.surface != null
                  ? Color(settings.customColors!.surface!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(current.copyWith(surface: color?.value));
              },
            ),
            // Background
            _ColorPickerTile(
              title: 'Background',
              color: settings.customColors?.background != null
                  ? Color(settings.customColors!.background!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(
                      current.copyWith(background: color?.value),
                    );
              },
            ),
            // Error
            _ColorPickerTile(
              title: 'Error',
              color: settings.customColors?.error != null
                  ? Color(settings.customColors!.error!)
                  : null,
              onColorChanged: (color) {
                final current = settings.customColors ?? ThemeColors();
                ref
                    .read(appSettingsProvider.notifier)
                    .setCustomColors(current.copyWith(error: color?.value));
              },
            ),
            // Reset custom colors
            ListTile(
              title: Text('Reset Custom Colors').tr(),
              trailing: const Icon(Symbols.restart_alt).padding(right: 2),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setCustomColors(null);
                showSnackBar('settingsApplied'.tr());
              },
            ),
          ],
        ),
      ),

      // FAB position settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('fabLocation').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.adjust),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownMenuItem<String>(
                value: 'left',
                child: Text('Left').fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'center',
                child: Text('Center').fontSize(14),
              ),
              DropdownMenuItem<String>(
                value: 'right',
                child: Text('Right').fontSize(14),
              ),
            ],
            value: settings.fabPosition,
            onChanged: (String? value) {
              if (value != null) {
                ref.read(appSettingsProvider.notifier).setFabPosition(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 120,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 40),
          ),
        ),
      ),

      // Card background opacity settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsCardBackgroundOpacity').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.opacity),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Slider(
            value: settings.cardTransparency,
            min: 0.0,
            max: 1.0,
            year2023: true,
            padding: EdgeInsets.only(right: 24),
            label: '${(settings.cardTransparency * 100).round()}%',
            onChanged: (value) {
              ref
                  .read(appSettingsProvider.notifier)
                  .setAppTransparentBackground(value);
            },
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
          future: File(
            '${docBasepath.value}/$kAppBackgroundImagePath',
          ).exists(),
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
                      .read(appSettingsProvider.notifier)
                      .setShowBackgroundImage(value);
                },
              ),
            );
          },
        ),

      // Clear background image option
      if (!kIsWeb && docBasepath.value != null)
        FutureBuilder<bool>(
          future: File(
            '${docBasepath.value}/$kAppBackgroundImagePath',
          ).exists(),
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
          future: File(
            '${docBasepath.value}/$kAppBackgroundImagePath',
          ).exists(),
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
                    .read(appSettingsProvider.notifier)
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

      if (user.value != null)
        pools.when(
          data: (data) {
            final validPools = data;
            final currentPoolId = resolveDefaultPoolId(ref, data);

            return ListTile(
              isThreeLine: true,
              minLeadingWidth: 48,
              title: Text('settingsDefaultPool').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.cloud),
              subtitle: Text(
                'settingsDefaultPoolHelper'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  items: validPools.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Tooltip(
                        message: p.name,
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).fontSize(14),
                      ),
                    );
                  }).toList(),
                  value: currentPoolId,
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDefaultPoolId(value);
                    showSnackBar('settingsApplied'.tr());
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    height: 40,
                    width: 120,
                  ),
                  menuItemStyleData: const MenuItemStyleData(height: 40),
                ),
              ),
            );
          },
          loading: () => const ListTile(
            minLeadingWidth: 48,
            title: Text('Loading pools...'),
            leading: CircularProgressIndicator(),
          ),
          error: (err, st) => ListTile(
            minLeadingWidth: 48,
            title: Text('settingsDefaultPool').tr(),
            subtitle: Text('Error: $err'),
            leading: const Icon(Icons.error, color: Colors.red),
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
            ref.read(appSettingsProvider.notifier).setAutoTranslate(value);
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
            ref.read(appSettingsProvider.notifier).setSoundEffects(value);
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
            ref.read(appSettingsProvider.notifier).setAprilFoolFeatures(value);
          },
        ),
      ),

      // Enter to send settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsEnterToSend').tr(),
        subtitle: isDesktop
            ? Text('settingsEnterToSendDesktopHint').tr().fontSize(12)
            : null,
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.send),
        trailing: Switch(
          value: settings.enterToSend,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setEnterToSend(value);
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
            ref.read(appSettingsProvider.notifier).setAppBarTransparent(value);
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
            ref.read(appSettingsProvider.notifier).setDataSavingMode(value);
          },
        ),
      ),

      // Disable animation settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsDisableAnimation').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.animation),
        trailing: Switch(
          value: settings.disableAnimation,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setDisableAnimation(value);
          },
        ),
      ),
    ];

    // Desktop-specific settings
    final desktopSettings = !isDesktop
        ? <Widget>[]
        : [
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsWindowOpacity').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.opacity),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Slider(
                  value: settings.windowOpacity,
                  min: 0.1,
                  max: 1.0,
                  year2023: true,
                  padding: EdgeInsets.only(right: 24),
                  label: '${(settings.windowOpacity * 100).round()}%',
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setWindowOpacity(value);
                  },
                ),
              ),
            ),
          ];

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

// Helper widget for color picker tiles
class _ColorPickerTile extends StatelessWidget {
  final String title;
  final Color? color;
  final ValueChanged<Color?> onColorChanged;

  const _ColorPickerTile({
    required this.title,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      trailing: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              Color selectedColor = color ?? Colors.transparent;

              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    paletteType: PaletteType.hsv,
                    enableAlpha: true,
                    showLabel: true,
                    hexInputBar: true,
                    pickerColor: selectedColor,
                    onColorChanged: (newColor) {
                      selectedColor = newColor;
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
                      onColorChanged(selectedColor);
                      Navigator.of(context).pop();
                    },
                    child: Text('confirm').tr(),
                  ),
                  TextButton(
                    onPressed: () {
                      onColorChanged(null);
                      Navigator.of(context).pop();
                    },
                    child: Text('Reset').tr(),
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
            color: color ?? Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
