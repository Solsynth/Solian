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
const kAppDrawerPreferCollapse = 'app_drawer_prefer_collapse';
const kAppNotifyWithHaptic = 'app_notify_with_haptic';
const kAppExpandPostLink = 'app_expand_post_link';
const kAppExpandChatLink = 'app_expand_chat_link';
const kAppRealmCompactView = 'app_realm_compact_view';
const kAppCustomFonts = 'app_custom_fonts';

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
  bool drawerIsExpanded = false;

  void calcDrawerSize(BuildContext context, {bool withMediaQuery = false}) {
    bool newDrawerIsCollapsed = false;
    bool newDrawerIsExpanded = false;
    if (withMediaQuery) {
      newDrawerIsCollapsed = MediaQuery.of(context).size.width < 600;
      newDrawerIsExpanded = MediaQuery.of(context).size.width >= 601;
    } else {
      final rpb = ResponsiveBreakpoints.of(context);
      newDrawerIsCollapsed = rpb.smallerOrEqualTo(MOBILE);
      newDrawerIsExpanded = rpb.largerThan(TABLET)
          ? (prefs.getBool(kAppDrawerPreferCollapse) ?? false)
              ? false
              : true
          : false;
    }

    if (newDrawerIsExpanded != drawerIsExpanded ||
        newDrawerIsCollapsed != drawerIsCollapsed) {
      drawerIsExpanded = newDrawerIsExpanded;
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

  set realmCompactView(bool value) {
    prefs.setBool(kAppRealmCompactView, value);
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
