// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchAccounts)
final searchAccountsProvider = SearchAccountsFamily._();

final class SearchAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAccount>>,
          List<SnAccount>,
          FutureOr<List<SnAccount>>
        >
    with $FutureModifier<List<SnAccount>>, $FutureProvider<List<SnAccount>> {
  SearchAccountsProvider._({
    required SearchAccountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchAccountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchAccountsHash();

  @override
  String toString() {
    return r'searchAccountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAccount>> create(Ref ref) {
    final argument = this.argument as String;
    return searchAccounts(ref, query: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAccountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchAccountsHash() => r'70960eded34048df04dafd0da30752752f06b1ad';

final class SearchAccountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnAccount>>, String> {
  SearchAccountsFamily._()
    : super(
        retry: null,
        name: r'searchAccountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchAccountsProvider call({required String query}) =>
      SearchAccountsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchAccountsProvider';
}
