// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeColors _$ThemeColorsFromJson(Map<String, dynamic> json) => _ThemeColors(
  primary: (json['primary'] as num?)?.toInt(),
  secondary: (json['secondary'] as num?)?.toInt(),
  tertiary: (json['tertiary'] as num?)?.toInt(),
  surface: (json['surface'] as num?)?.toInt(),
  background: (json['background'] as num?)?.toInt(),
  error: (json['error'] as num?)?.toInt(),
);

Map<String, dynamic> _$ThemeColorsToJson(_ThemeColors instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'secondary': instance.secondary,
      'tertiary': instance.tertiary,
      'surface': instance.surface,
      'background': instance.background,
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
    r'fc474771ced89ec8637c0f773a9c6bc392f0df60';

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
