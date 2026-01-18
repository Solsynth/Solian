// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PluginRegistryNotifier)
final pluginRegistryProvider = PluginRegistryNotifierProvider._();

final class PluginRegistryNotifierProvider
    extends $NotifierProvider<PluginRegistryNotifier, PluginRegistry> {
  PluginRegistryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginRegistryNotifierHash();

  @$internal
  @override
  PluginRegistryNotifier create() => PluginRegistryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PluginRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PluginRegistry>(value),
    );
  }
}

String _$pluginRegistryNotifierHash() =>
    r'287b3a9e5598b279b80293dd37fe5a825395c8e3';

abstract class _$PluginRegistryNotifier extends $Notifier<PluginRegistry> {
  PluginRegistry build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PluginRegistry, PluginRegistry>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PluginRegistry, PluginRegistry>,
              PluginRegistry,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
