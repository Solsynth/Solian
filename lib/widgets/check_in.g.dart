// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(checkInResultToday)
const checkInResultTodayProvider = CheckInResultTodayProvider._();

final class CheckInResultTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnCheckInResult?>,
          SnCheckInResult?,
          FutureOr<SnCheckInResult?>
        >
    with $FutureModifier<SnCheckInResult?>, $FutureProvider<SnCheckInResult?> {
  const CheckInResultTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInResultTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInResultTodayHash();

  @$internal
  @override
  $FutureProviderElement<SnCheckInResult?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnCheckInResult?> create(Ref ref) {
    return checkInResultToday(ref);
  }
}

String _$checkInResultTodayHash() =>
    r'b4dc97b2243f542b36c295dc5cce3fe6097cb308';

@ProviderFor(nextNotableDay)
const nextNotableDayProvider = NextNotableDayProvider._();

final class NextNotableDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnNotableDay?>,
          SnNotableDay?,
          FutureOr<SnNotableDay?>
        >
    with $FutureModifier<SnNotableDay?>, $FutureProvider<SnNotableDay?> {
  const NextNotableDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextNotableDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextNotableDayHash();

  @$internal
  @override
  $FutureProviderElement<SnNotableDay?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnNotableDay?> create(Ref ref) {
    return nextNotableDay(ref);
  }
}

String _$nextNotableDayHash() => r'c8404308f6b0f581cc7df251bce8f3c5ac130245';
