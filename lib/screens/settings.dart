import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_sticker.dart';
import 'package:surface/providers/theme.dart';
import 'package:surface/theme.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/updater.dart';

const Map<String, Color> kColorSchemes = {
  'colorSchemeIndigo': Colors.indigo,
  'colorSchemeBlue': Colors.blue,
  'colorSchemeGreen': Colors.green,
  'colorSchemeYellow': Colors.yellow,
  'colorSchemeOrange': Colors.orange,
  'colorSchemeRed': Colors.red,
  'colorSchemeWhite': Colors.white,
  'colorSchemeBlack': Colors.black,
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SharedPreferences _prefs;
  String _docBasepath = '/';

  final TextEditingController _customFontController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      _docBasepath = dir.path;
      if (mounted) {
        setState(() {});
      }
    });
    final config = context.read<ConfigProvider>();
    _prefs = config.prefs;
    _serverUrlController.text = config.serverUrl;
    if (_prefs.getString(kAppCustomFonts) != null) {
      _customFontController.text = _prefs.getString(kAppCustomFonts) ?? '';
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _customFontController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final dt = context.read<DatabaseProvider>();
    final cfg = context.watch<ConfigProvider>();

    final now = DateTime.now();

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenSettings').tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settingsAppearance')
                    .bold()
                    .fontSize(17)
                    .tr()
                    .padding(horizontal: 20, bottom: 4),
                ListTile(
                  title: Text('settingsDisplayLanguage').tr(),
                  subtitle: Text('settingsDisplayLanguageDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  leading: const Icon(Symbols.translate),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<Locale?>(
                      isExpanded: true,
                      items: [
                        ...EasyLocalization.of(context)!
                            .supportedLocales
                            .mapIndexed((idx, ele) {
                          return DropdownMenuItem<Locale?>(
                            value: ele,
                            child:
                                Text('${ele.languageCode}-${ele.countryCode}')
                                    .fontSize(14),
                          );
                        }),
                        DropdownMenuItem<Locale?>(
                          value: null,
                          child: Text('settingsDisplayLanguageSystem')
                              .tr()
                              .fontSize(14),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        height: 40,
                        width: 160,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                    ),
                  ),
                ),
                if (!kIsWeb)
                  ListTile(
                    title: Text('settingsBackgroundImage').tr(),
                    subtitle: Text('settingsBackgroundImageDescription').tr(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Symbols.image),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image == null) return;

                      await File(image.path)
                          .copy('$_docBasepath/app_background_image');
                      _prefs.setBool(kAppBackgroundStoreKey, true);

                      setState(() {});
                    },
                  ),
                if (!kIsWeb)
                  FutureBuilder<bool>(
                      future:
                          File('$_docBasepath/app_background_image').exists(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          title: Text('settingsBackgroundImageClear').tr(),
                          subtitle:
                              Text('settingsBackgroundImageClearDescription')
                                  .tr(),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          leading: const Icon(Symbols.texture),
                          trailing: const Icon(Symbols.chevron_right),
                          onTap: () {
                            File('$_docBasepath/app_background_image')
                                .deleteSync();
                            _prefs.remove(kAppBackgroundStoreKey);
                            setState(() {});
                          },
                        );
                      }),
                CheckboxListTile(
                  title: Text('settingsThemeMaterial3').tr(),
                  subtitle: Text('settingsThemeMaterial3Description').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  secondary: const Icon(Symbols.new_releases),
                  value: _prefs.getBool(kMaterialYouToggleStoreKey) ?? true,
                  onChanged: (value) {
                    setState(() {
                      _prefs.setBool(
                        kMaterialYouToggleStoreKey,
                        value ?? false,
                      );
                    });
                    final th = context.read<ThemeProvider>();
                    th.reloadTheme(useMaterial3: value ?? false);
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.format_paint),
                  title: Text('settingsColorScheme').tr(),
                  subtitle: Text('settingsColorSchemeDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    Color pickerColor = Color(
                        _prefs.getInt(kAppColorSchemeStoreKey) ??
                            Colors.indigo.value);
                    final color = await showDialog<Color?>(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) => pickerColor = color,
                            enableAlpha: false,
                            hexInputBar: true,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('dialogDismiss').tr(),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('dialogConfirm').tr(),
                            onPressed: () {
                              Navigator.of(context).pop(pickerColor);
                            },
                          ),
                        ],
                      ),
                    );

                    if (color == null || !context.mounted) return;

                    _prefs.setInt(kAppColorSchemeStoreKey, color.value);
                    final th = context.read<ThemeProvider>();
                    th.reloadTheme(seedColorOverride: color);
                    setState(() {});

                    context.showSnackbar('colorSchemeApplied'.tr());
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.palette),
                  title: Text('settingsColorSeed').tr(),
                  subtitle: Text('settingsColorSeedDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<int?>(
                      isExpanded: true,
                      items: [
                        ...kColorSchemes.entries.mapIndexed((idx, ele) {
                          return DropdownMenuItem<int>(
                            value: idx,
                            child: Text(ele.key).tr(),
                          );
                        }),
                        DropdownMenuItem<int>(
                          value: -1,
                          child: Text('custom').tr(),
                        ),
                      ],
                      value: _prefs.getInt(kAppColorSchemeStoreKey) == null
                          ? 1
                          : kColorSchemes.values.toList().indexWhere((ele) =>
                              ele.value ==
                              _prefs.getInt(kAppColorSchemeStoreKey)),
                      onChanged: (int? value) {
                        if (value != null && value != -1) {
                          _prefs.setInt(kAppColorSchemeStoreKey,
                              kColorSchemes.values.elementAt(value).value);
                          final th = context.read<ThemeProvider>();
                          th.reloadTheme(
                              seedColorOverride:
                                  kColorSchemes.values.elementAt(value));
                          setState(() {});

                          context.showSnackbar('colorSchemeApplied'.tr());
                        }
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        height: 40,
                        width: 160,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                    ),
                  ),
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.blur_on),
                  title: Text('settingsAppBarTransparent').tr(),
                  subtitle: Text('settingsAppBarTransparentDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  value: _prefs.getBool(kAppbarTransparentStoreKey) ?? false,
                  onChanged: (value) {
                    _prefs.setBool(kAppbarTransparentStoreKey, value ?? false);
                    final th = context.read<ThemeProvider>();
                    th.reloadTheme();
                    setState(() {});
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.left_panel_close),
                  title: Text('settingsDrawerPreferCollapse').tr(),
                  subtitle:
                      Text('settingsDrawerPreferCollapseDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  value: _prefs.getBool(kAppDrawerPreferCollapse) ?? false,
                  onChanged: (value) {
                    _prefs.setBool(kAppDrawerPreferCollapse, value ?? false);
                    final cfg = context.read<ConfigProvider>();
                    cfg.calcDrawerSize(context);
                    setState(() {});
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.hide),
                  title: Text('settingsHideBottomNav').tr(),
                  subtitle: Text('settingsHideBottomNavDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  value: _prefs.getBool(kAppHideBottomNav) ?? false,
                  onChanged: (value) {
                    _prefs.setBool(kAppHideBottomNav, value ?? false);
                    final cfg = context.read<ConfigProvider>();
                    cfg.calcDrawerSize(context);
                    setState(() {});
                  },
                ),
                CheckboxListTile(
                  value: cfg.soundEffects,
                  onChanged: (value) {
                    cfg.soundEffects = value ?? false;
                    setState(() {});
                  },
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  title: Text('settingsSoundEffects').tr(),
                  subtitle: Text('settingsSoundEffectsDescription').tr(),
                  secondary: const Icon(Symbols.sound_sampler),
                ),
                ListTile(
                  leading: const Icon(Symbols.font_download),
                  title: Text('settingsCustomFonts').tr(),
                  subtitle: Text('settingsCustomFontsDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 14),
                  trailing: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _prefs.remove(kAppCustomFonts);
                      context.showSnackbar('settingsCustomFontApplied'.tr());
                      final theme = context.read<ThemeProvider>();
                      _customFontController.clear();
                      theme.reloadTheme();
                    },
                  ),
                ),
                TextField(
                  controller: _customFontController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'settingsCustomFontFamily'.tr(),
                    helperText: 'settingsCustomFontFamilyHint'.tr(),
                    prefixIcon: const Icon(Symbols.format_paint),
                    suffixIcon: IconButton(
                      icon: const Icon(Symbols.save),
                      onPressed: () {
                        _prefs.setString(
                          kAppCustomFonts,
                          _customFontController.text,
                        );
                        context.showSnackbar('settingsCustomFontApplied'.tr());
                        final theme = context.read<ThemeProvider>();
                        theme.reloadTheme();
                      },
                    ),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16, top: 8, bottom: 4),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settingsFeatures')
                    .bold()
                    .fontSize(17)
                    .tr()
                    .padding(horizontal: 20, bottom: 4),
                CheckboxListTile(
                  secondary: const Icon(Symbols.translate),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  title: Text('settingsAutoTranslate').tr(),
                  subtitle: Text('settingsAutoTranslateDescription').tr(),
                  value: _prefs.getBool(kAppAutoTranslate) ?? false,
                  onChanged: (value) {
                    setState(() {
                      _prefs.setBool(kAppAutoTranslate, value ?? false);
                    });
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.vibration),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  title: Text('settingsNotifyWithHaptic').tr(),
                  subtitle: Text('settingsNotifyWithHapticDescription').tr(),
                  value: _prefs.getBool(kAppNotifyWithHaptic) ?? true,
                  onChanged: (value) {
                    setState(() {
                      _prefs.setBool(kAppNotifyWithHaptic, value ?? false);
                    });
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.link),
                  title: Text('settingsExpandPostLink').tr(),
                  subtitle: Text('settingsExpandPostLinkDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  value: _prefs.getBool(kAppExpandPostLink) ?? true,
                  onChanged: (value) {
                    setState(() {
                      _prefs.setBool(kAppExpandPostLink, value ?? false);
                    });
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Symbols.chat),
                  title: Text('settingsExpandChatLink').tr(),
                  subtitle: Text('settingsExpandChatLinkDescription').tr(),
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  value: _prefs.getBool(kAppExpandChatLink) ?? true,
                  onChanged: (value) {
                    setState(() {
                      _prefs.setBool(kAppExpandChatLink, value ?? false);
                    });
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settingsNetwork')
                    .bold()
                    .fontSize(17)
                    .tr()
                    .padding(horizontal: 20, bottom: 4),
                TextField(
                  controller: _serverUrlController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'settingsNetworkServer'.tr(),
                    helperText: 'settingsNetworkServerDescription'.tr(),
                    prefixIcon: const Icon(Symbols.dns),
                    suffixIcon: IconButton(
                      icon: const Icon(Symbols.save),
                      onPressed: () {
                        sn.setBaseUrl(_serverUrlController.text);
                        _prefs.setString(
                          kNetworkServerStoreKey,
                          _serverUrlController.text,
                        );
                        context.showSnackbar('settingsNetworkServerSaved'.tr());
                        setState(() {});
                      },
                    ),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16, top: 8, bottom: 4),
                ListTile(
                  title: Text('settingsNetworkServerPreset').tr(),
                  subtitle: Text('settingsNetworkServerPresetDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.lists),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      items: [
                        ...kNetworkServerDirectory,
                        if (!kNetworkServerDirectory
                            .map((ele) => ele.$2)
                            .contains(_serverUrlController.text))
                          ('Custom', _serverUrlController.text),
                      ]
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.$2,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.$1).fontSize(14),
                                  Text(item.$2, overflow: TextOverflow.ellipsis)
                                      .fontSize(11)
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      value: _serverUrlController.text,
                      onChanged: (String? value) {
                        if (value == null) return;
                        _serverUrlController.text = value;
                        _prefs.setString(kNetworkServerStoreKey, value);
                        context.showSnackbar('settingsNetworkServerSaved'.tr());
                        setState(() {});
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        height: 56,
                        width: 160,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 60,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('settingsNetworkServerReset').tr(),
                  subtitle: Text('settingsNetworkServerResetDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.reset_wrench),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () {
                    _serverUrlController.text = kNetworkServerDefault;
                    _prefs.remove(kNetworkServerStoreKey);
                    context.showSnackbar('settingsNetworkServerSaved'.tr());
                    setState(() {});
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settingsPerformance')
                    .bold()
                    .fontSize(17)
                    .tr()
                    .padding(horizontal: 20, bottom: 4),
                ListTile(
                  title: Text('settingsImageQuality').tr(),
                  subtitle: Text('settingsImageQualityDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.image),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton2<FilterQuality>(
                      value: kImageQualityLevel.values.elementAtOrNull(
                              _prefs.getInt('app_image_quality') ?? 3) ??
                          FilterQuality.high,
                      isExpanded: true,
                      items: kImageQualityLevel.entries
                          .map(
                            (item) => DropdownMenuItem<FilterQuality>(
                              value: item.value,
                              child: Text(item.key).tr().fontSize(14),
                            ),
                          )
                          .toList(),
                      onChanged: (FilterQuality? value) {
                        if (value == null) return;
                        _prefs.setInt('app_image_quality',
                            kImageQualityLevel.values.toList().indexOf(value));
                        setState(() {});
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        height: 40,
                        width: 160,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settingsMisc')
                    .bold()
                    .fontSize(17)
                    .tr()
                    .padding(horizontal: 20, bottom: 4),
                ListTile(
                  leading: const Icon(Symbols.home_storage),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('cacheSize').tr(),
                  subtitle: FutureBuilder(
                    future: DefaultCacheManager().store.getCacheSize(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || kIsWeb) {
                        return Text('unknown').tr();
                      }
                      return Text(
                        snapshot.data!.formatBytes(),
                        style: GoogleFonts.robotoMono(),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Symbols.cleaning_services),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('cacheDelete').tr(),
                  subtitle: Text('cacheDeleteDescription').tr(),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    await DefaultCacheManager().emptyCache();
                    if (!context.mounted) return;
                    HapticFeedback.heavyImpact();
                    context.showSnackbar('cacheDeleted'.tr());
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.database),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('databaseSize').tr(),
                  subtitle: FutureBuilder(
                    future: dt.getDatabaseSize(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || kIsWeb) {
                        return Text('unknown').tr();
                      }
                      return Text(
                        snapshot.data!.formatBytes(),
                        style: GoogleFonts.robotoMono(),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Symbols.database_off),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('databaseDelete').tr(),
                  subtitle: Text('databaseDeleteDescription').tr(),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    await dt.removeDatabase();
                    if (!context.mounted) return;
                    HapticFeedback.heavyImpact();
                    context.showSnackbar('databaseDeleted'.tr());
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.notifications),
                  title: Text('settingsEnablePushNotifications').tr(),
                  subtitle:
                      Text('settingsEnablePushNotificationsDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    final nty = context.read<NotificationProvider>();
                    try {
                      await nty.registerPushNotifications();
                      if (!context.mounted) return;
                      HapticFeedback.heavyImpact();
                      context.showSnackbar(
                          'settingsEnabledPushNotifications'.tr());
                    } catch (err) {
                      if (!mounted) return;
                      context.showErrorDialog(err);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Symbols.refresh),
                  title: Text('stickersReload').tr(),
                  subtitle: Text('stickersReloadDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    final stickers = context.read<SnStickerProvider>();
                    try {
                      await stickers.listSticker();
                      if (!context.mounted) return;
                      HapticFeedback.heavyImpact();
                      context.showSnackbar('stickersReloaded'.tr());
                    } catch (err) {
                      if (!context.mounted) return;
                      context.showErrorDialog(err);
                    }
                  },
                ),
                ListTile(
                  title: Text('forceUpdate').tr(),
                  subtitle: Text('forceUpdateDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.update),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => VersionUpdatePopup(),
                    );
                  },
                ),
                ListTile(
                  title: Text('runtimeLogsOpen').tr(),
                  subtitle: Text('runtimeLogsDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.receipt_long),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    GoRouter.of(context).pushNamed('debugLogging');
                  },
                ),
                ListTile(
                  title: Text('settingsMiscAbout').tr(),
                  subtitle: Text('settingsMiscAboutDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Symbols.info),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () async {
                    GoRouter.of(context).pushNamed('about');
                  },
                ),
                if (now.day == 1 && now.month == 4)
                  CheckboxListTile(
                    title: Text('settingsAprilFoolFeatures').tr(),
                    subtitle: Text('settingsAprilFoolFeaturesDescription').tr(),
                    contentPadding: const EdgeInsets.only(left: 24, right: 17),
                    secondary: const Icon(Symbols.new_releases),
                    value: cfg.aprilFoolFeatures,
                    onChanged: (value) {
                      cfg.aprilFoolFeatures = value ?? false;
                      setState(() {});
                    },
                  )
              ],
            ),
          ],
        ).padding(vertical: 20),
      ),
    );
  }
}
