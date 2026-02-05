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

const kTokenPairStoreKey = 'dyn_user_tk';

const kNetworkServerDefault = 'https://api.solian.app';
const kNetworkServerStoreKey = 'app_server_url';

const kAppbarTransparentStoreKey = 'app_bar_transparent';
const kAppBackgroundStoreKey = 'app_has_background';
const kAppShowBackgroundImage = 'app_show_background_image';
const kAppColorSchemeStoreKey = 'app_color_scheme';
const kAppCustomColorsStoreKey = 'app_custom_colors';
const kAppNotifyWithHaptic = 'app_notify_with_haptic';
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
const kAppThemeMode = 'app_theme_mode';
const kAppDisableAnimation = 'app_disable_animation';
const kAppGroupedChatList = 'app_grouped_chat_list';
const kFeaturedPostsCollapsedId =
    'featured_posts_collapsed_id'; // Key for storing the ID of the collapsed featured post
const kAppFirstLaunchAt = 'app_first_launch_at';
const kAppAskedReview = 'app_asked_review';
const kAppDashSearchEngine = 'app_dash_search_engine';
const kAppDefaultScreen = 'app_default_screen';
const kAppShowFediverseContent = 'app_show_fediverse_content';
const kAppDashboardConfig = 'app_dashboard_config';

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
sealed class AppSettings with _$AppSettings {
  const factory AppSettings({
    required bool dataSavingMode,
    required bool soundEffects,
    required bool festivalFeatures,
    required bool enterToSend,
    required bool appBarTransparent,
    required bool showBackgroundImage,
    required bool notifyWithHaptic,
    required String? customFonts,
    required int? appColorScheme, // The color stored via the int type
    required ThemeColors? customColors,
    required Size? windowSize, // The window size for desktop platforms
    required double windowOpacity, // The window opacity for desktop platforms
    required double cardTransparency, // The card background opacity
    required String? defaultPoolId,
    required String messageDisplayStyle,
    required String? themeMode,
    required bool disableAnimation,
    required bool groupedChatList,
    required String? firstLaunchAt,
    required bool askedReview,
    required String? dashSearchEngine,
    required String? defaultScreen,
    required bool showFediverseContent,
    required DashboardConfig? dashboardConfig,
  }) = _AppSettings;
}

@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      dataSavingMode: prefs.getBool(kAppDataSavingMode) ?? false,
      soundEffects: prefs.getBool(kAppSoundEffects) ?? true,
      festivalFeatures: prefs.getBool(kAppFestivalFeatures) ?? true,
      enterToSend: prefs.getBool(kAppEnterToSend) ?? true,
      appBarTransparent: prefs.getBool(kAppbarTransparentStoreKey) ?? false,
      showBackgroundImage: prefs.getBool(kAppShowBackgroundImage) ?? true,
      notifyWithHaptic: prefs.getBool(kAppNotifyWithHaptic) ?? true,
      customFonts: prefs.getString(kAppCustomFonts),
      appColorScheme: prefs.getInt(kAppColorSchemeStoreKey),
      customColors: _getThemeColorsFromPrefs(prefs),
      windowSize: _getWindowSizeFromPrefs(prefs),
      windowOpacity: prefs.getDouble(kAppWindowOpacity) ?? 1.0,
      cardTransparency: prefs.getDouble(kAppCardTransparent) ?? 1.0,
      defaultPoolId: prefs.getString(kAppDefaultPoolId),
      messageDisplayStyle: prefs.getString(kAppMessageDisplayStyle) ?? 'bubble',
      themeMode: prefs.getString(kAppThemeMode) ?? 'system',
      disableAnimation: prefs.getBool(kAppDisableAnimation) ?? false,
      groupedChatList: prefs.getBool(kAppGroupedChatList) ?? false,
      askedReview: prefs.getBool(kAppAskedReview) ?? false,
      firstLaunchAt: prefs.getString(kAppFirstLaunchAt),
      dashSearchEngine: prefs.getString(kAppDashSearchEngine),
      defaultScreen: prefs.getString(kAppDefaultScreen),
      showFediverseContent: prefs.getBool(kAppShowFediverseContent) ?? true,
      dashboardConfig: _getDashboardConfigFromPrefs(prefs),
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

  void setShowFediverseContent(bool value) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppShowFediverseContent, value);
    state = state.copyWith(showFediverseContent: value);
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