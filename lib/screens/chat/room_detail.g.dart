// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(totalMessagesCount)
final totalMessagesCountProvider = TotalMessagesCountFamily._();

final class TotalMessagesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TotalMessagesCountProvider._({
    required TotalMessagesCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalMessagesCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalMessagesCountHash();

  @override
  String toString() {
    return r'totalMessagesCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return totalMessagesCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalMessagesCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalMessagesCountHash() =>
    r'd55f1507aba2acdce5e468c1c2e15dba7640c571';

final class TotalMessagesCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  TotalMessagesCountFamily._()
    : super(
        retry: null,
        name: r'totalMessagesCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalMessagesCountProvider call(String roomId) =>
      TotalMessagesCountProvider._(argument: roomId, from: this);

  @override
  String toString() => r'totalMessagesCountProvider';
}
