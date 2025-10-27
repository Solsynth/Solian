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

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsNotifierHash() =>
    r'22b695f2023e3251db3296858acd701f7211d757';

/// See also [AppSettingsNotifier].
@ProviderFor(AppSettingsNotifier)
final appSettingsNotifierProvider =
    AutoDisposeNotifierProvider<AppSettingsNotifier, AppSettings>.internal(
      AppSettingsNotifier.new,
      name: r'appSettingsNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$appSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppSettingsNotifier = AutoDisposeNotifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
