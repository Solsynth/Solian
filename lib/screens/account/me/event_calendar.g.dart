// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_calendar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountEventCalendarHash() =>
    r'57405caaf53a83d121b6bb4b70540134fb581525';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [accountEventCalendar].
@ProviderFor(accountEventCalendar)
const accountEventCalendarProvider = AccountEventCalendarFamily();

/// See also [accountEventCalendar].
class AccountEventCalendarFamily
    extends Family<AsyncValue<List<SnEventCalendarEntry>>> {
  /// See also [accountEventCalendar].
  const AccountEventCalendarFamily();

  /// See also [accountEventCalendar].
  AccountEventCalendarProvider call(EventCalendarQuery query) {
    return AccountEventCalendarProvider(query);
  }

  @override
  AccountEventCalendarProvider getProviderOverride(
    covariant AccountEventCalendarProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountEventCalendarProvider';
}

/// See also [accountEventCalendar].
class AccountEventCalendarProvider
    extends AutoDisposeFutureProvider<List<SnEventCalendarEntry>> {
  /// See also [accountEventCalendar].
  AccountEventCalendarProvider(EventCalendarQuery query)
    : this._internal(
        (ref) => accountEventCalendar(ref as AccountEventCalendarRef, query),
        from: accountEventCalendarProvider,
        name: r'accountEventCalendarProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountEventCalendarHash,
        dependencies: AccountEventCalendarFamily._dependencies,
        allTransitiveDependencies:
            AccountEventCalendarFamily._allTransitiveDependencies,
        query: query,
      );

  AccountEventCalendarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final EventCalendarQuery query;

  @override
  Override overrideWith(
    FutureOr<List<SnEventCalendarEntry>> Function(
      AccountEventCalendarRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountEventCalendarProvider._internal(
        (ref) => create(ref as AccountEventCalendarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnEventCalendarEntry>> createElement() {
    return _AccountEventCalendarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountEventCalendarProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountEventCalendarRef
    on AutoDisposeFutureProviderRef<List<SnEventCalendarEntry>> {
  /// The parameter `query` of this provider.
  EventCalendarQuery get query;
}

class _AccountEventCalendarProviderElement
    extends AutoDisposeFutureProviderElement<List<SnEventCalendarEntry>>
    with AccountEventCalendarRef {
  _AccountEventCalendarProviderElement(super.provider);

  @override
  EventCalendarQuery get query =>
      (origin as AccountEventCalendarProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
