// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_pod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(relationshipAlias)
final relationshipAliasProvider = RelationshipAliasFamily._();

final class RelationshipAliasProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  RelationshipAliasProvider._({
    required RelationshipAliasFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'relationshipAliasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relationshipAliasHash();

  @override
  String toString() {
    return r'relationshipAliasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return relationshipAlias(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelationshipAliasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relationshipAliasHash() => r'572a4fddc02609db69d6832b92ccc6ecf3cf62d8';

final class RelationshipAliasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  RelationshipAliasFamily._()
    : super(
        retry: null,
        name: r'relationshipAliasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RelationshipAliasProvider call(String targetAccountId) =>
      RelationshipAliasProvider._(argument: targetAccountId, from: this);

  @override
  String toString() => r'relationshipAliasProvider';
}
