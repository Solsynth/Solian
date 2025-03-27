import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/providers/widget.dart';

const kAtkStoreKey = 'nex_user_atk';
const kRtkStoreKey = 'nex_user_rtk';

const kNetworkServerDefault = 'https://api.sn.solsynth.dev';
const kNetworkServerStoreKey = 'app_server_url';

const kAppbarTransparentStoreKey = 'app_bar_transparent';
const kAppBackgroundStoreKey = 'app_has_background';
const kAppColorSchemeStoreKey = 'app_color_scheme';
const kAppNotifyWithHaptic = 'app_notify_with_haptic';
const kAppExpandPostLink = 'app_expand_post_link';
const kAppExpandChatLink = 'app_expand_chat_link';
const kAppRealmCompactView = 'app_realm_compact_view';
const kAppCustomFonts = 'app_custom_fonts';
const kAppMixedFeed = 'app_mixed_feed';
const kAppAutoTranslate = 'app_auto_translate';
const kAppHideBottomNav = 'app_hide_bottom_nav';
const kAppSoundEffects = 'app_sound_effects';
const kAppAprilFoolFeatures = 'app_april_fool_features';
const kAppWindowSize = 'app_window_size';

const Map<String, FilterQuality> kImageQualityLevel = {
  'settingsImageQualityLowest': FilterQuality.none,
  'settingsImageQualityLow': FilterQuality.low,
  'settingsImageQualityMedium': FilterQuality.medium,
  'settingsImageQualityHigh': FilterQuality.high,
};

class ConfigProvider extends ChangeNotifier {
  late final SharedPreferences prefs;

  late final HomeWidgetProvider _home;

  ConfigProvider(BuildContext context) {
    _home = context.read<HomeWidgetProvider>();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool drawerIsCollapsed = false;

  void calcDrawerSize(BuildContext context, {bool withMediaQuery = false}) {
    bool newDrawerIsCollapsed = false;
    if (withMediaQuery) {
      newDrawerIsCollapsed = MediaQuery.of(context).size.width < 600;
    } else {
      final rpb = ResponsiveBreakpoints.of(context);
      newDrawerIsCollapsed = rpb.smallerOrEqualTo(MOBILE);
    }

    if (newDrawerIsCollapsed != drawerIsCollapsed) {
      drawerIsCollapsed = newDrawerIsCollapsed;
      notifyListeners();
    }
  }

  FilterQuality get imageQuality {
    return kImageQualityLevel.values
            .elementAtOrNull(prefs.getInt('app_image_quality') ?? 3) ??
        FilterQuality.high;
  }

  String get serverUrl {
    return prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
  }

  bool get realmCompactView {
    return prefs.getBool(kAppRealmCompactView) ?? false;
  }

  bool get mixedFeed {
    return prefs.getBool(kAppMixedFeed) ?? true;
  }

  bool get autoTranslate {
    return prefs.getBool(kAppAutoTranslate) ?? false;
  }

  bool get hideBottomNav {
    return prefs.getBool(kAppHideBottomNav) ?? false;
  }

  bool get aprilFoolFeatures {
    return prefs.getBool(kAppAprilFoolFeatures) ?? true;
  }

  bool get soundEffects {
    return prefs.getBool(kAppSoundEffects) ?? true;
  }

  set soundEffects(bool value) {
    prefs.setBool(kAppSoundEffects, value);
    notifyListeners();
  }

  set aprilFoolFeatures(bool value) {
    prefs.setBool(kAppAprilFoolFeatures, value);
    notifyListeners();
  }

  set hideBottomNav(bool value) {
    prefs.setBool(kAppHideBottomNav, value);
    notifyListeners();
  }

  set autoTranslate(bool value) {
    prefs.setBool(kAppAutoTranslate, value);
    notifyListeners();
  }

  set mixedFeed(bool value) {
    prefs.setBool(kAppMixedFeed, value);
    notifyListeners();
  }

  set realmCompactView(bool value) {
    prefs.setBool(kAppRealmCompactView, value);
    notifyListeners();
  }

  set serverUrl(String url) {
    prefs.setString(kNetworkServerStoreKey, url);
    _home.saveWidgetData("nex_server_url", url);
  }

  String? updatableVersion;
  String? updatableChangelog;

  void setUpdate(String newVersion, String newChangelog) {
    updatableVersion = newVersion;
    updatableChangelog = newChangelog;
    notifyListeners();
  }
}
