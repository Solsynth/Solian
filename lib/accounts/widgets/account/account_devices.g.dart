// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_devices.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authDevices)
final authDevicesProvider = AuthDevicesProvider._();

final class AuthDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResult<SnAuthDeviceWithSession>>,
          PaginatedResult<SnAuthDeviceWithSession>,
          FutureOr<PaginatedResult<SnAuthDeviceWithSession>>
        >
    with
        $FutureModifier<PaginatedResult<SnAuthDeviceWithSession>>,
        $FutureProvider<PaginatedResult<SnAuthDeviceWithSession>> {
  AuthDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authDevicesHash();

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnAuthDeviceWithSession>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnAuthDeviceWithSession>> create(Ref ref) {
    return authDevices(ref);
  }
}

String _$authDevicesHash() => r'bda95cc18e9ac420379b3679a4d20c9bbbe7076e';

/// Provider for root sessions only (sessions without parent or with children)

@ProviderFor(authSessions)
final authSessionsProvider = AuthSessionsFamily._();

/// Provider for root sessions only (sessions without parent or with children)

final class AuthSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResult<SnAuthSession>>,
          PaginatedResult<SnAuthSession>,
          FutureOr<PaginatedResult<SnAuthSession>>
        >
    with
        $FutureModifier<PaginatedResult<SnAuthSession>>,
        $FutureProvider<PaginatedResult<SnAuthSession>> {
  /// Provider for root sessions only (sessions without parent or with children)
  AuthSessionsProvider._({
    required AuthSessionsFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'authSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authSessionsHash();

  @override
  String toString() {
    return r'authSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnAuthSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnAuthSession>> create(Ref ref) {
    final argument = this.argument as int?;
    return authSessions(ref, type: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authSessionsHash() => r'386a68ceb81ba22246ff592001a922c21aaa3891';

/// Provider for root sessions only (sessions without parent or with children)

final class AuthSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedResult<SnAuthSession>>,
          int?
        > {
  AuthSessionsFamily._()
    : super(
        retry: null,
        name: r'authSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for root sessions only (sessions without parent or with children)

  AuthSessionsProvider call({int? type}) =>
      AuthSessionsProvider._(argument: type, from: this);

  @override
  String toString() => r'authSessionsProvider';
}

/// Provider for child sessions of a specific parent session

@ProviderFor(sessionChildren)
final sessionChildrenProvider = SessionChildrenFamily._();

/// Provider for child sessions of a specific parent session

final class SessionChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAuthSession>>,
          List<SnAuthSession>,
          FutureOr<List<SnAuthSession>>
        >
    with
        $FutureModifier<List<SnAuthSession>>,
        $FutureProvider<List<SnAuthSession>> {
  /// Provider for child sessions of a specific parent session
  SessionChildrenProvider._({
    required SessionChildrenFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionChildrenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionChildrenHash();

  @override
  String toString() {
    return r'sessionChildrenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnAuthSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAuthSession>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionChildren(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionChildrenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionChildrenHash() => r'70daa628c155405377f863372ae1994a7634c904';

/// Provider for child sessions of a specific parent session

final class SessionChildrenFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnAuthSession>>, String> {
  SessionChildrenFamily._()
    : super(
        retry: null,
        name: r'sessionChildrenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for child sessions of a specific parent session

  SessionChildrenProvider call(String parentId) =>
      SessionChildrenProvider._(argument: parentId, from: this);

  @override
  String toString() => r'sessionChildrenProvider';
}

@ProviderFor(SessionTypeFilter)
final sessionTypeFilterProvider = SessionTypeFilterProvider._();

final class SessionTypeFilterProvider
    extends $NotifierProvider<SessionTypeFilter, int?> {
  SessionTypeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTypeFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTypeFilterHash();

  @$internal
  @override
  SessionTypeFilter create() => SessionTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$sessionTypeFilterHash() => r'548b22f614e3e475871c87509fbeae2c647fc1cc';

abstract class _$SessionTypeFilter extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider to track expanded sessions

@ProviderFor(ExpandedSessions)
final expandedSessionsProvider = ExpandedSessionsProvider._();

/// Provider to track expanded sessions
final class ExpandedSessionsProvider
    extends $NotifierProvider<ExpandedSessions, Set<String>> {
  /// Provider to track expanded sessions
  ExpandedSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expandedSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expandedSessionsHash();

  @$internal
  @override
  ExpandedSessions create() => ExpandedSessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$expandedSessionsHash() => r'9c72c57c979e33ed10075b3eb49deb8935bbd4ac';

/// Provider to track expanded sessions

abstract class _$ExpandedSessions extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
