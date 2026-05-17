// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IpOverride _$IpOverrideFromJson(Map<String, dynamic> json) => _IpOverride(
  ip: json['ip'] as String,
  port: (json['port'] as num?)?.toInt(),
);

Map<String, dynamic> _$IpOverrideToJson(_IpOverride instance) =>
    <String, dynamic>{'ip': instance.ip, 'port': instance.port};

_IpOverrideSettings _$IpOverrideSettingsFromJson(Map<String, dynamic> json) =>
    _IpOverrideSettings(
      enabled: json['enabled'] as bool,
      overrides: (json['overrides'] as List<dynamic>)
          .map((e) => IpOverride.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IpOverrideSettingsToJson(_IpOverrideSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'overrides': instance.overrides.map((e) => e.toJson()).toList(),
    };

_ThemeColors _$ThemeColorsFromJson(Map<String, dynamic> json) => _ThemeColors(
  primary: (json['primary'] as num?)?.toInt(),
  onPrimary: (json['on_primary'] as num?)?.toInt(),
  primaryContainer: (json['primary_container'] as num?)?.toInt(),
  secondary: (json['secondary'] as num?)?.toInt(),
  onSecondary: (json['on_secondary'] as num?)?.toInt(),
  secondaryContainer: (json['secondary_container'] as num?)?.toInt(),
  tertiary: (json['tertiary'] as num?)?.toInt(),
  onTertiary: (json['on_tertiary'] as num?)?.toInt(),
  tertiaryContainer: (json['tertiary_container'] as num?)?.toInt(),
  surface: (json['surface'] as num?)?.toInt(),
  surfaceContainerHighest: (json['surface_container_highest'] as num?)?.toInt(),
  background: (json['background'] as num?)?.toInt(),
  outline: (json['outline'] as num?)?.toInt(),
  shadow: (json['shadow'] as num?)?.toInt(),
  error: (json['error'] as num?)?.toInt(),
);

Map<String, dynamic> _$ThemeColorsToJson(_ThemeColors instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'on_primary': instance.onPrimary,
      'primary_container': instance.primaryContainer,
      'secondary': instance.secondary,
      'on_secondary': instance.onSecondary,
      'secondary_container': instance.secondaryContainer,
      'tertiary': instance.tertiary,
      'on_tertiary': instance.onTertiary,
      'tertiary_container': instance.tertiaryContainer,
      'surface': instance.surface,
      'surface_container_highest': instance.surfaceContainerHighest,
      'background': instance.background,
      'outline': instance.outline,
      'shadow': instance.shadow,
      'error': instance.error,
    };

_DashboardConfig _$DashboardConfigFromJson(Map<String, dynamic> json) =>
    _DashboardConfig(
      verticalLayouts: (json['vertical_layouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      horizontalLayouts: (json['horizontal_layouts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      showSearchBar: json['show_search_bar'] as bool,
      showClockAndCountdown: json['show_clock_and_countdown'] as bool,
    );

Map<String, dynamic> _$DashboardConfigToJson(_DashboardConfig instance) =>
    <String, dynamic>{
      'vertical_layouts': instance.verticalLayouts,
      'horizontal_layouts': instance.horizontalLayouts,
      'show_search_bar': instance.showSearchBar,
      'show_clock_and_countdown': instance.showClockAndCountdown,
    };

_ExploreSettings _$ExploreSettingsFromJson(Map<String, dynamic> json) =>
    _ExploreSettings(
      mode: json['mode'] as String? ?? 'personalized',
      aggressiveMode: json['aggressive_mode'] as bool? ?? true,
      selectedPublisherNames:
          (json['selected_publisher_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      selectedCategoryIds:
          (json['selected_category_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      selectedTagIds:
          (json['selected_tag_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ExploreSettingsToJson(_ExploreSettings instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'aggressive_mode': instance.aggressiveMode,
      'selected_publisher_names': instance.selectedPublisherNames,
      'selected_category_ids': instance.selectedCategoryIds,
      'selected_tag_ids': instance.selectedTagIds,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppSettingsNotifier)
final appSettingsProvider = AppSettingsNotifierProvider._();

final class AppSettingsNotifierProvider
    extends $NotifierProvider<AppSettingsNotifier, AppSettings> {
  AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$appSettingsNotifierHash() =>
    r'1a3faa82e2ed24e28f00ec34bdd707a978cbe8bb';

abstract class _$AppSettingsNotifier extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
