import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/cache_service.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/screens/file_pool.dart';

@RoutePage()
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
                return DropdownItem<Locale?>(
                  value: ele,
                  child: Text(_getLanguageDisplayName(ele)).fontSize(14),
                );
              }),
              DropdownItem<Locale?>(
                value: null,
                child: Text('languageFollowSystem').tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier<Locale?>(
              EasyLocalization.of(context)!.currentLocale,
            ),
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
              DropdownItem<String>(
                value: 'system',
                child: Text('settingsThemeModeSystem').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'light',
                child: Text('settingsThemeModeLight').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'dark',
                child: Text('settingsThemeModeDark').tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier(settings.themeMode),
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
              DropdownItem<String>(
                value: 'bubble',
                child: Text('settingsMessageDisplayStyleBubble').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'column',
                child: Text('settingsMessageDisplayStyleColumn').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'compact',
                child: Text('settingsMessageDisplayStyleCompact').tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier<String>(
              settings.messageDisplayStyle,
            ),
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
          ),
        ),
      ),

      // Attachments list style settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsAttachmentsListStyle').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.attachment),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownItem<String>(
                value: 'row',
                child: Text('settingsAttachmentsListStyleRow').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'column',
                child: Text('settingsAttachmentsListStyleColumn').tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier<String>(
              settings.attachmentsListStyle,
            ),
            onChanged: (String? value) {
              if (value != null) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setAttachmentsListStyle(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
            ),
          ),
        ),
      ),

      // Link collapse mode settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsLinkCollapseMode').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.unfold_more),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownItem<String>(
                value: 'expand',
                child: Text('settingsLinkCollapseModeExpand').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'collapse',
                child: Text(
                  'settingsLinkCollapseModeCollapse',
                ).tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier<String>(settings.linkCollapseMode),
            onChanged: (String? value) {
              if (value != null) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setLinkCollapseMode(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
            ),
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

      // Card background opacity settings
      ListTile(
        isThreeLine: true,
        minLeadingWidth: 48,
        title: Text('settingsCardBackgroundOpacity').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.opacity),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackShape: RoundedRectSliderTrackShape(),
            ),
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
              leading: const Icon(Symbols.hide_image),
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

      // Media Proxy settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsMediaProxy').tr(),
        subtitle: Text('settingsMediaProxyHelper'.tr()),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.speed),
        trailing: Switch(
          value: settings.mediaProxyEnabled,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setMediaProxyEnabled(value);
          },
        ),
      ),

      if (user.value != null)
        pools.when(
          data: (data) {
            final validPools = data;
            final currentPoolId = resolveDefaultPoolId(
              ref.read(appSettingsProvider),
              data,
            );

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
                    return DropdownItem<String>(
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
                  valueListenable: ValueNotifier<String?>(currentPoolId),
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
        title: Text('settingsFestivalFeatures').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.celebration),
        trailing: Switch(
          value: settings.festivalFeatures,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setFeativalFeatures(value);
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

      // Grouped chat list settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsGroupedChatList').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.chat),
        trailing: Switch(
          value: settings.groupedChatList,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setGroupedChatList(value);
          },
        ),
      ),

      // Show chat event/system messages settings
      ListTile(
        minLeadingWidth: 48,
        title: const Text('settingsShowChatEventMessages').tr(),
        subtitle: const Text(
          'ShowChatEventsMessagesHelper',
        ).tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.info),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownItem<String>(
                value: kChatEventMessageModeVerbose,
                child: Text('settingsChatEventMessageModeVerbose').tr(),
              ),
              DropdownItem<String>(
                value: kChatEventMessageModeImportant,
                child: Text('settingsChatEventMessageModeImportant').tr(),
              ),
              DropdownItem<String>(
                value: kChatEventMessageModeNone,
                child: Text('settingsChatEventMessageModeNone').tr(),
              ),
            ],
            valueListenable: ValueNotifier<String>(
              settings.chatEventMessageMode,
            ),
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(appSettingsProvider.notifier)
                  .setChatEventMessageMode(value);
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
            ),
          ),
        ),
      ),

      // Haptic feedback settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsNotifyWithHaptic').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.vibration),
        trailing: Switch(
          value: settings.notifyWithHaptic,
          onChanged: (value) {
            ref.read(appSettingsProvider.notifier).setNotifyWithHaptic(value);
          },
        ),
      ),

      // TTS settings
      Theme(
        data: Theme.of(
          context,
        ).copyWith(listTileTheme: const ListTileThemeData(minLeadingWidth: 48)),
        child: ExpansionTile(
          title: Text('settingsTts').tr(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Symbols.record_voice_over),
          children: [
            ListTile(
              title: Text('settingsEnableTts').tr(),
              trailing: Switch(
                value: settings.enableTts,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setEnableTts(value);
                },
              ),
            ),
            _TtsVoiceSelector(settings: settings, ref: ref),
            _TtsLanguageSelector(settings: settings, ref: ref),
            ListTile(
              title: Text('settingsTtsSpeechRate').tr(),
              subtitle: SliderTheme(
                data: SliderThemeData(year2023: true),
                child: Slider(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  value: settings.ttsSpeechRate,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: settings.ttsSpeechRate.toStringAsFixed(1),
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setTtsSpeechRate(value);
                  },
                ),
              ),
            ),
            ListTile(
              title: Text('settingsTtsPitch').tr(),
              subtitle: SliderTheme(
                data: SliderThemeData(year2023: true),
                child: Slider(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  value: settings.ttsPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: settings.ttsPitch.toStringAsFixed(1),
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setTtsPitch(value);
                  },
                ),
              ),
            ),
            ListTile(
              title: Text('settingsTtsVolume').tr(),
              subtitle: SliderTheme(
                data: SliderThemeData(year2023: true),
                child: Slider(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  value: settings.ttsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(settings.ttsVolume * 100).round()}%',
                  onChanged: (value) {
                    ref.read(appSettingsProvider.notifier).setTtsVolume(value);
                  },
                ),
              ),
            ),
            ListTile(
              title: Text('settingsTtsTest').tr(),
              trailing: const Icon(Icons.play_arrow),
              onTap: () async {
                final tts = FlutterTts();
                await tts.setVolume(settings.ttsVolume);
                await tts.setSpeechRate(settings.ttsSpeechRate);
                await tts.setPitch(settings.ttsPitch);
                if (settings.ttsLanguage.isNotEmpty) {
                  await tts.setLanguage(settings.ttsLanguage);
                }
                if (settings.ttsVoice != null &&
                    settings.ttsVoice!.isNotEmpty) {
                  await tts.setVoice({
                    'name': settings.ttsVoice!,
                    'locale': settings.ttsLanguage,
                  });
                }
                if (!kIsWeb) {
                  await tts.setIosAudioCategory(
                    IosTextToSpeechAudioCategory.ambient,
                    [
                      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
                      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
                      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
                    ],
                    IosTextToSpeechAudioMode.voicePrompt,
                  );
                }
                await tts.speak(
                  'This is a test notification. Title: New message received. Subtitle: From John. Content: Hello, this is a test message.',
                );
              },
            ),
          ],
        ),
      ),

      // Default screen settings
      ListTile(
        minLeadingWidth: 48,
        title: Text('settingsDefaultScreen').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.home),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: [
              DropdownItem<String>(
                value: 'dashboard',
                child: Text('dashboard').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'explore',
                child: Text('explore').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'chat',
                child: Text('chat').tr().fontSize(14),
              ),
              DropdownItem<String>(
                value: 'account',
                child: Text('account').tr().fontSize(14),
              ),
            ],
            valueListenable: ValueNotifier<String>(
              settings.defaultScreen ?? 'dashboard',
            ),
            onChanged: (String? value) {
              if (value != null) {
                ref.read(appSettingsProvider.notifier).setDefaultScreen(value);
                showSnackBar('settingsApplied'.tr());
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              height: 40,
              width: 140,
            ),
          ),
        ),
      ),

      // Dash search engine settings
      ListTile(
        isThreeLine: true,
        minLeadingWidth: 48,
        title: Text('settingsDashSearchEngine').tr(),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.search),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: TextField(
            controller: TextEditingController(text: settings.dashSearchEngine),
            decoration: InputDecoration(
              hintText: 'https://google.com/?q=%s',
              helperText: 'settingsDashSearchEngineHelper'.tr(),
              suffixIcon: IconButton(
                icon: const Icon(Symbols.restart_alt),
                onPressed: () {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setDashSearchEngine(null);
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
                  .setDashSearchEngine(value.isEmpty ? null : value);
              showSnackBar('settingsApplied'.tr());
            },
          ),
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
              isThreeLine: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                    trackShape: RoundedRectSliderTrackShape(),
                  ),
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
            ),            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsFriendStatusDesktopNotification').tr(),
              subtitle: Text('settingsFriendStatusDesktopNotificationHelper'.tr())
                  .fontSize(12),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.notifications_active),
              trailing: Switch(
                value: settings.friendStatusDesktopNotification,
                onChanged: (value) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setFriendStatusDesktopNotification(value);
                },
              ),
            ),

          ];

    // Storage settings
    final storageSettings = [_StorageSettingsSection()];

    // Create a responsive layout based on screen width
    Widget buildSettingsList() {
      if (isWide) {
        // Two-column layout for wide screens
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 16,
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
                  spacing: 16,
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
                    _SettingsSection(
                      title: 'settingsStorage'.tr(),
                      children: storageSettings,
                    ),
                  ],
                ),
              ),
            ],
          ).padding(horizontal: 16),
        ).center();
      } else {
        // Single column layout for narrow screens
        return Column(
          spacing: 16,
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
            _SettingsSection(
              title: 'settingsStorage'.tr(),
              children: storageSettings,
            ),
          ],
        ).padding(horizontal: 16);
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('settings').tr(),
        leading: const AutoLeadingButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: buildSettingsList(),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
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
      ),
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

class _TtsVoiceSelector extends StatefulWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _TtsVoiceSelector({required this.settings, required this.ref});

  @override
  State<_TtsVoiceSelector> createState() => _TtsVoiceSelectorState();
}

class _TtsVoiceSelectorState extends State<_TtsVoiceSelector> {
  List<Map<String, String>> _voices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = FlutterTts();
    final voices = await tts.getVoices;
    final voiceList = <Map<String, String>>[];
    if (voices is List) {
      for (final voice in voices) {
        if (voice is Map) {
          final name = voice['name']?.toString() ?? '';
          final locale = voice['locale']?.toString() ?? '';
          if (name.isNotEmpty) {
            voiceList.add({'name': name, 'locale': locale});
          }
        }
      }
    }
    setState(() {
      _voices = voiceList;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('settingsTtsVoice').tr(),
      trailing: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<String?>(
              value: widget.settings.ttsVoice,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: const Text('System Default'),
                ),
                ..._voices.map((voice) {
                  return DropdownMenuItem<String?>(
                    value: voice['name'],
                    child: Text(
                      '${voice['name']} (${voice['locale']})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                widget.ref
                    .read(appSettingsProvider.notifier)
                    .setTtsVoice(value);
              },
            ),
    );
  }
}

class _TtsLanguageSelector extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _TtsLanguageSelector({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('settingsTtsLanguage').tr(),
      trailing: SizedBox(
        width: 120,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'en-US',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          controller: TextEditingController(text: settings.ttsLanguage),
          onSubmitted: (value) {
            ref.read(appSettingsProvider.notifier).setTtsLanguage(value);
          },
        ),
      ),
    );
  }
}

class _StorageSettingsSection extends StatefulWidget {
  @override
  State<_StorageSettingsSection> createState() =>
      _StorageSettingsSectionState();
}

class _StorageSettingsSectionState extends State<_StorageSettingsSection> {
  DiskSpaceInfo? _diskSpace;
  int _flutterCacheSize = 0;
  int _nativeCacheSize = 0;
  bool _loading = true;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final diskSpace = await CacheService.getDiskSpace();
    final flutterCache = await CacheService.getFlutterCacheSize();
    final nativeCache = await CacheService.getNativeCacheSize();

    if (mounted) {
      setState(() {
        _diskSpace = diskSpace;
        _flutterCacheSize = flutterCache;
        _nativeCacheSize = nativeCache;
        _loading = false;
      });
    }
  }

  Future<void> _clearFlutterCache() async {
    setState(() => _clearing = true);
    await CacheService.clearFlutterCache();
    await _loadStorageInfo();
    setState(() => _clearing = false);
    if (mounted) {
      showSnackBar('settingsCacheCleared'.tr());
    }
  }

  Future<void> _clearNativeCache() async {
    setState(() => _clearing = true);
    await CacheService.clearNativeCache();
    await _loadStorageInfo();
    setState(() => _clearing = false);
    if (mounted) {
      showSnackBar('settingsCacheCleared'.tr());
    }
  }

  Future<void> _clearAllCache() async {
    setState(() => _clearing = true);
    await CacheService.clearAllCaches();
    await _loadStorageInfo();
    setState(() => _clearing = false);
    if (mounted) {
      showSnackBar('settingsCacheCleared'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && Platform.isIOS;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          // Storage usage bar
          if (_diskSpace != null)
            ...([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'settingsStorageUsed'.tr(),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          'settingsStorageUsedPercent'.tr(
                            args: [
                              (_diskSpace!.usedPercentage * 100)
                                  .toStringAsFixed(0),
                            ],
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _diskSpace!.usedPercentage.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${CacheService.formatBytes(_diskSpace!.usedSpace)} / ${CacheService.formatBytes(_diskSpace!.totalSpace)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${'settingsStorageFree'.tr()}: ${CacheService.formatBytes(_diskSpace!.freeSpace)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
            ])
          else
            ...([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'settingsStorageNotAvailable'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Divider(height: 24),
            ]),

          // App Cache section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settingsAppCache'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Flutter cache
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.cached, size: 20),
                  title: Text('settingsFlutterCache'.tr()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CacheService.formatBytes(_flutterCacheSize),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      if (_clearing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: _clearFlutterCache,
                          child: Text('settingsClearCache'.tr()),
                        ),
                    ],
                  ),
                ),
                // Native cache (iOS only)
                if (isIOS)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Symbols.android, size: 20),
                    title: Text('settingsNativeCache'.tr()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CacheService.formatBytes(_nativeCacheSize),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        if (_clearing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton(
                            onPressed: _clearNativeCache,
                            child: Text('settingsClearCache'.tr()),
                          ),
                      ],
                    ),
                  ),
                // Non-iOS: single clear all button
                if (!isIOS && (_flutterCacheSize > 0))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearing ? null : _clearAllCache,
                        icon: _clearing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Symbols.delete_outline),
                        label: Text('settingsClearCache'.tr()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
