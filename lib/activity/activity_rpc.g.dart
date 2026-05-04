// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_rpc.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(presenceActivities)
final presenceActivitiesProvider = PresenceActivitiesFamily._();

final class PresenceActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPresenceActivity>>,
          List<SnPresenceActivity>,
          FutureOr<List<SnPresenceActivity>>
        >
    with
        $FutureModifier<List<SnPresenceActivity>>,
        $FutureProvider<List<SnPresenceActivity>> {
  PresenceActivitiesProvider._({
    required PresenceActivitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'presenceActivitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presenceActivitiesHash();

  @override
  String toString() {
    return r'presenceActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnPresenceActivity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPresenceActivity>> create(Ref ref) {
    final argument = this.argument as String;
    return presenceActivities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presenceActivitiesHash() =>
    r'cca9b8f5c5697db6df7a4971348f0cc4a41593df';

final class PresenceActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnPresenceActivity>>, String> {
  PresenceActivitiesFamily._()
    : super(
        retry: null,
        name: r'presenceActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PresenceActivitiesProvider call(String uname) =>
      PresenceActivitiesProvider._(argument: uname, from: this);

  @override
  String toString() => r'presenceActivitiesProvider';
}
