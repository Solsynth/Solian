// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought_chat_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing thought chat state

@ProviderFor(ThoughtChatNotifier)
final thoughtChatProvider = ThoughtChatNotifierFamily._();

/// Notifier for managing thought chat state
final class ThoughtChatNotifierProvider
    extends $NotifierProvider<ThoughtChatNotifier, ThoughtChatState> {
  /// Notifier for managing thought chat state
  ThoughtChatNotifierProvider._({
    required ThoughtChatNotifierFamily super.from,
    required ThoughtChatArgs super.argument,
  }) : super(
         retry: null,
         name: r'thoughtChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$thoughtChatNotifierHash();

  @override
  String toString() {
    return r'thoughtChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ThoughtChatNotifier create() => ThoughtChatNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThoughtChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThoughtChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThoughtChatNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$thoughtChatNotifierHash() =>
    r'321abcce93eb53039be449ae742fce6b4a314144';

/// Notifier for managing thought chat state

final class ThoughtChatNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ThoughtChatNotifier,
          ThoughtChatState,
          ThoughtChatState,
          ThoughtChatState,
          ThoughtChatArgs
        > {
  ThoughtChatNotifierFamily._()
    : super(
        retry: null,
        name: r'thoughtChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for managing thought chat state

  ThoughtChatNotifierProvider call(ThoughtChatArgs args) =>
      ThoughtChatNotifierProvider._(argument: args, from: this);

  @override
  String toString() => r'thoughtChatProvider';
}

/// Notifier for managing thought chat state

abstract class _$ThoughtChatNotifier extends $Notifier<ThoughtChatState> {
  late final _$args = ref.$arg as ThoughtChatArgs;
  ThoughtChatArgs get args => _$args;

  ThoughtChatState build(ThoughtChatArgs args);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThoughtChatState, ThoughtChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThoughtChatState, ThoughtChatState>,
              ThoughtChatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
