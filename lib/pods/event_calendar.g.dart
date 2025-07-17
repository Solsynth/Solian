// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_calendar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventCalendarHash() => r'72232fc044ac3c99b855dca37ff2f06a64be0afb';

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

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed
///
/// Copied from [eventCalendar].
@ProviderFor(eventCalendar)
const eventCalendarProvider = EventCalendarFamily();

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed
///
/// Copied from [eventCalendar].
class EventCalendarFamily
    extends Family<AsyncValue<List<SnEventCalendarEntry>>> {
  /// Provider for fetching event calendar data
  /// This can be used anywhere in the app where calendar data is needed
  ///
  /// Copied from [eventCalendar].
  const EventCalendarFamily();

  /// Provider for fetching event calendar data
  /// This can be used anywhere in the app where calendar data is needed
  ///
  /// Copied from [eventCalendar].
  EventCalendarProvider call(EventCalendarQuery query) {
    return EventCalendarProvider(query);
  }

  @override
  EventCalendarProvider getProviderOverride(
    covariant EventCalendarProvider provider,
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
  String? get name => r'eventCalendarProvider';
}

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed
///
/// Copied from [eventCalendar].
class EventCalendarProvider
    extends AutoDisposeFutureProvider<List<SnEventCalendarEntry>> {
  /// Provider for fetching event calendar data
  /// This can be used anywhere in the app where calendar data is needed
  ///
  /// Copied from [eventCalendar].
  EventCalendarProvider(EventCalendarQuery query)
    : this._internal(
        (ref) => eventCalendar(ref as EventCalendarRef, query),
        from: eventCalendarProvider,
        name: r'eventCalendarProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$eventCalendarHash,
        dependencies: EventCalendarFamily._dependencies,
        allTransitiveDependencies:
            EventCalendarFamily._allTransitiveDependencies,
        query: query,
      );

  EventCalendarProvider._internal(
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
    FutureOr<List<SnEventCalendarEntry>> Function(EventCalendarRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventCalendarProvider._internal(
        (ref) => create(ref as EventCalendarRef),
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
    return _EventCalendarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventCalendarProvider && other.query == query;
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
mixin EventCalendarRef
    on AutoDisposeFutureProviderRef<List<SnEventCalendarEntry>> {
  /// The parameter `query` of this provider.
  EventCalendarQuery get query;
}

class _EventCalendarProviderElement
    extends AutoDisposeFutureProviderElement<List<SnEventCalendarEntry>>
    with EventCalendarRef {
  _EventCalendarProviderElement(super.provider);

  @override
  EventCalendarQuery get query => (origin as EventCalendarProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
