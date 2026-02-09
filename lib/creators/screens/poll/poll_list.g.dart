// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pollWithStats)
final pollWithStatsProvider = PollWithStatsFamily._();

final class PollWithStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPollWithStats>,
          SnPollWithStats,
          FutureOr<SnPollWithStats>
        >
    with $FutureModifier<SnPollWithStats>, $FutureProvider<SnPollWithStats> {
  PollWithStatsProvider._({
    required PollWithStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pollWithStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pollWithStatsHash();

  @override
  String toString() {
    return r'pollWithStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPollWithStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPollWithStats> create(Ref ref) {
    final argument = this.argument as String;
    return pollWithStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PollWithStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pollWithStatsHash() => r'6bb910046ce1e09368f9922dbec52fdc2cc86740';

final class PollWithStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPollWithStats>, String> {
  PollWithStatsFamily._()
    : super(
        retry: null,
        name: r'pollWithStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PollWithStatsProvider call(String id) =>
      PollWithStatsProvider._(argument: id, from: this);

  @override
  String toString() => r'pollWithStatsProvider';
}
