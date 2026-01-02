// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountStatus)
final accountStatusProvider = AccountStatusFamily._();

final class AccountStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnAccountStatus?>,
          SnAccountStatus?,
          FutureOr<SnAccountStatus?>
        >
    with $FutureModifier<SnAccountStatus?>, $FutureProvider<SnAccountStatus?> {
  AccountStatusProvider._({
    required AccountStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountStatusHash();

  @override
  String toString() {
    return r'accountStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnAccountStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnAccountStatus?> create(Ref ref) {
    final argument = this.argument as String;
    return accountStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountStatusHash() => r'4cac809808e6f1345dab06dc32d759cfcea13315';

final class AccountStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnAccountStatus?>, String> {
  AccountStatusFamily._()
    : super(
        retry: null,
        name: r'accountStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountStatusProvider call(String uname) =>
      AccountStatusProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountStatusProvider';
}
