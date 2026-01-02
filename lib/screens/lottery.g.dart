// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lotteryTickets)
final lotteryTicketsProvider = LotteryTicketsFamily._();

final class LotteryTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnLotteryTicket>>,
          List<SnLotteryTicket>,
          FutureOr<List<SnLotteryTicket>>
        >
    with
        $FutureModifier<List<SnLotteryTicket>>,
        $FutureProvider<List<SnLotteryTicket>> {
  LotteryTicketsProvider._({
    required LotteryTicketsFamily super.from,
    required ({int offset, int take}) super.argument,
  }) : super(
         retry: null,
         name: r'lotteryTicketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lotteryTicketsHash();

  @override
  String toString() {
    return r'lotteryTicketsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnLotteryTicket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnLotteryTicket>> create(Ref ref) {
    final argument = this.argument as ({int offset, int take});
    return lotteryTickets(ref, offset: argument.offset, take: argument.take);
  }

  @override
  bool operator ==(Object other) {
    return other is LotteryTicketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotteryTicketsHash() => r'dd17cd721fc3b176ffa0ee0a85d0d850740e5e80';

final class LotteryTicketsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnLotteryTicket>>,
          ({int offset, int take})
        > {
  LotteryTicketsFamily._()
    : super(
        retry: null,
        name: r'lotteryTicketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LotteryTicketsProvider call({int offset = 0, int take = 20}) =>
      LotteryTicketsProvider._(
        argument: (offset: offset, take: take),
        from: this,
      );

  @override
  String toString() => r'lotteryTicketsProvider';
}

@ProviderFor(lotteryRecords)
final lotteryRecordsProvider = LotteryRecordsFamily._();

final class LotteryRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnLotteryRecord>>,
          List<SnLotteryRecord>,
          FutureOr<List<SnLotteryRecord>>
        >
    with
        $FutureModifier<List<SnLotteryRecord>>,
        $FutureProvider<List<SnLotteryRecord>> {
  LotteryRecordsProvider._({
    required LotteryRecordsFamily super.from,
    required ({int offset, int take}) super.argument,
  }) : super(
         retry: null,
         name: r'lotteryRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lotteryRecordsHash();

  @override
  String toString() {
    return r'lotteryRecordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnLotteryRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnLotteryRecord>> create(Ref ref) {
    final argument = this.argument as ({int offset, int take});
    return lotteryRecords(ref, offset: argument.offset, take: argument.take);
  }

  @override
  bool operator ==(Object other) {
    return other is LotteryRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotteryRecordsHash() => r'55c657460f18d9777741d09013b445ca036863f3';

final class LotteryRecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnLotteryRecord>>,
          ({int offset, int take})
        > {
  LotteryRecordsFamily._()
    : super(
        retry: null,
        name: r'lotteryRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LotteryRecordsProvider call({int offset = 0, int take = 20}) =>
      LotteryRecordsProvider._(
        argument: (offset: offset, take: take),
        from: this,
      );

  @override
  String toString() => r'lotteryRecordsProvider';
}
