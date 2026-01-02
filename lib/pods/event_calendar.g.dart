// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_calendar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed

@ProviderFor(eventCalendar)
final eventCalendarProvider = EventCalendarFamily._();

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed

final class EventCalendarProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnEventCalendarEntry>>,
          List<SnEventCalendarEntry>,
          FutureOr<List<SnEventCalendarEntry>>
        >
    with
        $FutureModifier<List<SnEventCalendarEntry>>,
        $FutureProvider<List<SnEventCalendarEntry>> {
  /// Provider for fetching event calendar data
  /// This can be used anywhere in the app where calendar data is needed
  EventCalendarProvider._({
    required EventCalendarFamily super.from,
    required EventCalendarQuery super.argument,
  }) : super(
         retry: null,
         name: r'eventCalendarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventCalendarHash();

  @override
  String toString() {
    return r'eventCalendarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnEventCalendarEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnEventCalendarEntry>> create(Ref ref) {
    final argument = this.argument as EventCalendarQuery;
    return eventCalendar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventCalendarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventCalendarHash() => r'3a33581c28bcd44bc5eb3abdb770171b4d275a5d';

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed

final class EventCalendarFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnEventCalendarEntry>>,
          EventCalendarQuery
        > {
  EventCalendarFamily._()
    : super(
        retry: null,
        name: r'eventCalendarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching event calendar data
  /// This can be used anywhere in the app where calendar data is needed

  EventCalendarProvider call(EventCalendarQuery query) =>
      EventCalendarProvider._(argument: query, from: this);

  @override
  String toString() => r'eventCalendarProvider';
}
