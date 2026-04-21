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

String _$eventCalendarHash() => r'634eacca82ace3c047cb5254f36d3d47cf914e8e';

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

/// Provider for fetching merged calendar for a specific month

@ProviderFor(mergedCalendar)
final mergedCalendarProvider = MergedCalendarFamily._();

/// Provider for fetching merged calendar for a specific month

final class MergedCalendarProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnEventCalendarEntry>,
          SnEventCalendarEntry,
          FutureOr<SnEventCalendarEntry>
        >
    with
        $FutureModifier<SnEventCalendarEntry>,
        $FutureProvider<SnEventCalendarEntry> {
  /// Provider for fetching merged calendar for a specific month
  MergedCalendarProvider._({
    required MergedCalendarFamily super.from,
    required ({int year, int month, String? username}) super.argument,
  }) : super(
         retry: null,
         name: r'mergedCalendarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mergedCalendarHash();

  @override
  String toString() {
    return r'mergedCalendarProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SnEventCalendarEntry> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnEventCalendarEntry> create(Ref ref) {
    final argument = this.argument as ({int year, int month, String? username});
    return mergedCalendar(
      ref,
      year: argument.year,
      month: argument.month,
      username: argument.username,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MergedCalendarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mergedCalendarHash() => r'8c1563f4ead595f75f04bf5603dd9b08886a8d83';

/// Provider for fetching merged calendar for a specific month

final class MergedCalendarFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnEventCalendarEntry>,
          ({int year, int month, String? username})
        > {
  MergedCalendarFamily._()
    : super(
        retry: null,
        name: r'mergedCalendarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching merged calendar for a specific month

  MergedCalendarProvider call({
    required int year,
    required int month,
    String? username,
  }) => MergedCalendarProvider._(
    argument: (year: year, month: month, username: username),
    from: this,
  );

  @override
  String toString() => r'mergedCalendarProvider';
}

/// Provider for listing user's calendar events

@ProviderFor(calendarEvents)
final calendarEventsProvider = CalendarEventsFamily._();

/// Provider for listing user's calendar events

final class CalendarEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResult<SnUserCalendarEvent>>,
          PaginatedResult<SnUserCalendarEvent>,
          FutureOr<PaginatedResult<SnUserCalendarEvent>>
        >
    with
        $FutureModifier<PaginatedResult<SnUserCalendarEvent>>,
        $FutureProvider<PaginatedResult<SnUserCalendarEvent>> {
  /// Provider for listing user's calendar events
  CalendarEventsProvider._({
    required CalendarEventsFamily super.from,
    required CalendarEventListQuery super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarEventsHash();

  @override
  String toString() {
    return r'calendarEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnUserCalendarEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnUserCalendarEvent>> create(Ref ref) {
    final argument = this.argument as CalendarEventListQuery;
    return calendarEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventsHash() => r'6c431c6c85f140c100b2854decb3719d06249286';

/// Provider for listing user's calendar events

final class CalendarEventsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedResult<SnUserCalendarEvent>>,
          CalendarEventListQuery
        > {
  CalendarEventsFamily._()
    : super(
        retry: null,
        name: r'calendarEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for listing user's calendar events

  CalendarEventsProvider call(CalendarEventListQuery query) =>
      CalendarEventsProvider._(argument: query, from: this);

  @override
  String toString() => r'calendarEventsProvider';
}

/// Provider for a single calendar event

@ProviderFor(calendarEvent)
final calendarEventProvider = CalendarEventFamily._();

/// Provider for a single calendar event

final class CalendarEventProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnUserCalendarEvent>,
          SnUserCalendarEvent,
          FutureOr<SnUserCalendarEvent>
        >
    with
        $FutureModifier<SnUserCalendarEvent>,
        $FutureProvider<SnUserCalendarEvent> {
  /// Provider for a single calendar event
  CalendarEventProvider._({
    required CalendarEventFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarEventHash();

  @override
  String toString() {
    return r'calendarEventProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnUserCalendarEvent> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnUserCalendarEvent> create(Ref ref) {
    final argument = this.argument as String;
    return calendarEvent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventHash() => r'ec9b54062c6be0ef862a38d2e8a2bd32e0f6889b';

/// Provider for a single calendar event

final class CalendarEventFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnUserCalendarEvent>, String> {
  CalendarEventFamily._()
    : super(
        retry: null,
        name: r'calendarEventProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a single calendar event

  CalendarEventProvider call(String eventId) =>
      CalendarEventProvider._(argument: eventId, from: this);

  @override
  String toString() => r'calendarEventProvider';
}

/// Provider for fetching upcoming event countdowns

@ProviderFor(eventCountdowns)
final eventCountdownsProvider = EventCountdownsFamily._();

/// Provider for fetching upcoming event countdowns

final class EventCountdownsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnEventCountdownItem>>,
          List<SnEventCountdownItem>,
          FutureOr<List<SnEventCountdownItem>>
        >
    with
        $FutureModifier<List<SnEventCountdownItem>>,
        $FutureProvider<List<SnEventCountdownItem>> {
  /// Provider for fetching upcoming event countdowns
  EventCountdownsProvider._({
    required EventCountdownsFamily super.from,
    required ({int take, String? username}) super.argument,
  }) : super(
         retry: null,
         name: r'eventCountdownsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventCountdownsHash();

  @override
  String toString() {
    return r'eventCountdownsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnEventCountdownItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnEventCountdownItem>> create(Ref ref) {
    final argument = this.argument as ({int take, String? username});
    return eventCountdowns(
      ref,
      take: argument.take,
      username: argument.username,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventCountdownsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventCountdownsHash() => r'cfaacd6634d3367d789c69e83a7fdc6100abe97f';

/// Provider for fetching upcoming event countdowns

final class EventCountdownsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnEventCountdownItem>>,
          ({int take, String? username})
        > {
  EventCountdownsFamily._()
    : super(
        retry: null,
        name: r'eventCountdownsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching upcoming event countdowns

  EventCountdownsProvider call({int take = 5, String? username}) =>
      EventCountdownsProvider._(
        argument: (take: take, username: username),
        from: this,
      );

  @override
  String toString() => r'eventCountdownsProvider';
}

/// Provider for countdowns within the next week

@ProviderFor(weekCountdowns)
final weekCountdownsProvider = WeekCountdownsFamily._();

/// Provider for countdowns within the next week

final class WeekCountdownsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnEventCountdownItem>>,
          List<SnEventCountdownItem>,
          FutureOr<List<SnEventCountdownItem>>
        >
    with
        $FutureModifier<List<SnEventCountdownItem>>,
        $FutureProvider<List<SnEventCountdownItem>> {
  /// Provider for countdowns within the next week
  WeekCountdownsProvider._({
    required WeekCountdownsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'weekCountdownsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weekCountdownsHash();

  @override
  String toString() {
    return r'weekCountdownsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnEventCountdownItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnEventCountdownItem>> create(Ref ref) {
    final argument = this.argument as String?;
    return weekCountdowns(ref, username: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekCountdownsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weekCountdownsHash() => r'd8d9c8f419c6edf6967164271da13ae847946bdf';

/// Provider for countdowns within the next week

final class WeekCountdownsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnEventCountdownItem>>,
          String?
        > {
  WeekCountdownsFamily._()
    : super(
        retry: null,
        name: r'weekCountdownsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for countdowns within the next week

  WeekCountdownsProvider call({String? username}) =>
      WeekCountdownsProvider._(argument: username, from: this);

  @override
  String toString() => r'weekCountdownsProvider';
}

/// Provider for countdowns within the next month

@ProviderFor(monthCountdowns)
final monthCountdownsProvider = MonthCountdownsFamily._();

/// Provider for countdowns within the next month

final class MonthCountdownsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnEventCountdownItem>>,
          List<SnEventCountdownItem>,
          FutureOr<List<SnEventCountdownItem>>
        >
    with
        $FutureModifier<List<SnEventCountdownItem>>,
        $FutureProvider<List<SnEventCountdownItem>> {
  /// Provider for countdowns within the next month
  MonthCountdownsProvider._({
    required MonthCountdownsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'monthCountdownsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthCountdownsHash();

  @override
  String toString() {
    return r'monthCountdownsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnEventCountdownItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnEventCountdownItem>> create(Ref ref) {
    final argument = this.argument as String?;
    return monthCountdowns(ref, username: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthCountdownsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthCountdownsHash() => r'bd39223335f2bab1b8215d5707598809fdc1e64d';

/// Provider for countdowns within the next month

final class MonthCountdownsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnEventCountdownItem>>,
          String?
        > {
  MonthCountdownsFamily._()
    : super(
        retry: null,
        name: r'monthCountdownsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for countdowns within the next month

  MonthCountdownsProvider call({String? username}) =>
      MonthCountdownsProvider._(argument: username, from: this);

  @override
  String toString() => r'monthCountdownsProvider';
}

/// Provider for countdowns within the next year

@ProviderFor(yearCountdowns)
final yearCountdownsProvider = YearCountdownsFamily._();

/// Provider for countdowns within the next year

final class YearCountdownsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnEventCountdownItem>>,
          List<SnEventCountdownItem>,
          FutureOr<List<SnEventCountdownItem>>
        >
    with
        $FutureModifier<List<SnEventCountdownItem>>,
        $FutureProvider<List<SnEventCountdownItem>> {
  /// Provider for countdowns within the next year
  YearCountdownsProvider._({
    required YearCountdownsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'yearCountdownsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearCountdownsHash();

  @override
  String toString() {
    return r'yearCountdownsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnEventCountdownItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnEventCountdownItem>> create(Ref ref) {
    final argument = this.argument as String?;
    return yearCountdowns(ref, username: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearCountdownsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearCountdownsHash() => r'd7c6d5901c7822a91a8aeecdd26164e7cdec7913';

/// Provider for countdowns within the next year

final class YearCountdownsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnEventCountdownItem>>,
          String?
        > {
  YearCountdownsFamily._()
    : super(
        retry: null,
        name: r'yearCountdownsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for countdowns within the next year

  YearCountdownsProvider call({String? username}) =>
      YearCountdownsProvider._(argument: username, from: this);

  @override
  String toString() => r'yearCountdownsProvider';
}
