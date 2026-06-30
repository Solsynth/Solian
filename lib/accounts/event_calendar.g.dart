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

/// Provider for the list of account IDs the current user has subscribed to

@ProviderFor(calendarSubscriptions)
final calendarSubscriptionsProvider = CalendarSubscriptionsProvider._();

/// Provider for the list of account IDs the current user has subscribed to

final class CalendarSubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for the list of account IDs the current user has subscribed to
  CalendarSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return calendarSubscriptions(ref);
  }
}

String _$calendarSubscriptionsHash() =>
    r'00c449239ed0a938fb553d079f280800bda3db3e';

/// Checks if the current user is subscribed to a specific account's calendar

@ProviderFor(isCalendarSubscribed)
final isCalendarSubscribedProvider = IsCalendarSubscribedFamily._();

/// Checks if the current user is subscribed to a specific account's calendar

final class IsCalendarSubscribedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Checks if the current user is subscribed to a specific account's calendar
  IsCalendarSubscribedProvider._({
    required IsCalendarSubscribedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isCalendarSubscribedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isCalendarSubscribedHash();

  @override
  String toString() {
    return r'isCalendarSubscribedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isCalendarSubscribed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsCalendarSubscribedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isCalendarSubscribedHash() =>
    r'f912fbf6bebcf675bb35f39bb80dbb918fcb8a2c';

/// Checks if the current user is subscribed to a specific account's calendar

final class IsCalendarSubscribedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsCalendarSubscribedFamily._()
    : super(
        retry: null,
        name: r'isCalendarSubscribedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Checks if the current user is subscribed to a specific account's calendar

  IsCalendarSubscribedProvider call(String accountId) =>
      IsCalendarSubscribedProvider._(argument: accountId, from: this);

  @override
  String toString() => r'isCalendarSubscribedProvider';
}

/// Provider for fetching the current user's used calendar tags

@ProviderFor(usedCalendarTags)
final usedCalendarTagsProvider = UsedCalendarTagsProvider._();

/// Provider for fetching the current user's used calendar tags

final class UsedCalendarTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for fetching the current user's used calendar tags
  UsedCalendarTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usedCalendarTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usedCalendarTagsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return usedCalendarTags(ref);
  }
}

String _$usedCalendarTagsHash() => r'8e1795f4fe61ebc073589277e7a2a635c386b223';

/// Provider for searching calendar events + notable days

@ProviderFor(calendarSearch)
final calendarSearchProvider = CalendarSearchFamily._();

/// Provider for searching calendar events + notable days

final class CalendarSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarSearchResult>>,
          List<CalendarSearchResult>,
          FutureOr<List<CalendarSearchResult>>
        >
    with
        $FutureModifier<List<CalendarSearchResult>>,
        $FutureProvider<List<CalendarSearchResult>> {
  /// Provider for searching calendar events + notable days
  CalendarSearchProvider._({
    required CalendarSearchFamily super.from,
    required CalendarSearchQuery super.argument,
  }) : super(
         retry: null,
         name: r'calendarSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarSearchHash();

  @override
  String toString() {
    return r'calendarSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CalendarSearchResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CalendarSearchResult>> create(Ref ref) {
    final argument = this.argument as CalendarSearchQuery;
    return calendarSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarSearchHash() => r'58ff0dca31f21f95db5784564e2d3fa24a3f01b2';

/// Provider for searching calendar events + notable days

final class CalendarSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CalendarSearchResult>>,
          CalendarSearchQuery
        > {
  CalendarSearchFamily._()
    : super(
        retry: null,
        name: r'calendarSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for searching calendar events + notable days

  CalendarSearchProvider call(CalendarSearchQuery query) =>
      CalendarSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'calendarSearchProvider';
}
