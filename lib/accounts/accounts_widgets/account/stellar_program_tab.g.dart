// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stellar_program_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountStellarSubscription)
final accountStellarSubscriptionProvider =
    AccountStellarSubscriptionProvider._();

final class AccountStellarSubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWalletSubscription?>,
          SnWalletSubscription?,
          FutureOr<SnWalletSubscription?>
        >
    with
        $FutureModifier<SnWalletSubscription?>,
        $FutureProvider<SnWalletSubscription?> {
  AccountStellarSubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountStellarSubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountStellarSubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<SnWalletSubscription?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnWalletSubscription?> create(Ref ref) {
    return accountStellarSubscription(ref);
  }
}

String _$accountStellarSubscriptionHash() =>
    r'fd0aa9b7110e5d0ba68d8a57bd0e4dc191586e3b';

@ProviderFor(accountSentGifts)
final accountSentGiftsProvider = AccountSentGiftsFamily._();

final class AccountSentGiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnWalletGift>>,
          List<SnWalletGift>,
          FutureOr<List<SnWalletGift>>
        >
    with
        $FutureModifier<List<SnWalletGift>>,
        $FutureProvider<List<SnWalletGift>> {
  AccountSentGiftsProvider._({
    required AccountSentGiftsFamily super.from,
    required ({int offset, int take}) super.argument,
  }) : super(
         retry: null,
         name: r'accountSentGiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountSentGiftsHash();

  @override
  String toString() {
    return r'accountSentGiftsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnWalletGift>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnWalletGift>> create(Ref ref) {
    final argument = this.argument as ({int offset, int take});
    return accountSentGifts(ref, offset: argument.offset, take: argument.take);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountSentGiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountSentGiftsHash() => r'9fa99729b9efa1a74695645ee1418677b5e63027';

final class AccountSentGiftsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnWalletGift>>,
          ({int offset, int take})
        > {
  AccountSentGiftsFamily._()
    : super(
        retry: null,
        name: r'accountSentGiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountSentGiftsProvider call({int offset = 0, int take = 20}) =>
      AccountSentGiftsProvider._(
        argument: (offset: offset, take: take),
        from: this,
      );

  @override
  String toString() => r'accountSentGiftsProvider';
}

@ProviderFor(accountReceivedGifts)
final accountReceivedGiftsProvider = AccountReceivedGiftsFamily._();

final class AccountReceivedGiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnWalletGift>>,
          List<SnWalletGift>,
          FutureOr<List<SnWalletGift>>
        >
    with
        $FutureModifier<List<SnWalletGift>>,
        $FutureProvider<List<SnWalletGift>> {
  AccountReceivedGiftsProvider._({
    required AccountReceivedGiftsFamily super.from,
    required ({int offset, int take}) super.argument,
  }) : super(
         retry: null,
         name: r'accountReceivedGiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountReceivedGiftsHash();

  @override
  String toString() {
    return r'accountReceivedGiftsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnWalletGift>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnWalletGift>> create(Ref ref) {
    final argument = this.argument as ({int offset, int take});
    return accountReceivedGifts(
      ref,
      offset: argument.offset,
      take: argument.take,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountReceivedGiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountReceivedGiftsHash() =>
    r'b9e9ad5e8de8916f881ceeca7f2032f344c5c58b';

final class AccountReceivedGiftsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnWalletGift>>,
          ({int offset, int take})
        > {
  AccountReceivedGiftsFamily._()
    : super(
        retry: null,
        name: r'accountReceivedGiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountReceivedGiftsProvider call({int offset = 0, int take = 20}) =>
      AccountReceivedGiftsProvider._(
        argument: (offset: offset, take: take),
        from: this,
      );

  @override
  String toString() => r'accountReceivedGiftsProvider';
}

@ProviderFor(accountGift)
final accountGiftProvider = AccountGiftFamily._();

final class AccountGiftProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWalletGift>,
          SnWalletGift,
          FutureOr<SnWalletGift>
        >
    with $FutureModifier<SnWalletGift>, $FutureProvider<SnWalletGift> {
  AccountGiftProvider._({
    required AccountGiftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountGiftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountGiftHash();

  @override
  String toString() {
    return r'accountGiftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnWalletGift> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnWalletGift> create(Ref ref) {
    final argument = this.argument as String;
    return accountGift(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountGiftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountGiftHash() => r'78890be44865accadeabdc26a96447bb3e841a5d';

final class AccountGiftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnWalletGift>, String> {
  AccountGiftFamily._()
    : super(
        retry: null,
        name: r'accountGiftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountGiftProvider call(String giftId) =>
      AccountGiftProvider._(argument: giftId, from: this);

  @override
  String toString() => r'accountGiftProvider';
}
