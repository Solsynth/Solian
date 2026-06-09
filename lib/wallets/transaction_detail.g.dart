// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionDetail)
final transactionDetailProvider = TransactionDetailFamily._();

final class TransactionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnTransaction>,
          SnTransaction,
          FutureOr<SnTransaction>
        >
    with $FutureModifier<SnTransaction>, $FutureProvider<SnTransaction> {
  TransactionDetailProvider._({
    required TransactionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionDetailHash();

  @override
  String toString() {
    return r'transactionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnTransaction> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnTransaction> create(Ref ref) {
    final argument = this.argument as String;
    return transactionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionDetailHash() => r'1d40f1558b1e4c7c4449818caf722017f17e7068';

final class TransactionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnTransaction>, String> {
  TransactionDetailFamily._()
    : super(
        retry: null,
        name: r'transactionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionDetailProvider call(String id) =>
      TransactionDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionDetailProvider';
}
