import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kTokenPairStoreKey = 'dyn_user_tk';

const kNetworkServerDefault = 'http://localhost:5071';
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

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final imageQualityProvider = Provider<FilterQuality>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return kImageQualityLevel.values.elementAtOrNull(
        prefs.getInt('app_image_quality') ?? 3,
      ) ??
      FilterQuality.high;
});

final serverUrlProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
});

class AppSettings {
  final bool realmCompactView;
  final bool mixedFeed;
  final bool autoTranslate;
  final bool hideBottomNav;
  final bool soundEffects;
  final bool aprilFoolFeatures;

  AppSettings({
    required this.realmCompactView,
    required this.mixedFeed,
    required this.autoTranslate,
    required this.hideBottomNav,
    required this.soundEffects,
    required this.aprilFoolFeatures,
  });

  AppSettings copyWith({
    bool? realmCompactView,
    bool? mixedFeed,
    bool? autoTranslate,
    bool? hideBottomNav,
    bool? soundEffects,
    bool? aprilFoolFeatures,
  }) {
    return AppSettings(
      realmCompactView: realmCompactView ?? this.realmCompactView,
      mixedFeed: mixedFeed ?? this.mixedFeed,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      hideBottomNav: hideBottomNav ?? this.hideBottomNav,
      soundEffects: soundEffects ?? this.soundEffects,
      aprilFoolFeatures: aprilFoolFeatures ?? this.aprilFoolFeatures,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences prefs;

  AppSettingsNotifier(this.prefs)
    : super(
        AppSettings(
          realmCompactView: prefs.getBool(kAppRealmCompactView) ?? false,
          mixedFeed: prefs.getBool(kAppMixedFeed) ?? true,
          autoTranslate: prefs.getBool(kAppAutoTranslate) ?? false,
          hideBottomNav: prefs.getBool(kAppHideBottomNav) ?? false,
          soundEffects: prefs.getBool(kAppSoundEffects) ?? true,
          aprilFoolFeatures: prefs.getBool(kAppAprilFoolFeatures) ?? true,
        ),
      );

  void setRealmCompactView(bool value) {
    prefs.setBool(kAppRealmCompactView, value);
    state = state.copyWith(realmCompactView: value);
  }

  void setMixedFeed(bool value) {
    prefs.setBool(kAppMixedFeed, value);
    state = state.copyWith(mixedFeed: value);
  }

  void setAutoTranslate(bool value) {
    prefs.setBool(kAppAutoTranslate, value);
    state = state.copyWith(autoTranslate: value);
  }

  void setHideBottomNav(bool value) {
    prefs.setBool(kAppHideBottomNav, value);
    state = state.copyWith(hideBottomNav: value);
  }

  void setSoundEffects(bool value) {
    prefs.setBool(kAppSoundEffects, value);
    state = state.copyWith(soundEffects: value);
  }

  void setAprilFoolFeatures(bool value) {
    prefs.setBool(kAppAprilFoolFeatures, value);
    state = state.copyWith(aprilFoolFeatures: value);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppSettingsNotifier(prefs);
    });

final updateInfoProvider =
    StateNotifierProvider<UpdateInfoNotifier, (String?, String?)>((ref) {
      return UpdateInfoNotifier();
    });

class UpdateInfoNotifier extends StateNotifier<(String?, String?)> {
  UpdateInfoNotifier() : super((null, null));

  void setUpdate(String newVersion, String newChangelog) {
    state = (newVersion, newChangelog);
  }
}

final drawerCollapsedProvider = StateProvider<bool>((ref) => false);

void calcDrawerSize(
  WidgetRef ref,
  BuildContext context, {
  bool withMediaQuery = false,
}) {
  bool newDrawerIsCollapsed;
  if (withMediaQuery) {
    newDrawerIsCollapsed = MediaQuery.of(context).size.width < 600;
  } else {
    final rpb = ResponsiveBreakpoints.of(context);
    newDrawerIsCollapsed = rpb.smallerOrEqualTo(MOBILE);
  }

  final current = ref.read(drawerCollapsedProvider);
  if (newDrawerIsCollapsed != current) {
    ref.read(drawerCollapsedProvider.notifier).state = newDrawerIsCollapsed;
  }
}
