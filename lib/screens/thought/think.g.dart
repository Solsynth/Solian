// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'think.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$thoughtSequenceHash() => r'2a93c0a04f9a720ba474c02a36502940fb7f3ed7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [thoughtSequence].
@ProviderFor(thoughtSequence)
const thoughtSequenceProvider = ThoughtSequenceFamily();

/// See also [thoughtSequence].
class ThoughtSequenceFamily
    extends Family<AsyncValue<List<SnThinkingThought>>> {
  /// See also [thoughtSequence].
  const ThoughtSequenceFamily();

  /// See also [thoughtSequence].
  ThoughtSequenceProvider call(String sequenceId) {
    return ThoughtSequenceProvider(sequenceId);
  }

  @override
  ThoughtSequenceProvider getProviderOverride(
    covariant ThoughtSequenceProvider provider,
  ) {
    return call(provider.sequenceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'thoughtSequenceProvider';
}

/// See also [thoughtSequence].
class ThoughtSequenceProvider
    extends AutoDisposeFutureProvider<List<SnThinkingThought>> {
  /// See also [thoughtSequence].
  ThoughtSequenceProvider(String sequenceId)
    : this._internal(
        (ref) => thoughtSequence(ref as ThoughtSequenceRef, sequenceId),
        from: thoughtSequenceProvider,
        name: r'thoughtSequenceProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$thoughtSequenceHash,
        dependencies: ThoughtSequenceFamily._dependencies,
        allTransitiveDependencies:
            ThoughtSequenceFamily._allTransitiveDependencies,
        sequenceId: sequenceId,
      );

  ThoughtSequenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sequenceId,
  }) : super.internal();

  final String sequenceId;

  @override
  Override overrideWith(
    FutureOr<List<SnThinkingThought>> Function(ThoughtSequenceRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ThoughtSequenceProvider._internal(
        (ref) => create(ref as ThoughtSequenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sequenceId: sequenceId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnThinkingThought>> createElement() {
    return _ThoughtSequenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThoughtSequenceProvider && other.sequenceId == sequenceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sequenceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ThoughtSequenceRef
    on AutoDisposeFutureProviderRef<List<SnThinkingThought>> {
  /// The parameter `sequenceId` of this provider.
  String get sequenceId;
}

class _ThoughtSequenceProviderElement
    extends AutoDisposeFutureProviderElement<List<SnThinkingThought>>
    with ThoughtSequenceRef {
  _ThoughtSequenceProviderElement(super.provider);

  @override
  String get sequenceId => (origin as ThoughtSequenceProvider).sequenceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
