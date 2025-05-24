import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'config.freezed.dart';

const kTokenPairStoreKey = 'dyn_user_tk';

const kNetworkServerDefault = 'https://nt.solian.app';
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
const kAppEnterToSend = 'app_enter_to_send';

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

@freezed
sealed class AppSettings with _$AppSettings {
  const factory AppSettings({
    required bool autoTranslate,
    required bool soundEffects,
    required bool aprilFoolFeatures,
    required bool enterToSend,
  }) = _AppSettings;
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences prefs;

  AppSettingsNotifier(this.prefs)
    : super(
        AppSettings(
          autoTranslate: prefs.getBool(kAppAutoTranslate) ?? false,
          soundEffects: prefs.getBool(kAppSoundEffects) ?? true,
          aprilFoolFeatures: prefs.getBool(kAppAprilFoolFeatures) ?? true,
          enterToSend: prefs.getBool(kAppEnterToSend) ?? true,
        ),
      );

  void setAutoTranslate(bool value) {
    prefs.setBool(kAppAutoTranslate, value);
    state = state.copyWith(autoTranslate: value);
  }

  void setSoundEffects(bool value) {
    prefs.setBool(kAppSoundEffects, value);
    state = state.copyWith(soundEffects: value);
  }

  void setAprilFoolFeatures(bool value) {
    prefs.setBool(kAppAprilFoolFeatures, value);
    state = state.copyWith(aprilFoolFeatures: value);
  }

  void setEnterToSend(bool value) {
    prefs.setBool(kAppEnterToSend, value);
    state = state.copyWith(enterToSend: value);
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
