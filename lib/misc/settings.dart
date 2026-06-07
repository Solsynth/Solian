import 'dart:async';
import 'dart:convert';
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
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/cache_service.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:island/core/services/desktop_presence.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/misc/connectivity_self_check_screen.dart';
import 'package:island/misc/about_content.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/plugins/screens/plugin_manager_screen.dart';
import 'package:island/route.gr.dart';

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
    final latestReleaseRefreshNonce = useState(0);
    final latestRelease = useFuture(
      useMemoized(() => UpdateService().fetchLatestRelease(), [
        latestReleaseRefreshNonce.value,
      ]),
    );

    useEffect(() {
      getApplicationSupportDirectory().then((dir) {
        docBasepath.value = dir.path;
      });
      return null;
    }, []);

    final selectedCategoryIdx = useState(0);
    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    final categories = <_SettingCategory>[];

    bool matchesQuery(_SettingCategory category, String query) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return category.title.toLowerCase().contains(q) ||
          category.getLocalizedTitle(context).toLowerCase().contains(q) ||
          category.searchTerms.any((term) => term.toLowerCase().contains(q));
    }

    categories.add(
      _SettingCategory(
        icon: Symbols.palette,
        title: 'Appearance',
        localizedTitleKey: 'settingsAppearance',
        searchTerms: [
          'theme',
          'color scheme',
          'opacity',
          'card background',
          'display language',
          'locale',
          'system language',
          'window opacity',
          'custom fonts',
          'typeface',
          'font family',
        ],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'settingsColorScheme'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            title: Text('seedColor').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            trailing: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = settings.appColorScheme != null
                        ? Color(settings.appColorScheme!)
                        : Colors.indigo;

                    return AlertDialog(
                      title: Text('seedColor').tr(),
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
          ExpansionTile(
            title: Text('settingsCustomColors'.tr()),
            tilePadding: const EdgeInsets.fromLTRB(24, 0, 26, 0),
            children: [
              _ColorPickerTile(
                titleKey: 'settingsColorPrimary',
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
              _ColorPickerTile(
                titleKey: 'settingsColorOnPrimary',
                color: settings.customColors?.onPrimary != null
                    ? Color(settings.customColors!.onPrimary!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(onPrimary: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorPrimaryContainer',
                color: settings.customColors?.primaryContainer != null
                    ? Color(settings.customColors!.primaryContainer!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(primaryContainer: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorSecondary',
                color: settings.customColors?.secondary != null
                    ? Color(settings.customColors!.secondary!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(secondary: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorOnSecondary',
                color: settings.customColors?.onSecondary != null
                    ? Color(settings.customColors!.onSecondary!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(onSecondary: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorSecondaryContainer',
                color: settings.customColors?.secondaryContainer != null
                    ? Color(settings.customColors!.secondaryContainer!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(secondaryContainer: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorTertiary',
                color: settings.customColors?.tertiary != null
                    ? Color(settings.customColors!.tertiary!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(tertiary: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorOnTertiary',
                color: settings.customColors?.onTertiary != null
                    ? Color(settings.customColors!.onTertiary!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(onTertiary: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorTertiaryContainer',
                color: settings.customColors?.tertiaryContainer != null
                    ? Color(settings.customColors!.tertiaryContainer!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(tertiaryContainer: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorSurface',
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
              _ColorPickerTile(
                titleKey: 'settingsColorSurfaceContainerHighest',
                color: settings.customColors?.surfaceContainerHighest != null
                    ? Color(settings.customColors!.surfaceContainerHighest!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(
                        current.copyWith(surfaceContainerHighest: color?.value),
                      );
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorBackground',
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
              _ColorPickerTile(
                titleKey: 'settingsColorOutline',
                color: settings.customColors?.outline != null
                    ? Color(settings.customColors!.outline!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(current.copyWith(outline: color?.value));
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorShadow',
                color: settings.customColors?.shadow != null
                    ? Color(settings.customColors!.shadow!)
                    : null,
                onColorChanged: (color) {
                  final current = settings.customColors ?? ThemeColors();
                  ref
                      .read(appSettingsProvider.notifier)
                      .setCustomColors(current.copyWith(shadow: color?.value));
                },
              ),
              _ColorPickerTile(
                titleKey: 'settingsColorError',
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
              ListTile(
                title: Text('settingsResetCustomColors'.tr()),
                trailing: const Icon(Symbols.restart_alt).padding(right: 2),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  ref.read(appSettingsProvider.notifier).setCustomColors(null);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
            ],
          ),
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
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
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
          if (isDesktop)
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
            ),
          if (isDesktop) const Divider(height: 24),
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
                          .read(appSettingsProvider.notifier)
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
                      .read(appSettingsProvider.notifier)
                      .setCustomFonts(value.isEmpty ? null : value);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
            ),
          ),
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.chat,
        title: 'Chat',
        localizedTitleKey: 'settingsCategoryChat',
        searchTerms: [
          'message style',
          'attachments',
          'link collapse',
          'enter to send',
          'grouped chat list',
          'chat event messages',
          'sound effects',
          'festival features',
          'haptic feedback',
          'friend status',
        ],
        children: [
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
                    child: Text(
                      'settingsMessageDisplayStyleBubble',
                    ).tr().fontSize(14),
                  ),
                  DropdownItem<String>(
                    value: 'column',
                    child: Text(
                      'settingsMessageDisplayStyleColumn',
                    ).tr().fontSize(14),
                  ),
                  DropdownItem<String>(
                    value: 'compact',
                    child: Text(
                      'settingsMessageDisplayStyleCompact',
                    ).tr().fontSize(14),
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
                    child: Text(
                      'settingsAttachmentsListStyleRow',
                    ).tr().fontSize(14),
                  ),
                  DropdownItem<String>(
                    value: 'column',
                    child: Text(
                      'settingsAttachmentsListStyleColumn',
                    ).tr().fontSize(14),
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
                    child: Text(
                      'settingsLinkCollapseModeExpand',
                    ).tr().fontSize(14),
                  ),
                  DropdownItem<String>(
                    value: 'collapse',
                    child: Text(
                      'settingsLinkCollapseModeCollapse',
                    ).tr().fontSize(14),
                  ),
                ],
                valueListenable: ValueNotifier<String>(
                  settings.linkCollapseMode,
                ),
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
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsGroupedChatList').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.chat),
            trailing: Switch(
              value: settings.groupedChatList,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setGroupedChatList(value);
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 48,
            title: const Text('settingsShowChatEventMessages').tr(),
            subtitle: const Text('ShowChatEventsMessagesHelper').tr(),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'settingsCategoryNotifications'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
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
            title: Text('settingsFestivalFeatures').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.celebration),
            trailing: Switch(
              value: settings.festivalFeatures,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setFeativalFeatures(value);
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsNotifyWithHaptic').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.vibration),
            trailing: Switch(
              value: settings.notifyWithHaptic,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setNotifyWithHaptic(value);
              },
            ),
          ),
          if (isDesktop)
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsFriendStatusDesktopNotification').tr(),
              subtitle: Text(
                'settingsFriendStatusDesktopNotificationHelper'.tr(),
              ).fontSize(12),
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
        ],
      ),
    );

    if (isDesktop) {
      categories.add(
        _SettingCategory(
          icon: Symbols.desktop_windows,
          title: 'Desktop Presence',
          localizedTitleKey: 'settingsCategoryDesktopPresence',
          searchTerms: [
            'idle status',
            'now playing',
            'desktop presence',
            'activity status',
            'music status',
            'media status',
            'disable presence',
            'turn off presence',
          ],
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'settingsIdleStatus'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsDesktopIdleStatusEnabled').tr(),
              subtitle: Text('settingsDesktopIdleStatusEnabledHelper').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.schedule),
              trailing: Switch(
                value: ref.watch(desktopIdleStatusEnabledProvider),
                onChanged: (value) {
                  ref
                      .read(desktopIdleStatusEnabledProvider.notifier)
                      .setEnabled(value);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
            ),
            _DesktopIdleStatusPreview(),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'settingsNowPlaying'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsDesktopNowPlayingEnabled').tr(),
              subtitle: Text('settingsDesktopNowPlayingEnabledHelper').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.music_note),
              trailing: Switch(
                value: ref.watch(desktopNowPlayingEnabledProvider),
                onChanged: (value) {
                  ref
                      .read(desktopNowPlayingEnabledProvider.notifier)
                      .setEnabled(value);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
            ),
            if (Platform.isMacOS) ...[
              Builder(
                builder: (context) {
                  final status = ref.watch(desktopNowPlayingCliStatusProvider);
                  return ListTile(
                    minLeadingWidth: 48,
                    title: const Text('macOS nowplaying-cli'),
                    subtitle: Text(
                      status.when(
                        data: (value) {
                          final path = value.path ?? '(not configured)';
                          final label = switch (value.availability) {
                            DesktopNowPlayingCliAvailability.installed =>
                              'Installed',
                            DesktopNowPlayingCliAvailability.missing =>
                              'Missing or not executable',
                            DesktopNowPlayingCliAvailability.unsupported =>
                              'Unsupported',
                          };
                          return '$label\n$path';
                        },
                        loading: () => 'Checking availability...',
                        error: (error, _) => 'Failed to check: $error',
                      ),
                    ).fontSize(12),
                    contentPadding: const EdgeInsets.only(left: 24, right: 17),
                    leading: const Icon(Symbols.music_note),
                    trailing: const Icon(Symbols.chevron_right),
                    isThreeLine: true,
                    onTap: () =>
                        _showDesktopNowPlayingCliPathEditor(context, ref),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final reuseFixedManualId = ref.watch(
                    desktopNowPlayingReuseFixedManualIdProvider,
                  );
                  return ListTile(
                    minLeadingWidth: 48,
                    title: Text('settingsNowPlayingReuseFixedManualId').tr(),
                    subtitle: Text(
                      'settingsNowPlayingReuseFixedManualIdHelper',
                    ).tr().fontSize(12),
                    contentPadding: const EdgeInsets.only(left: 24, right: 17),
                    leading: const Icon(Symbols.music_note),
                    trailing: Switch(
                      value: reuseFixedManualId,
                      onChanged: (value) {
                        ref
                            .read(
                              desktopNowPlayingReuseFixedManualIdProvider
                                  .notifier,
                            )
                            .setEnabled(value);
                      },
                    ),
                  );
                },
              ),
            ],
            _DesktopNowPlayingPreview(),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'settingsRpcServer'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsDesktopRpcServerEnabled').tr(),
              subtitle: Text('settingsDesktopRpcServerEnabledHelper').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.dns),
              trailing: Switch(
                value: ref.watch(desktopRpcServerEnabledProvider),
                onChanged: (value) {
                  ref.read(rpcServerStateProvider.notifier).toggleServer(value);
                  showSnackBar('settingsApplied'.tr());
                },
              ),
            ),
            _DesktopRpcServerPreview(),
          ],
        ),
      );
    }

    categories.add(
      _SettingCategory(
        icon: Symbols.image,
        title: 'Background',
        localizedTitleKey: 'settingsCategoryBackground',
        searchTerms: ['background image', 'wallpaper', 'generate color'],
        children: [
          if (!kIsWeb && docBasepath.value != null) ...[
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
                    final colors =
                        await ColorExtractionService.getColorsFromImage(
                          FileImage(
                            File(
                              '${docBasepath.value}/$kAppBackgroundImagePath',
                            ),
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
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
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
          ],
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.link,
        title: 'Connection',
        localizedTitleKey: 'settingsCategoryConnection',
        searchTerms: ['server url', 'media proxy', 'default pool'],
        children: [
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
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsMediaProxy').tr(),
            subtitle: Text('settingsMediaProxyHelper'.tr()),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.speed),
            trailing: Switch(
              value: settings.mediaProxyEnabled,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setMediaProxyEnabled(value);
              },
            ),
          ),
          Builder(
            builder: (context) {
              final ipOverrideMode = ref.watch(ipOverrideModeProvider);
              return ListTile(
                minLeadingWidth: 48,
                title: Text('settingsIpOverride').tr(),
                subtitle: Text(
                  'settingsIpOverrideModeHelper'.tr(
                    args: [_ipOverrideModeLabel(ipOverrideMode)],
                  ),
                ),
                contentPadding: const EdgeInsets.only(left: 24, right: 17),
                leading: const Icon(Symbols.dns),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (_) => _IpOverrideModeSheet(ref: ref),
                  );
                },
              );
            },
          ),
          Builder(
            builder: (context) {
              final domains = ref.watch(ipOverrideDomainsProvider);
              return ListTile(
                minLeadingWidth: 48,
                title: Text('settingsIpOverrideDomains').tr(),
                subtitle: Text(
                  domains.isNotEmpty
                      ? domains.join(', ')
                      : 'settingsIpOverrideDomainsHelper'.tr(),
                ),
                contentPadding: const EdgeInsets.only(left: 24, right: 17),
                leading: const Icon(Symbols.edit),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  _showIpOverrideDomainsEditor(context, ref);
                },
              );
            },
          ),
          Builder(
            builder: (context) {
              final ipOverrideSettings = ref.watch(ipOverrideSettingsProvider);
              return ListTile(
                minLeadingWidth: 48,
                title: Text('settingsIpOverrideEntries').tr(),
                subtitle: Text(
                  ipOverrideSettings.overrides.isNotEmpty
                      ? ipOverrideSettings.overrides
                            .map(
                              (entry) => entry.port == null
                                  ? entry.ip
                                  : '${entry.ip}:${entry.port}',
                            )
                            .join(', ')
                      : 'settingsIpOverrideEntriesEmpty'.tr(),
                ),
                contentPadding: const EdgeInsets.only(left: 24, right: 17),
                leading: const Icon(Symbols.edit),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  _showIpOverrideEntriesEditor(context, ref);
                },
              );
            },
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('cfIpSpeedTest').tr(),
            subtitle: Text('cfIpSpeedTestSubtitle').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.speed),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              context.router.push(const CfIpSpeedTestRoute());
            },
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('connectivitySelfCheck').tr(),
            subtitle: Text('connectivitySelfCheckSubtitle').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.health_and_safety),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConnectivitySelfCheckScreen(),
                ),
              );
            },
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
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
                leading: const Icon(Symbols.error, color: Colors.red),
              ),
            ),
          const Divider(height: 24),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsConnectionStatus'.tr()),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.wifi),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => NetworkStatusSheet(),
              );
            },
          ),
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.record_voice_over,
        title: 'Speech',
        localizedTitleKey: 'settingsCategorySpeech',
        searchTerms: [
          'tts',
          'voice',
          'language',
          'speech rate',
          'pitch',
          'volume',
        ],
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
            trailing: const Icon(Symbols.play_arrow),
            onTap: () async {
              final tts = FlutterTts();
              await tts.setVolume(settings.ttsVolume);
              await tts.setSpeechRate(settings.ttsSpeechRate);
              await tts.setPitch(settings.ttsPitch);
              if (settings.ttsLanguage.isNotEmpty) {
                await tts.setLanguage(settings.ttsLanguage);
              }
              if (settings.ttsVoice != null && settings.ttsVoice!.isNotEmpty) {
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
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.tune,
        title: 'General',
        localizedTitleKey: 'settingsCategoryGeneral',
        searchTerms: [
          'transparent app bar',
          'data saving',
          'disable animation',
          'default screen',
          'search engine',
        ],
        children: [
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsTransparentAppBar').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.blur_on),
            trailing: Switch(
              value: settings.appBarTransparent,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
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
                ref.read(appSettingsProvider.notifier).setDataSavingMode(value);
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsDisableAnimation').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.animation),
            trailing: Switch(
              value: settings.disableAnimation,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setDisableAnimation(value);
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('Developer mode').tr(),
            subtitle: Text('Enable debug tools and developer features'),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.developer_mode),
            trailing: Switch(
              value: ref.watch(developerModeProvider),
              onChanged: kDebugMode
                  ? null
                  : (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setDeveloperMode(value);
                    },
            ),
          ),
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
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDefaultScreen(value);
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
          ListTile(
            isThreeLine: true,
            minLeadingWidth: 48,
            title: Text('settingsDashSearchEngine').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.search),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextField(
                controller: TextEditingController(
                  text: settings.dashSearchEngine,
                ),
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
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.storage,
        title: 'Storage',
        localizedTitleKey: 'settingsStorage',
        searchTerms: ['cache', 'disk space'],
        children: [_StorageSettingsSection()],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.update,
        title: 'Update',
        localizedTitleKey: 'settingsUpdate',
        searchTerms: ['release', 'version', 'force update', 'cleanup'],
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Text(
              'settingsCheckForUpdatesSection'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsCheckForUpdates').tr(),
            subtitle: Text('settingsCheckForUpdatesHelper').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.update),
            trailing: IconButton(
              icon: const Icon(Symbols.refresh),
              tooltip: 'refresh'.tr(),
              onPressed: () {
                latestReleaseRefreshNonce.value++;
              },
            ),
            onTap: () async {
              await UpdateService().checkForUpdates(context);
            },
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsGithubLatestVersion').tr(),
            subtitle: latestRelease.connectionState == ConnectionState.waiting
                ? Text('settingsGithubLatestVersionLoading').tr()
                : latestRelease.hasError
                ? Text('settingsGithubLatestVersionUnavailable').tr()
                : Text(
                    '${'settingsGithubLatestVersionValue'.tr()}: ${latestRelease.data?.tagName ?? '-'}',
                  ),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.cloud_download),
            trailing: const Icon(Symbols.chevron_right),
            onTap: latestRelease.data == null
                ? null
                : () async {
                    await UpdateService().showUpdateSheet(
                      context,
                      latestRelease.data!,
                    );
                  },
          ),
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsCleanPreviousUpdates').tr(),
            subtitle: Text('settingsCleanPreviousUpdatesHelper').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.cleaning_services),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () async {
              final cleaned = await UpdateService()
                  .cleanupPreviousUpdateArtifacts();
              if (!context.mounted) return;
              showSnackBar(
                cleaned == 0
                    ? 'settingsCleanPreviousUpdatesNone'.tr()
                    : 'settingsCleanPreviousUpdatesDone'.tr(args: ['$cleaned']),
              );
            },
          ),
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.extension,
        title: 'Plugins',
        localizedTitleKey: 'settingsCategoryPlugins',
        searchTerms: [
          'plugins',
          'javascript',
          'scripts',
          'extensions',
          'automation',
          'hooks',
          'commands',
          'events',
        ],
        embedInWide: isWide,
        wideContent: (context) => const PluginManagerContent(),
        children: [
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsManagePlugins').tr(),
            subtitle: Text('settingsManagePluginsDescription').tr(),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.extension),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => SheetScaffold(
                  titleText: 'Plugins',
                  heightFactor: 0.85,
                  child: const PluginManagerContent(),
                ),
              );
            },
          ),
        ],
      ),
    );

    categories.add(
      _SettingCategory(
        icon: Symbols.info,
        title: 'About',
        localizedTitleKey: 'about',
        searchTerms: ['version', 'license', 'developer', 'privacy', 'terms'],
        embedInWide: isWide,
        wideContent: (context) => const AboutContent(),
        children: const [],
      ),
    );

    Widget buildSettingsList(
      BoxConstraints constraints,
      List<_SettingCategory> visibleCategories,
      int selectedIdx,
    ) {
      final selectedCategory = visibleCategories[selectedIdx];

      if (isWide) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < visibleCategories.length; i++)
                        () {
                          final category = visibleCategories[i];
                          return ListTile(
                            selected: selectedIdx == i,
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            leading: Icon(category.icon),
                            title: Text(category.getLocalizedTitle(context)),
                            onTap: () => selectedCategoryIdx.value = i,
                          );
                        }(),
                    ],
                  ),
                ).alignment(Alignment.center),
              ),
              const VerticalDivider(width: 1),
              Flexible(
                flex: 2,
                child:
                    selectedCategory.embedInWide &&
                        selectedCategory.wideContent != null
                    ? selectedCategory.wideContent!(context)
                    : SingleChildScrollView(
                        child: _SettingsSection(
                          title: selectedCategory.title,
                          localizedTitleKey: selectedCategory.localizedTitleKey,
                          children: selectedCategory.children,
                        ),
                      ),
              ),
            ],
          ),
        );
      }

      // Narrow layout with category dropdown
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category dropdown selector
          DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              isExpanded: true,
              valueListenable: ValueNotifier<int>(selectedIdx),
              items: visibleCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return DropdownItem<int>(
                  value: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          category.getLocalizedTitle(context),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategoryIdx.value = value;
                }
              },
              buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
              dropdownStyleData: const DropdownStyleData(),
            ),
          ),
          // Selected category content
          Flexible(
            child: selectedCategory.wideContent != null
                ? selectedCategory.wideContent!(context)
                : SingleChildScrollView(
                    child: _SettingsSection(
                      title: selectedCategory.title,
                      localizedTitleKey: selectedCategory.localizedTitleKey,
                      children: selectedCategory.children,
                    ),
                  ),
          ),
        ],
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: SearchBar(
          controller: searchController,
          focusNode: searchFocusNode,
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'searchSettings'.tr(),
          hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onTapOutside: (_) => searchFocusNode.unfocus(),
          trailing: [
            if (searchQuery.value.isNotEmpty)
              IconButton(
                onPressed: () {
                  searchController.clear();
                  searchQuery.value = '';
                  searchFocusNode.unfocus();
                },
                icon: Icon(
                  Symbols.close,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
          ],
          onChanged: (value) => searchQuery.value = value,
          leading: Icon(
            Symbols.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: const AutoLeadingButton(),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final filteredCategories = categories
              .where((category) => matchesQuery(category, searchQuery.value))
              .toList();

          if (filteredCategories.isNotEmpty &&
              selectedCategoryIdx.value >= filteredCategories.length) {
            selectedCategoryIdx.value = 0;
          }

          if (filteredCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'searchSettingsNoResults'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (isWide) {
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: buildSettingsList(
                constraints,
                filteredCategories,
                selectedCategoryIdx.value.clamp(
                  0,
                  filteredCategories.length - 1,
                ),
              ),
            );
          } else {
            return SizedBox(
              height: constraints.maxHeight,
              child: buildSettingsList(
                constraints,
                filteredCategories,
                selectedCategoryIdx.value.clamp(
                  0,
                  filteredCategories.length - 1,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _SettingCategory {
  final IconData icon;
  final String title;
  final String? localizedTitleKey;
  final List<String> searchTerms;
  final List<Widget> children;
  final bool embedInWide;
  final WidgetBuilder? wideContent;

  _SettingCategory({
    required this.icon,
    required this.title,
    this.localizedTitleKey,
    required this.searchTerms,
    required this.children,
    this.embedInWide = false,
    this.wideContent,
  });

  String getLocalizedTitle(BuildContext context) {
    if (localizedTitleKey != null) return localizedTitleKey!.tr();
    return title;
  }
}

// Helper widget for displaying settings sections with titles
class _SettingsSection extends StatelessWidget {
  final String title;
  final String? localizedTitleKey;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    this.localizedTitleKey,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = localizedTitleKey != null
        ? localizedTitleKey!.tr()
        : title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            displayTitle,
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
  final String titleKey;
  final Color? color;
  final ValueChanged<Color?> onColorChanged;

  const _ColorPickerTile({
    required this.titleKey,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = titleKey.tr();
    return ListTile(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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

class _StorageSettingsSection extends HookConsumerWidget {
  const _StorageSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIOS = !kIsWeb && Platform.isIOS;
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    final theme = Theme.of(context);
    final diskSpace = useState<DiskSpaceInfo?>(null);
    final flutterCacheSize = useState(0);
    final nativeCacheSize = useState(0);
    final databaseSize = useState(0);
    final databasePath = useState<String?>(null);
    final loading = useState(true);
    final clearing = useState(false);
    final resettingDb = useState(false);

    Future<int> calculateDatabaseSize() async {
      if (kIsWeb || databasePath.value == null) return 0;
      try {
        final dbDir = Directory(databasePath.value!);
        if (await dbDir.exists()) {
          return CacheService.getDirectorySize(dbDir);
        }
        return 0;
      } catch (e) {
        debugPrint('Failed to calculate database size: $e');
        return 0;
      }
    }

    useEffect(() {
      CacheService.getDiskSpace().then((space) {
        diskSpace.value = space;
      });
      getApplicationSupportDirectory().then((dir) {
        databasePath.value = '${dir.path}/objectbox';
        calculateDatabaseSize().then((size) {
          databaseSize.value = size;
        });
      });
      CacheService.getFlutterCacheSize().then((size) {
        flutterCacheSize.value = size;
      });
      CacheService.getNativeCacheSize().then((size) {
        nativeCacheSize.value = size;
      });
      loading.value = false;
      return null;
    }, []);

    Future<void> clearFlutterCache() async {
      clearing.value = true;
      await CacheService.clearFlutterCache();
      flutterCacheSize.value = await CacheService.getFlutterCacheSize();
      clearing.value = false;
      if (context.mounted) {
        showSnackBar('settingsCacheCleared'.tr());
      }
    }

    Future<void> clearNativeCache() async {
      clearing.value = true;
      await CacheService.clearNativeCache();
      nativeCacheSize.value = await CacheService.getNativeCacheSize();
      clearing.value = false;
      if (context.mounted) {
        showSnackBar('settingsCacheCleared'.tr());
      }
    }

    Future<void> clearAllCache() async {
      clearing.value = true;
      await CacheService.clearAllCaches();
      flutterCacheSize.value = await CacheService.getFlutterCacheSize();
      nativeCacheSize.value = await CacheService.getNativeCacheSize();
      clearing.value = false;
      if (context.mounted) {
        showSnackBar('settingsCacheCleared'.tr());
      }
    }

    Future<void> resetDb() async {
      final db = ref.read(databaseProvider);
      final stats = await db.getDatabaseStats();
      if (!context.mounted) return;
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) =>
            _DatabaseResetSheet(stats: stats, sizeBytes: databaseSize.value),
      );
      if (confirmed != true) return;
      resettingDb.value = true;
      await resetDatabase(ref);
      databaseSize.value = await calculateDatabaseSize();
      resettingDb.value = false;
      if (context.mounted) {
        showSnackBar('settingsDatabaseResetSuccess'.tr());
      }
    }

    Future<void> openDatabaseFolder() async {
      if (!isDesktop || databasePath.value == null) return;

      try {
        await OpenFile.open(databasePath.value!);
      } catch (e) {
        if (context.mounted) {
          showErrorAlert(e);
        }
      }
    }

    if (loading.value) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (diskSpace.value != null)
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
                          (diskSpace.value!.usedPercentage * 100)
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
                    value: diskSpace.value!.usedPercentage.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CacheService.formatBytes(diskSpace.value!.usedSpace)} / ${CacheService.formatBytes(diskSpace.value!.totalSpace)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${'settingsStorageFree'.tr()}: ${CacheService.formatBytes(diskSpace.value!.freeSpace)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          )
        else
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
        ListTile(
          minLeadingWidth: 48,
          title: Text('settingsChatRoomStorage').tr(),
          subtitle: Text('settingsChatRoomStorageHelper').tr(),
          contentPadding: const EdgeInsets.only(left: 24, right: 17),
          leading: const Icon(Symbols.storage),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            context.router.push(const ChatRoomStorageRoute());
          },
        ),
        const Divider(height: 24),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Symbols.cached, size: 20),
                title: Text('settingsFlutterCache'.tr()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CacheService.formatBytes(flutterCacheSize.value),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    if (clearing.value)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      TextButton(
                        onPressed: clearFlutterCache,
                        child: Text('settingsClearCache'.tr()),
                      ),
                  ],
                ),
              ),
              if (isIOS)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.android, size: 20),
                  title: Text('settingsNativeCache'.tr()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CacheService.formatBytes(nativeCacheSize.value),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      if (clearing.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: clearNativeCache,
                          child: Text('settingsClearCache'.tr()),
                        ),
                    ],
                  ),
                ),
              if (!isIOS && flutterCacheSize.value > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: clearing.value ? null : clearAllCache,
                      icon: clearing.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.delete_outline),
                      label: Text('settingsClearCache'.tr()),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settingsDatabase'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.folder_open, size: 20),
                  title: Text('settingsOpenDatabaseFolder'.tr()),
                  subtitle: Text(
                    databasePath.value ?? 'unknown'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: openDatabaseFolder,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.storage, size: 20),
                  title: Text('settingsDatabaseSize'.tr()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CacheService.formatBytes(databaseSize.value),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      if (resettingDb.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: resetDb,
                          child: Text('settingsDatabaseReset'.tr()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

String _ipOverrideModeLabel(IpOverrideMode mode) {
  return switch (mode) {
    IpOverrideMode.complete => 'settingsIpOverrideModeComplete'.tr(),
    IpOverrideMode.mixed => 'settingsIpOverrideModeMixed'.tr(),
    IpOverrideMode.off => 'settingsIpOverrideModeOff'.tr(),
  };
}

class _IpOverrideModeSheet extends StatelessWidget {
  final WidgetRef ref;

  const _IpOverrideModeSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(ipOverrideModeProvider);
    final domains = ref.watch(ipOverrideDomainsProvider);

    return SheetScaffold(
      titleText: 'settingsIpOverride'.tr(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<IpOverrideMode>(
              segments: [
                ButtonSegment(
                  value: IpOverrideMode.complete,
                  label: Text('settingsIpOverrideModeComplete').tr(),
                ),
                ButtonSegment(
                  value: IpOverrideMode.mixed,
                  label: Text('settingsIpOverrideModeMixed').tr(),
                ),
                ButtonSegment(
                  value: IpOverrideMode.off,
                  label: Text('settingsIpOverrideModeOff').tr(),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (selected) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setIpOverrideMode(selected.first);
                context.pop();
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            Text(
              'settingsIpOverrideModeDescription'.tr(
                args: [_ipOverrideModeLabel(mode)],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showIpOverrideDomainsEditor(context, ref),
              icon: const Icon(Symbols.list),
              label: Text('settingsIpOverrideDomains').tr(),
            ),
            const SizedBox(height: 8),
            Text(
              domains.isEmpty
                  ? 'settingsIpOverrideDomainsHelper'.tr()
                  : domains.join('\n'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatabaseResetSheet extends StatelessWidget {
  final Map<String, int> stats;
  final int sizeBytes;

  const _DatabaseResetSheet({required this.stats, required this.sizeBytes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <(IconData, String, int)>[
      (
        Symbols.chat,
        'settingsDatabaseResetStatMessages'.tr(),
        stats['messages'] ?? 0,
      ),
      (
        Symbols.forum,
        'settingsDatabaseResetStatChatRooms'.tr(),
        stats['chatRooms'] ?? 0,
      ),
      (
        Symbols.group,
        'settingsDatabaseResetStatChatMembers'.tr(),
        stats['chatMembers'] ?? 0,
      ),
      (
        Symbols.public,
        'settingsDatabaseResetStatRealms'.tr(),
        stats['realms'] ?? 0,
      ),
      (
        Symbols.draft,
        'settingsDatabaseResetStatPostDrafts'.tr(),
        stats['postDrafts'] ?? 0,
      ),
    ];

    return SheetScaffold(
      titleText: 'settingsDatabaseResetSheetTitle'.tr(),
      heightFactor: 0.75,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.55),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Symbols.warning_rounded,
                      fill: 1,
                      size: 22,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'settingsDatabaseResetSheetDescription'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(entries[i].$1, size: 18),
                      ),
                      title: Text(entries[i].$2),
                      trailing: Text(
                        entries[i].$3.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Symbols.storage, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text('settingsDatabaseSize'.tr())),
                          Text(
                            CacheService.formatBytes(sizeBytes),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'settingsDatabaseResetConfirm'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).padding(horizontal: 16),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                const SizedBox(width: 8),
                _LongPressConfirmButton(
                  label: 'settingsDatabaseResetHoldToConfirm'.tr(),
                  icon: Symbols.delete_forever,
                  onCompleted: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showIpOverrideDomainsEditor(BuildContext context, WidgetRef ref) {
  final domains = ref.read(ipOverrideDomainsProvider);
  final controller = TextEditingController(text: domains.join('\n'));

  Future<void> save() async {
    final lines = controller.text
        .split(RegExp(r'[\n,]'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    ref.read(appSettingsProvider.notifier).setIpOverrideDomains(lines);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return SheetScaffold(
        titleText: 'settingsIpOverrideDomains'.tr(),
        onClose: () => Navigator.pop(sheetContext),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            top: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settingsIpOverrideDomainsHelper'.tr()),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'io.solian.app\nmedia.solian.app',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      controller.text = '';
                      save();
                      Navigator.pop(sheetContext);
                    },
                    child: Text('clear').tr(),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text('cancel').tr(),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await save();
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      showSnackBar('settingsApplied'.tr());
                    },
                    child: Text('confirm').tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showIpOverrideEntriesEditor(BuildContext context, WidgetRef ref) {
  final settings = ref.read(ipOverrideSettingsProvider);
  final controller = TextEditingController(
    text: settings.overrides
        .map(
          (override) => override.port == null
              ? override.ip
              : '${override.ip}:${override.port}',
        )
        .join('\n'),
  );

  Future<void> save() async {
    final lines = controller.text
        .split(RegExp(r'[\n,]'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final overrides = <IpOverride>[];
    for (final line in lines) {
      final idx = line.lastIndexOf(':');
      if (idx > 0 && idx < line.length - 1 && !line.contains(']')) {
        final ip = line.substring(0, idx).trim();
        final port = int.tryParse(line.substring(idx + 1).trim());
        if (ip.isNotEmpty) {
          overrides.add(IpOverride(ip: ip, port: port));
        }
      } else {
        overrides.add(IpOverride(ip: line));
      }
    }

    ref.read(appSettingsProvider.notifier).setIpOverrideList(overrides);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return SheetScaffold(
        titleText: 'settingsIpOverrideEntries'.tr(),
        onClose: () => Navigator.pop(sheetContext),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            top: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settingsIpOverrideEntriesHelper'.tr()),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '192.168.1.10\n192.168.1.11:443',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      controller.text = '';
                      save();
                      Navigator.pop(sheetContext);
                    },
                    child: Text('clear').tr(),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text('cancel').tr(),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await save();
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      showSnackBar('settingsIpOverrideEntriesSaved'.tr());
                    },
                    child: Text('confirm').tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LongPressConfirmButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onCompleted;

  const _LongPressConfirmButton({
    required this.label,
    required this.icon,
    required this.onCompleted,
  });

  @override
  State<_LongPressConfirmButton> createState() =>
      _LongPressConfirmButtonState();
}

Future<void> _showDesktopNowPlayingCliPathEditor(
  BuildContext context,
  WidgetRef ref,
) async {
  final controller = TextEditingController(
    text: ref.read(desktopNowPlayingCliPathProvider) ?? '',
  );

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('macOS nowplaying-cli path'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: kMacosNowPlayingCliDefaultPath,
            border: const OutlineInputBorder(),
            helperText:
                'Leave empty to use the default Homebrew path on this Mac.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('cancel').tr(),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(desktopNowPlayingCliPathProvider.notifier)
                  .setPath(controller.text);
              ref.invalidate(desktopNowPlayingCliStatusProvider);
              Navigator.of(dialogContext).pop();
            },
            child: Text('confirm').tr(),
          ),
        ],
      );
    },
  );
}

class _LongPressConfirmButtonState extends State<_LongPressConfirmButton>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_completed) {
          _completed = true;
          widget.onCompleted();
        }
      });
  }

  void _startHold() {
    if (_controller.isAnimating || _completed) return;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_controller.isCompleted || _completed) return;
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onLongPress: () {},
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final isHolding = _controller.value > 0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Opacity(
                      opacity: 0,
                      child: _content(scheme, isHolding: false),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _controller.value,
                        child: Container(color: scheme.error),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      alignment: Alignment.center,
                      child: _content(scheme, isHolding: isHolding),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(ColorScheme scheme, {required bool isHolding}) {
    final color = isHolding ? scheme.onError : scheme.onErrorContainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DesktopIdleStatusPreview extends HookConsumerWidget {
  const _DesktopIdleStatusPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(desktopIdleStatusEnabledProvider);
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final idleTime = useState<Duration?>(null);
    final loading = useState(true);

    useEffect(() {
      void fetchIdleTime() {
        IslandDesktopPresence()
            .getIdleTime()
            .then((duration) {
              idleTime.value = duration;
              loading.value = false;
            })
            .catchError((_) {
              loading.value = false;
            });
      }

      fetchIdleTime();
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        fetchIdleTime();
      });
      return timer.cancel;
    }, []);

    return ListTile(
      minLeadingWidth: 48,
      title: Text('settingsDesktopIdleStatusPreview'.tr()),
      contentPadding: const EdgeInsets.only(left: 24, right: 17),
      leading: const Icon(Symbols.preview),
      subtitle: loading.value
          ? Text('settingsDesktopIdleStatusPreviewLoading'.tr())
          : Text(
              idleTime.value != null
                  ? 'settingsDesktopIdleStatusPreviewValue'.tr(
                      args: [
                        idleTime.value!.inMinutes.toString(),
                        (idleTime.value!.inSeconds % 60).toString(),
                      ],
                    )
                  : 'settingsDesktopIdleStatusPreviewUnavailable'.tr(),
            ),
    );
  }
}

class _DesktopNowPlayingPreview extends HookConsumerWidget {
  const _DesktopNowPlayingPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(desktopNowPlayingEnabledProvider);
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final nowPlayingState = ref.watch(desktopNowPlayingStateProvider);
    final serverUrl = ref.watch(serverUrlProvider);

    String resolveArtworkUrl(String? imageUri) {
      if (imageUri == null) return '';
      if (imageUri.startsWith('sha256:')) {
        return '$serverUrl/passport/presence/artworks/$imageUri';
      }
      return imageUri;
    }

    return nowPlayingState.when(
      data: (state) {
        if (state == null || state.event == null) {
          return ListTile(
            minLeadingWidth: 48,
            title: Text('settingsNowPlayingPreview'.tr()),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.music_off),
            subtitle: Text('settingsNowPlayingPreviewEmpty'.tr()),
          );
        }

        final event = state.event!;
        final activityData = state.activityData;
        final artworkUrl = resolveArtworkUrl(
          activityData?['large_image'] as String? ??
              activityData?['small_image'] as String?,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsNowPlayingPreview'.tr()),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.music_note),
              subtitle: Text(
                event.state == ExternalNowPlayingState.playing
                    ? 'settingsNowPlayingPreviewPlaying'.tr()
                    : event.state == ExternalNowPlayingState.paused
                    ? 'settingsNowPlayingPreviewPaused'.tr()
                    : 'settingsNowPlayingPreviewStopped'.tr(),
              ),
            ),
            if (event.title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (artworkUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            artworkUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Symbols.music_note, size: 32),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settingsNowPlayingPreviewTrack'.tr(),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.title ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (event.artist != null)
                            Text(
                              event.artist!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (event.album != null)
                            Text(
                              event.album!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (state.lastError != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.error,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.lastError!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (activityData != null) ...[
              ExpansionTile(
                title: Text('settingsNowPlayingPreviewPayload'.tr()),
                tilePadding: const EdgeInsets.fromLTRB(24, 0, 26, 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(activityData),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final presence = IslandDesktopPresence();
                  final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                  Logger.root.info('[DebugNowPlaying] Manual trigger with path=$executablePath');
                  final result = await presence.debugNowPlaying(executablePath: executablePath);
                  if (context.mounted) {
                    if (result != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Now Playing Debug Result'),
                          content: SingleChildScrollView(
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(result),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('close'.tr()),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showSnackBar('No active now playing source detected');
                    }
                  }
                },
                icon: const Icon(Symbols.bug_report, size: 18),
                label: const Text('Debug: Test Now Playing'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final presence = IslandDesktopPresence();
                  final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                  Logger.root.info('[DebugNowPlaying] Authorization test with path=$executablePath');
                  
                  // Run the test and show result
                  final result = await presence.debugNowPlaying(executablePath: executablePath);
                  Logger.root.info('[DebugNowPlaying] Authorization test result: ${result != null ? "success" : "null"}');
                  
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Apple Music Authorization Test'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result != null
                                    ? '✓ Authorization successful! nowplaying-cli can access Apple Music.'
                                    : '✗ No data returned. This may indicate a permission issue.',
                              ),
                              const SizedBox(height: 16),
                              if (result != null) ...[
                                Text('Title: ${result['title'] ?? 'N/A'}'),
                                Text('Artist: ${result['artist'] ?? 'N/A'}'),
                                Text('Bundle: ${result['clientBundleIdentifier'] ?? result['bundleIdentifier'] ?? 'N/A'}'),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                'If you see permission errors, check:\n'
                                '• System Settings > Privacy & Security > Media & Apple Music\n'
                                '• Ensure nowplaying-cli is installed and executable',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('close'.tr()),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Symbols.security, size: 18),
                label: const Text('Test Apple Music Access'),
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        children: [
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsNowPlayingPreview'.tr()),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            subtitle: Text('loading'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final presence = IslandDesktopPresence();
                final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                Logger.root.info('[DebugNowPlaying] Manual trigger with path=$executablePath');
                final result = await presence.debugNowPlaying(executablePath: executablePath);
                if (context.mounted) {
                  if (result != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Now Playing Debug Result'),
                        content: SingleChildScrollView(
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ').convert(result),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('close'.tr()),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showSnackBar('No active now playing source detected');
                  }
                }
              },
              icon: const Icon(Symbols.bug_report, size: 18),
              label: const Text('Debug: Test Now Playing'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final presence = IslandDesktopPresence();
                final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                Logger.root.info('[DebugNowPlaying] Authorization test with path=$executablePath');
                
                final result = await presence.debugNowPlaying(executablePath: executablePath);
                Logger.root.info('[DebugNowPlaying] Authorization test result: ${result != null ? "success" : "null"}');
                
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Apple Music Authorization Test'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result != null
                                  ? '✓ Authorization successful! nowplaying-cli can access Apple Music.'
                                  : '✗ No data returned. This may indicate a permission issue.',
                            ),
                            const SizedBox(height: 16),
                            if (result != null) ...[
                              Text('Title: ${result['title'] ?? 'N/A'}'),
                              Text('Artist: ${result['artist'] ?? 'N/A'}'),
                              Text('Bundle: ${result['clientBundleIdentifier'] ?? result['bundleIdentifier'] ?? 'N/A'}'),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'If you see permission errors, check:\n'
                              '• System Settings > Privacy & Security > Media & Apple Music\n'
                              '• Ensure nowplaying-cli is installed and executable',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('close'.tr()),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(Symbols.security, size: 18),
              label: const Text('Test Apple Music Access'),
            ),
          ),
        ],
      ),
      error: (_, _) => Column(
        children: [
          ListTile(
            minLeadingWidth: 48,
            title: Text('settingsNowPlayingPreview'.tr()),
            contentPadding: const EdgeInsets.only(left: 24, right: 17),
            leading: const Icon(Symbols.error),
            subtitle: Text('settingsNowPlayingPreviewError'.tr()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final presence = IslandDesktopPresence();
                final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                Logger.root.info('[DebugNowPlaying] Manual trigger with path=$executablePath');
                final result = await presence.debugNowPlaying(executablePath: executablePath);
                if (context.mounted) {
                  if (result != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Now Playing Debug Result'),
                        content: SingleChildScrollView(
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ').convert(result),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('close'.tr()),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showSnackBar('No active now playing source detected');
                  }
                }
              },
              icon: const Icon(Symbols.bug_report, size: 18),
              label: const Text('Debug: Test Now Playing'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final presence = IslandDesktopPresence();
                final executablePath = ref.read(desktopNowPlayingCliPathProvider);
                Logger.root.info('[DebugNowPlaying] Authorization test with path=$executablePath');
                
                final result = await presence.debugNowPlaying(executablePath: executablePath);
                Logger.root.info('[DebugNowPlaying] Authorization test result: ${result != null ? "success" : "null"}');
                
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Apple Music Authorization Test'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result != null
                                  ? '✓ Authorization successful! nowplaying-cli can access Apple Music.'
                                  : '✗ No data returned. This may indicate a permission issue.',
                            ),
                            const SizedBox(height: 16),
                            if (result != null) ...[
                              Text('Title: ${result['title'] ?? 'N/A'}'),
                              Text('Artist: ${result['artist'] ?? 'N/A'}'),
                              Text('Bundle: ${result['clientBundleIdentifier'] ?? result['bundleIdentifier'] ?? 'N/A'}'),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'If you see permission errors, check:\n'
                              '• System Settings > Privacy & Security > Media & Apple Music\n'
                              '• Ensure nowplaying-cli is installed and executable',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('close'.tr()),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(Symbols.security, size: 18),
              label: const Text('Test Apple Music Access'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopRpcServerPreview extends HookConsumerWidget {
  const _DesktopRpcServerPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(desktopRpcServerEnabledProvider);
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final serverState = ref.watch(rpcServerStateProvider);
    final showPackets = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          minLeadingWidth: 48,
          title: Text('settingsRpcServerStatus'.tr()),
          contentPadding: const EdgeInsets.only(left: 24, right: 17),
          leading: Icon(
            serverState.status == 'Server running'
                ? Symbols.check_circle
                : Symbols.info,
            color: serverState.status == 'Server running'
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          subtitle: Text(serverState.status),
        ),
        if (serverState.currentActivityData != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settingsRpcServerCurrentActivity'.tr(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    const JsonEncoder.withIndent(
                      '  ',
                    ).convert(serverState.currentActivityData),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
        ListTile(
          minLeadingWidth: 48,
          title: Text('settingsRpcServerPackets'.tr()),
          subtitle: Text(
            'settingsRpcServerPacketsHelper'.tr(
              args: [serverState.recentPackets.length.toString()],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 24, right: 17),
          leading: const Icon(Symbols.swap_horiz),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (serverState.recentPackets.isNotEmpty)
                IconButton(
                  icon: const Icon(Symbols.delete_sweep),
                  tooltip: 'settingsRpcServerClearPackets'.tr(),
                  onPressed: () {
                    ref.read(rpcServerStateProvider.notifier).clearPackets();
                  },
                ),
              IconButton(
                icon: Icon(
                  showPackets.value ? Symbols.expand_less : Symbols.expand_more,
                ),
                onPressed: () {
                  showPackets.value = !showPackets.value;
                },
              ),
            ],
          ),
        ),
        if (showPackets.value) ...[
          if (serverState.recentPackets.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'settingsRpcServerNoPackets'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: serverState.recentPackets.length,
                padding: EdgeInsets.symmetric(vertical: 8),
                reverse: true,
                itemBuilder: (context, index) {
                  final packet =
                      serverState.recentPackets[serverState
                              .recentPackets
                              .length -
                          1 -
                          index];
                  final direction = packet['direction'] as String? ?? 'unknown';
                  final type = packet['type'] as String? ?? 'unknown';
                  final timestamp = packet['timestamp'] as String?;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          direction == 'incoming'
                              ? Symbols.arrow_downward
                              : direction == 'outgoing'
                              ? Symbols.arrow_upward
                              : Symbols.circle,
                          size: 14,
                          color: direction == 'incoming'
                              ? Theme.of(context).colorScheme.primary
                              : direction == 'outgoing'
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (timestamp != null)
                                Text(
                                  timestamp.substring(11, timestamp.length - 4),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.code, size: 14),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(type),
                                content: SingleChildScrollView(
                                  child: SelectableText(
                                    const JsonEncoder.withIndent(
                                      '  ',
                                    ).convert(packet),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('close'.tr()),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}
