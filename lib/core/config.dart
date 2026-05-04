import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

part 'config.freezed.dart';
part 'config.g.dart';

String localeToLanguageCode(Locale locale) {
  final lang = locale.languageCode;
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return '$lang-$country';
  }
  return lang;
}

const kTokenPairStoreKey = 'dyn_user_tk';

const kNetworkServerDefault = 'https://api.solian.app';
const kNetworkServerStoreKey = 'app_server_url';

const kAppbarTransparentStoreKey = 'app_bar_transparent';
const kAppBackgroundStoreKey = 'app_has_background';
const kAppShowBackgroundImage = 'app_show_background_image';
const kAppColorSchemeStoreKey = 'app_color_scheme';
const kAppCustomColorsStoreKey = 'app_custom_colors';
const kAppNotifyWithHaptic = 'app_notify_with_haptic';
const kAppEnableTts = 'app_enable_tts';
const kAppTtsVoice = 'app_tts_voice';
const kAppTtsSpeechRate = 'app_tts_speech_rate';
const kAppTtsPitch = 'app_tts_pitch';
const kAppTtsVolume = 'app_tts_volume';
const kAppTtsLanguage = 'app_tts_language';
const kAppCustomFonts = 'app_custom_fonts';
const kAppDataSavingMode = 'app_data_saving_mode';
const kAppSoundEffects = 'app_sound_effects';
const kAppFestivalFeatures = 'app_feastival_features';
const kAppWindowSize = 'app_window_size';
const kAppWindowOpacity = 'app_window_opacity';
const kAppCardTransparent = 'app_card_transparent';
const kAppEnterToSend = 'app_enter_to_send';
const kAppDefaultPoolId = 'app_default_pool_id';
const kAppMessageDisplayStyle = 'app_message_display_style';
const kAppAttachmentsListStyle = 'app_attachments_list_style';
const kAppLinkCollapseMode = 'app_link_collapse_mode';
const kAppThemeMode = 'app_theme_mode';
const kAppDisableAnimation = 'app_disable_animation';
const kAppGroupedChatList = 'app_grouped_chat_list';
const kFeaturedPostsCollapsedId =
    'featured_posts_collapsed_id'; // Key for storing the ID of the collapsed featured post
const kAppFirstLaunchAt = 'app_first_launch_at';
const kAppAskedReview = 'app_asked_review';
const kAppDashSearchEngine = 'app_dash_search_engine';
const kAppDefaultScreen = 'app_default_screen';
const kAppShowChatSystemMessages = 'app_show_chat_system_messages';
const kAppShowChatEventMessages = kAppShowChatSystemMessages;
const kAppChatEventMessageMode = 'app_chat_event_message_mode';
const kAppPushProvider = 'app_push_provider';
const kAppRealmDisplayMode = 'app_realm_display_mode';
const kChatEventMessageModeVerbose = 'verbose';
const kChatEventMessageModeImportant = 'important';
const kChatEventMessageModeNone = 'none';
const kAppDashboardConfig = 'app_dashboard_config';
const kRealmDisplayModeList = 'list';
const kRealmDisplayModeCard = 'card';
const kAppExploreSettings = 'app_explore_settings';
const kAppMediaProxyEnabled = 'app_media_proxy_enabled';
const kAppFriendStatusDesktopNotification =
    'app_friend_status_desktop_notification';

// Will be overrided by the ProviderScope
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final serverUrlProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
});

@freezed
sealed class ThemeColors with _$ThemeColors {
  factory ThemeColors({
    int? primary,
    int? secondary,
    int? tertiary,
    int? surface,
    int? background,
    int? error,
  }) = _ThemeColors;

  factory ThemeColors.fromJson(Map<String, dynamic> json) =>
      _$ThemeColorsFromJson(json);
}

@freezed
sealed class DashboardConfig with _$DashboardConfig {
  factory DashboardConfig({
    required List<String> verticalLayouts,
    required List<String> horizontalLayouts,
    required bool showSearchBar,
    required bool showClockAndCountdown,
  }) = _DashboardConfig;

  factory DashboardConfig.fromJson(Map<String, dynamic> json) =>
      _$DashboardConfigFromJson(json);
}

@freezed
sealed class ExploreSettings with _$ExploreSettings {
  const factory ExploreSettings({
    @Default('personalized') String mode,
    @Default(true) bool aggressiveMode,
    @Default(<String>[]) List<String> selectedPublisherNames,
    @Default(<String>[]) List<String> selectedCategoryIds,
    @Default(<String>[]) List<String> selectedTagIds,
  }) = _ExploreSettings;

  factory ExploreSettings.fromJson(Map<String, dynamic> json) =>
      _$ExploreSettingsFromJson(json);
}

@freezed
sealed class AppSettings with _$AppSettings {
  const factory AppSettings({
    required bool dataSavingMode,
    required bool soundEffects,
    required bool festivalFeatures,
    required bool enterToSend,
    required bool appBarTransparent,
    required bool showBackgroundImage,
    required bool notifyWithHaptic,
    required bool enableTts,
    required String? ttsVoice,
    required double ttsSpeechRate,
    required double ttsPitch,
    required double ttsVolume,
    required String ttsLanguage,
    required String? customFonts,
    required int? appColorScheme, // The color stored via the int type
    required ThemeColors? customColors,
    required Size? windowSize, // The window size for desktop platforms
    required double windowOpacity, // The window opacity for desktop platforms
    required double cardTransparency, // The card background opacity
    required String? defaultPoolId,
    required String messageDisplayStyle,
    required String attachmentsListStyle,
    required String linkCollapseMode,
    required String? themeMode,
    required bool disableAnimation,
    required bool groupedChatList,
    required String? firstLaunchAt,
    required bool askedReview,
    required String? dashSearchEngine,
    required String? defaultScreen,
    required String realmDisplayMode,
    required String chatEventMessageMode,
    required bool showChatSystemMessages,
    required DashboardConfig? dashboardConfig,
    required ExploreSettings exploreSettings,
    required bool mediaProxyEnabled,
    required bool friendStatusDesktopNotification,
  }) = _AppSettings;
}

@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final legacyShowSystemMessages =
        prefs.getBool(kAppShowChatSystemMessages) ?? false;
    final chatEventMessageMode =
        prefs.getString(kAppChatEventMessageMode) ??
        (legacyShowSystemMessages
            ? kChatEventMessageModeVerbose
            : kChatEventMessageModeNone);

    return AppSettings(
      dataSavingMode: prefs.getBool(kAppDataSavingMode) ?? false,
      soundEffects: prefs.getBool(kAppSoundEffects) ?? true,
      festivalFeatures: prefs.getBool(kAppFestivalFeatures) ?? true,
      enterToSend: prefs.getBool(kAppEnterToSend) ?? true,
      appBarTransparent: prefs.getBool(kAppbarTransparentStoreKey) ?? false,
      showBackgroundImage: prefs.getBool(kAppShowBackgroundImage) ?? true,
      notifyWithHaptic: prefs.getBool(kAppNotifyWithHaptic) ?? true,
      enableTts: prefs.getBool(kAppEnableTts) ?? false,
      ttsVoice: prefs.getString(kAppTtsVoice),
      ttsSpeechRate: prefs.getDouble(kAppTtsSpeechRate) ?? 1.0,
      ttsPitch: prefs.getDouble(kAppTtsPitch) ?? 1.0,
      ttsVolume: prefs.getDouble(kAppTtsVolume) ?? 1.0,
      ttsLanguage: prefs.getString(kAppTtsLanguage) ?? 'en-US',
      customFonts: prefs.getString(kAppCustomFonts),
      appColorScheme: prefs.getInt(kAppColorSchemeStoreKey),
      customColors: _getThemeColorsFromPrefs(prefs),
      windowSize: _getWindowSizeFromPrefs(prefs),
      windowOpacity: prefs.getDouble(kAppWindowOpacity) ?? 1.0,
      cardTransparency: prefs.getDouble(kAppCardTransparent) ?? 1.0,
      defaultPoolId: prefs.getString(kAppDefaultPoolId),
      messageDisplayStyle: prefs.getString(kAppMessageDisplayStyle) ?? 'bubble',
      attachmentsListStyle: prefs.getString(kAppAttachmentsListStyle) ?? 'row',
      linkCollapseMode: prefs.getString(kAppLinkCollapseMode) ?? 'expand',
      themeMode: prefs.getString(kAppThemeMode) ?? 'system',
      disableAnimation: prefs.getBool(kAppDisableAnimation) ?? false,
      groupedChatList: prefs.getBool(kAppGroupedChatList) ?? false,
      askedReview: prefs.getBool(kAppAskedReview) ?? false,
      firstLaunchAt: prefs.getString(kAppFirstLaunchAt),
      dashSearchEngine: prefs.getString(kAppDashSearchEngine),
      defaultScreen: prefs.getString(kAppDefaultScreen),
      realmDisplayMode:
          prefs.getString(kAppRealmDisplayMode) ?? kRealmDisplayModeCard,
      chatEventMessageMode: chatEventMessageMode,
      showChatSystemMessages: chatEventMessageMode != kChatEventMessageModeNone,
      dashboardConfig: _getDashboardConfigFromPrefs(prefs),
      exploreSettings: _getExploreSettingsFromPrefs(prefs),
      mediaProxyEnabled: prefs.getBool(kAppMediaProxyEnabled) ?? true,
      friendStatusDesktopNotification:
          prefs.getBool(kAppFriendStatusDesktopNotification) ?? true,
    );
  }

  Size? _getWindowSizeFromPrefs(SharedPreferences prefs) {
    final sizeString = prefs.getString(kAppWindowSize);
    if (sizeString == null) return null;

    try {
      final parts = sizeString.split(',');
      if (parts.length == 2) {
        final width = double.parse(parts[0]);
        final height = double.parse(parts[1]);
        return Size(width, height);
      }
    } catch (e) {
      // Invalid format, return null
    }
    return null;
  }

  ThemeColors? _getThemeColorsFromPrefs(SharedPreferences prefs) {
    final jsonString = prefs.getString(kAppCustomColorsStoreKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      return ThemeColors.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  DashboardConfig? _getDashboardConfigFromPrefs(SharedPreferences prefs) {
    final jsonString = prefs.getString(kAppDashboardConfig);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      return DashboardConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  ExploreSettings _getExploreSettingsFromPrefs(SharedPreferences prefs) {
    final jsonString = prefs.getString(kAppExploreSettings);
    if (jsonString == null) return const ExploreSettings();

    try {
      final json = jsonDecode(jsonString);
      return ExploreSettings.fromJson(json);
    } catch (e) {
      return const ExploreSettings();
    }
  }

  void setDefaultPoolId(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      prefs.setString(kAppDefaultPoolId, value);
    } else {
      prefs.remove(kAppDefaultPoolId);
    }
    state = state.copyWith(defaultPoolId: value);
  }

  void setDataSavingMode(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppDataSavingMode, value);
    state = state.copyWith(dataSavingMode: value);
  }

  void setSoundEffects(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppSoundEffects, value);
    state = state.copyWith(soundEffects: value);
  }

  void setFeativalFeatures(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppFestivalFeatures, value);
    state = state.copyWith(festivalFeatures: value);
  }

  void setEnterToSend(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppEnterToSend, value);
    state = state.copyWith(enterToSend: value);
  }

  void setAppBarTransparent(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppbarTransparentStoreKey, value);
    state = state.copyWith(appBarTransparent: value);
  }

  void setShowBackgroundImage(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppShowBackgroundImage, value);
    state = state.copyWith(showBackgroundImage: value);
  }

  void setNotifyWithHaptic(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppNotifyWithHaptic, value);
    state = state.copyWith(notifyWithHaptic: value);
  }

  void setEnableTts(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppEnableTts, value);
    state = state.copyWith(enableTts: value);
  }

  void setTtsVoice(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      prefs.setString(kAppTtsVoice, value);
    } else {
      prefs.remove(kAppTtsVoice);
    }
    state = state.copyWith(ttsVoice: value);
  }

  void setTtsSpeechRate(double value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(kAppTtsSpeechRate, value);
    state = state.copyWith(ttsSpeechRate: value);
  }

  void setTtsPitch(double value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(kAppTtsPitch, value);
    state = state.copyWith(ttsPitch: value);
  }

  void setTtsVolume(double value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(kAppTtsVolume, value);
    state = state.copyWith(ttsVolume: value);
  }

  void setTtsLanguage(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppTtsLanguage, value);
    state = state.copyWith(ttsLanguage: value);
  }

  void setCustomFonts(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppCustomFonts, value ?? '');
    state = state.copyWith(customFonts: value);
  }

  void setDefaultScreen(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppDefaultScreen, value ?? 'dashboard');
    state = state.copyWith(defaultScreen: value);
  }

  void setAppColorScheme(int? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt(kAppColorSchemeStoreKey, value ?? 0);
    state = state.copyWith(appColorScheme: value);
  }

  void setWindowSize(Size? size) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (size != null) {
      prefs.setString(kAppWindowSize, '${size.width},${size.height}');
    } else {
      prefs.remove(kAppWindowSize);
    }
    state = state.copyWith(windowSize: size);
  }

  Size? getWindowSize() {
    return state.windowSize;
  }

  void setMessageDisplayStyle(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppMessageDisplayStyle, value);
    state = state.copyWith(messageDisplayStyle: value);
  }

  void setAttachmentsListStyle(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppAttachmentsListStyle, value);
    state = state.copyWith(attachmentsListStyle: value);
  }

  void setLinkCollapseMode(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppLinkCollapseMode, value);
    state = state.copyWith(linkCollapseMode: value);
  }

  void setWindowOpacity(double value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(kAppWindowOpacity, value);
    state = state.copyWith(windowOpacity: value);
    Future(() => windowManager.setOpacity(value));
  }

  void setThemeMode(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    final oldValue = state.themeMode;
    prefs.setString(kAppThemeMode, value);
    state = state.copyWith(themeMode: value);

    AnalyticsService().logThemeChanged(oldValue ?? 'system', value);
  }

  void setAppTransparentBackground(double value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(kAppCardTransparent, value);
    state = state.copyWith(cardTransparency: value);
  }

  void setCustomColors(ThemeColors? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      final json = jsonEncode(value.toJson());
      prefs.setString(kAppCustomColorsStoreKey, json);
    } else {
      prefs.remove(kAppCustomColorsStoreKey);
    }
    state = state.copyWith(customColors: value);
  }

  void setDisableAnimation(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppDisableAnimation, value);
    state = state.copyWith(disableAnimation: value);
  }

  void setGroupedChatList(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppGroupedChatList, value);
    state = state.copyWith(groupedChatList: value);
  }

  void setFirstLaunchAt(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      prefs.setString(kAppFirstLaunchAt, value);
    } else {
      prefs.remove(kAppFirstLaunchAt);
    }
    state = state.copyWith(firstLaunchAt: value);
  }

  void setAskedReview(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppAskedReview, value);
    state = state.copyWith(askedReview: value);
  }

  void setDashSearchEngine(String? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      prefs.setString(kAppDashSearchEngine, value);
    } else {
      prefs.remove(kAppDashSearchEngine);
    }
    state = state.copyWith(dashSearchEngine: value);
  }

  void setRealmDisplayMode(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppRealmDisplayMode, value);
    state = state.copyWith(realmDisplayMode: value);
  }

  void setShowChatSystemMessages(bool value) {
    final mode = value
        ? kChatEventMessageModeVerbose
        : kChatEventMessageModeNone;
    setChatEventMessageMode(mode);
  }

  void setChatEventMessageMode(String value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(kAppChatEventMessageMode, value);
    prefs.setBool(
      kAppShowChatSystemMessages,
      value != kChatEventMessageModeNone,
    );
    state = state.copyWith(
      chatEventMessageMode: value,
      showChatSystemMessages: value != kChatEventMessageModeNone,
    );
  }

  void setShowChatEventMessages(bool value) {
    setShowChatSystemMessages(value);
  }

  void setDashboardConfig(DashboardConfig? value) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value != null) {
      final json = jsonEncode(value.toJson());
      prefs.setString(kAppDashboardConfig, json);
    } else {
      prefs.remove(kAppDashboardConfig);
    }
    state = state.copyWith(dashboardConfig: value);
  }

  void resetDashboardConfig() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.remove(kAppDashboardConfig);
    state = state.copyWith(dashboardConfig: null);
  }

  void setExploreSettings(ExploreSettings value) {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = jsonEncode(value.toJson());
    prefs.setString(kAppExploreSettings, json);
    state = state.copyWith(exploreSettings: value);
  }

  void setMediaProxyEnabled(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppMediaProxyEnabled, value);
    state = state.copyWith(mediaProxyEnabled: value);
  }

  void setFriendStatusDesktopNotification(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppFriendStatusDesktopNotification, value);
    state = state.copyWith(friendStatusDesktopNotification: value);
  }
}

final updateInfoProvider =
    NotifierProvider<UpdateInfoNotifier, (String?, String?)>(
      UpdateInfoNotifier.new,
    );

class UpdateInfoNotifier extends Notifier<(String?, String?)> {
  @override
  (String?, String?) build() {
    return (null, null);
  }

  void setUpdate(String newVersion, String newChangelog) {
    state = (newVersion, newChangelog);
  }
}
